from fastapi import APIRouter, Depends, HTTPException
from supabase import Client

from app.schemas.cards import LearningDeckRequest, LearningDeckResponse
from app.services.graph_service import get_existing_skills_for_strand
from app.services.llm_service import generate_learning_deck
from app.core.security import get_user_db_client

router = APIRouter()


@router.post("/generate-deck", response_model=LearningDeckResponse)
async def create_learning_deck(
    request: LearningDeckRequest,
    db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    try:
        # 1. Fetch existing skills from Neo4j (The Net)
        existing_skills = await get_existing_skills_for_strand(request.chosen_lens)

        # 2. Generate the 3-Card Deck using Gemini
        deck = await generate_learning_deck(
            object_name=request.object_name,
            strand=request.chosen_lens,
            grade_level=request.grade_level,
            existing_skills=existing_skills
        )

        return deck
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
