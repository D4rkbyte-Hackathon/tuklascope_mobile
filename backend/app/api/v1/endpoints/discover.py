from fastapi import APIRouter, HTTPException
from app.schemas.discover import DiscoverRequest, DiscoverResponse
from app.services.llm_service import generate_discovery_cards

router = APIRouter()


@router.post("/", response_model=DiscoverResponse)
async def discover_object(request: DiscoverRequest):
    try:
        response = await generate_discovery_cards(request)
        return response
    except Exception as e:
        # Catch LLM/parsing errors safely
        raise HTTPException(status_code=500, detail=str(e))
