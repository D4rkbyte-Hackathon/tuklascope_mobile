from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from supabase import Client
from app.schemas.discover import DiscoverRequest, DiscoverResponse, GradeLevel
from app.schemas.scan import SaveScanRequest, SaveScanResponse
from app.services.llm_service import generate_discovery_cards, generate_discovery_from_image
from app.services.gamification_service import save_user_discovery
from app.services.graph_service import save_skill_to_graph
from app.core.security import get_user_db_client

router = APIRouter()

# --- 1. Text-Only Fallback Function ---


@router.post("/", response_model=DiscoverResponse)
async def discover_object(request: DiscoverRequest):
    try:
        response = await generate_discovery_cards(request)
        return response
    except Exception as e:
        # Catch LLM/parsing errors safely
        raise HTTPException(status_code=500, detail=str(e))

# --- 2. The Multimodal Vision Route ---


@router.post("/vision", response_model=DiscoverResponse)
async def discover_from_vision(
    # Flutter will send these as multipart form data
    grade_level: GradeLevel = Form(...,
                                   description="The user's academic stage"),
    file: UploadFile = File(..., description="The photo taken by the user")
):
    # Security: Ensure it's actually an image to prevent malicious file uploads
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400, detail="File must be an image (JPEG, PNG, etc.)")

    try:
        # Read the raw file bytes into memory
        image_bytes = await file.read()

        # Send bytes to Gemini
        response = await generate_discovery_from_image(image_bytes, grade_level.value)
        return response

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- 3. Gamification Save Route ---


@router.post("/save", response_model=SaveScanResponse)
def save_discovery_choice(
    request: SaveScanRequest,
    db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    try:
        db_client, user_id = db_data

        # 1. Extract the skill for Neo4j directly from the JSON payload
        extracted_skill = request.learning_deck.get(
            "concept_card", {}).get("skill", "General Knowledge")

        # 2. SUPABASE: Save the Document state for the History Tab using the custom XP
        scan_id = save_user_discovery(
            db_client, user_id, request)

        # 3. NEO4J: Update the user's Knowledge Graph using the custom XP
        graph_success = save_skill_to_graph(
            user_id=user_id,
            strand_name=request.chosen_lens,
            skill_name=extracted_skill,
            xp_awarded=request.xp_awarded
        )

        if not graph_success:
            print(f"Warning: Failed to update Neo4j for user {user_id}")

        return SaveScanResponse(
            status="success",
            message=f"Action completed! {request.xp_awarded} XP added.",
            scan_id=str(scan_id),
            xp_awarded=request.xp_awarded
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
