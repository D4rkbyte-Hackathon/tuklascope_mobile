import logging
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, status
from supabase import Client
from app.schemas.discover import DiscoverResponse, GradeLevel
from app.schemas.scan import SaveScanRequest, SaveScanResponse
from app.services.llm_service import generate_discovery_from_image
from app.services.gamification_service import save_user_discovery
from app.services.graph_service import save_skill_to_graph
from app.core.security import get_user_db_client

logger = logging.getLogger(__name__)
router = APIRouter()

# SECURITY: Set maximum image upload size to 5MB to prevent Render Out-Of-Memory crashes
MAX_FILE_SIZE = 5 * 1024 * 1024


@router.post("/vision", response_model=DiscoverResponse)
async def discover_from_vision(
    grade_level: GradeLevel = Form(..., description="The user's academic stage"),
    file: UploadFile = File(..., description="The photo taken by the user"),
    db_data: tuple[Client, str] = Depends(get_user_db_client),
):
    # 1. Validation: Ensure it's an image
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Invalid file type. Only images are allowed.",
        )

    # 2. Validation: Fast fail if file size is reported by the browser/client as too large
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image exceeds the 5MB limit. Please compress the image.",
        )

    try:
        image_bytes = await file.read()

        # 3. Validation: Verify actual byte size in memory just to be safe
        if len(image_bytes) > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail="Image exceeds the 5MB limit.",
            )

        response = await generate_discovery_from_image(image_bytes, grade_level.value)
        return response

    except HTTPException:
        # Let our carefully crafted LLM exceptions pass through directly!
        raise
    except Exception as e:
        # Only catch ACTUAL unexpected server crashes here
        logger.error(f"Unexpected vision error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An internal error occurred while processing your image.",
        )
    finally:
        # Always free memory explicitly
        await file.close()


@router.post("/save", response_model=SaveScanResponse)
async def save_discovery_choice(
    request: SaveScanRequest, db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    db_client, user_id = db_data
    try:
        # Extract BOTH domain and skill for Neo4j directly from the JSON payload
        concept_card = request.learning_deck.get("concept_card", {})
        extracted_domain = concept_card.get("domain", "General Knowledge")
        extracted_skill = concept_card.get("skill", "General Skill")

        # Supabase Save (This calculates and sets the final request.xp_awarded internally)
        scan_id = save_user_discovery(db_client, user_id, request)

        # Neo4j Save (The True RPG Skill Tree)
        graph_success = await save_skill_to_graph(
            user_id=user_id,
            strand_name=request.chosen_lens,
            domain_name=extracted_domain,  # 🚀 NEW PARAMETER
            skill_name=extracted_skill,  # Passes specific skill
            xp_awarded=request.xp_awarded,
        )

        if not graph_success:
            logger.warning(
                f"Failed to update Neo4j for user {user_id}. Supabase scan {scan_id} was saved."
            )
            # Note: We don't fail the request here, but we log it. The user still gets their points in Postgres.

        return SaveScanResponse(
            status="success",
            message=f"Action completed! {request.xp_awarded} XP added.",
            scan_id=str(scan_id),
            xp_awarded=request.xp_awarded,
        )
    except Exception as e:
        logger.error(f"Save Discovery Error for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to save discovery progress.",
        )
