from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from supabase import Client
from app.schemas.discover import DiscoverRequest, DiscoverResponse, GradeLevel
from app.schemas.scan import SaveScanRequest, SaveScanResponse
from app.services.llm_service import generate_discovery_cards, generate_discovery_from_image
from app.services.gamification_service import save_user_discovery
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
    # This dependency forces the route to require a valid Flutter JWT Token!
    db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    try:
        # Split the tuple into our variables
        db_client, user_id = db_data

        # Pass both to the service
        scan_id = save_user_discovery(db_client, user_id, request)

        return SaveScanResponse(
            status="success",
            message=f"Discovery saved successfully! Awarded {request.xp_awarded} XP.",
            scan_id=scan_id
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
