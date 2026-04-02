from fastapi import APIRouter, HTTPException, Depends
from supabase import Client
from app.schemas.discover import DiscoverRequest, DiscoverResponse
from app.services.llm_service import generate_discovery_cards
from app.schemas.scan import SaveScanRequest, SaveScanResponse
from app.services.gamification_service import save_user_discovery
from app.core.security import get_user_db_client

router = APIRouter()


@router.post("/", response_model=DiscoverResponse)
async def discover_object(request: DiscoverRequest):
    try:
        response = await generate_discovery_cards(request)
        return response
    except Exception as e:
        # Catch LLM/parsing errors safely
        raise HTTPException(status_code=500, detail=str(e))


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
