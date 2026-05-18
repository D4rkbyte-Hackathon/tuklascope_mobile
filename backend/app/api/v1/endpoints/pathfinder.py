from fastapi import APIRouter, Depends, HTTPException
from supabase import Client
import logging

from app.schemas.pathfinder import PathfinderResponse, SkillWebResponse
from app.services.graph_service import get_user_skill_web
from app.services.llm_service import generate_holistic_pathfinder
from app.services.compass_service import resolve_pathfinder_input
from app.core.security import get_user_db_client

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/recommend", response_model=PathfinderResponse)
async def get_career_recommendations(
    db_data: tuple[Client, str] = Depends(get_user_db_client),
):
    try:
        db_client, user_id = db_data

        # 1. Neo4j skill web, or Compass when no scans exist yet
        neo4j_web = await get_user_skill_web(user_id)
        try:
            skill_web, from_compass = resolve_pathfinder_input(
                db_client, user_id, neo4j_web
            )
        except ValueError:
            raise HTTPException(
                status_code=404,
                detail=(
                    "Not enough data. Complete the Compass quiz or scan objects "
                    "to build your Kaalaman Skill Tree first!"
                ),
            )

        # 2. Ask Gemini to synthesize into the 3 career tiers
        recommendations = await generate_holistic_pathfinder(
            xp_distribution=skill_web["xp_distribution"],
            top_skills=skill_web.get("top_skills", []),
            from_compass=from_compass,
        )

        return recommendations

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Pathfinder Recommend Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"AI Synthesis failed: {str(e)}")


@router.get("/skills", response_model=SkillWebResponse)
async def get_user_skills(db_data: tuple[Client, str] = Depends(get_user_db_client)):
    """
    Returns the raw Neo4j Graph Data (Nodes and Levels) for the user's Skill Tree visualization.
    """
    try:
        _, user_id = db_data
        skill_web = await get_user_skill_web(user_id)

        if not skill_web:
            return SkillWebResponse(xp_distribution={}, top_skills=[])

        # Safely pass the new structured JSON directly to the Pydantic model
        return SkillWebResponse(
            xp_distribution=skill_web.get("xp_distribution", {}),
            top_skills=skill_web.get("top_skills", []),
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Pathfinder Skills Error: {e}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Neo4j Data fetch failed: {str(e)}"
        )
