import logging
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.schemas.cards import LearningDeckRequest, LearningDeckResponse
from app.services.graph_service import get_existing_skills_for_strand
from app.services.llm_service import generate_learning_deck
from app.core.security import get_user_db_client

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/generate-deck", response_model=LearningDeckResponse)
async def create_learning_deck(
    request: LearningDeckRequest,
    db_data: tuple[Client, str] = Depends(get_user_db_client),
):
    db_client, user_id = db_data
    try:
        # --- 1. MEMORY CHECK (ANTI-CHEAT) ---
        # Did the user already scan this exact object under this exact lens?
        past_scan = (
            db_client.table("scans")
            .select("learning_deck")
            .eq("user_id", user_id)
            .eq("object_name", request.object_name)
            .eq("chosen_lens", request.chosen_lens)
            .execute()
        )

        if past_scan.data:
            # DUPLICATE FOUND: Return the old deck, bypass Gemini, save API costs!
            saved_deck = past_scan.data[0]["learning_deck"]
            return LearningDeckResponse(
                concept_card=saved_deck.get("concept_card", {}),
                real_world_card=saved_deck.get("real_world_card", {}),
                challenge_card=saved_deck.get("challenge_card", {}),
                is_memory=True,  # 🚀 Flag for the mobile UI
            )

        # --- 2. NEW DISCOVERY (Proceed normally) ---
        existing_skills = await get_existing_skills_for_strand(request.chosen_lens)

        deck = await generate_learning_deck(
            object_name=request.object_name,
            strand=request.chosen_lens,
            grade_level=request.grade_level,
            teaser_context=request.teaser_context,
            existing_skills=existing_skills,
        )

        # Ensure the flag is false for new generations
        deck.is_memory = False
        return deck

    except HTTPException:
        raise
    except RuntimeError as e:
        logger.error(f"Deck Generation Error: {e}")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to generate the learning deck. The AI might be overloaded.",
        )
    except Exception as e:
        logger.error(f"Unexpected error in /generate-deck: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An internal server error occurred.",
        )
