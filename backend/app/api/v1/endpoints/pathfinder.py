from fastapi import APIRouter, Depends, HTTPException
from supabase import Client

from app.schemas.pathfinder import PathfinderResponse
from app.services.graph_service import get_dominant_strand
from app.services.llm_service import generate_career_recommendations
from app.core.security import get_user_db_client

router = APIRouter()


@router.get("/recommend", response_model=PathfinderResponse)
async def get_career_recommendations(
    # Secure the route!
    db_data: tuple[Client, str] = Depends(get_user_db_client)
):
    try:
        _, user_id = db_data

        # 1. Ask Neo4j for the user's top strand
        strand_data = get_dominant_strand(user_id)

        if not strand_data:
            raise HTTPException(
                status_code=404,
                detail="Not enough data. Scan more objects to build your Kaalaman Skill Tree first!"
            )

        # 2. Ask Gemini to generate recommendations based on that strand
        recommendations = await generate_career_recommendations(
            strand=strand_data["strand"],
            xp=strand_data["xp"]
        )

        return recommendations

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
