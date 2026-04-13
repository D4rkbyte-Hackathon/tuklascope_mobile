from supabase import Client
from app.schemas.scan import SaveScanRequest
from fastapi import HTTPException
import logging

logger = logging.getLogger(__name__)


def save_user_discovery(db_client: Client, user_id: str, request: SaveScanRequest) -> str:
    """
    Saves the finalized scan and the entire learning deck to Supabase JSONB.
    """
    try:
        data = {
            "user_id": user_id,
            "object_name": request.object_name,
            "chosen_lens": request.chosen_lens,
            "image_url": request.image_url,
            "learning_deck": request.learning_deck,
            "xp_awarded": request.xp_awarded
        }

        response = db_client.table("scans").insert(data).execute()

        if not response.data:
            raise ValueError(
                "Insert succeeded but no data returned from Supabase.")

        return response.data[0]["id"]

    except Exception as e:
        logger.error(
            f"Failed to save scan to Supabase for user {user_id}: {str(e)}")
        raise HTTPException(
            status_code=500, detail="Database error while saving scan history.")
