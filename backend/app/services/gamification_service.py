# backend/app/services/gamification_service.py
from supabase import Client
from app.schemas.scan import SaveScanRequest
from fastapi import HTTPException
import logging

logger = logging.getLogger(__name__)


def save_user_discovery(db_client: Client, user_id: str, request: SaveScanRequest) -> str:
    """
    Saves the finalized scan, and triggers the Postgres RPC to update Streaks, XP, and the Skill Tree.
    """
    try:
        # 1. Prepare data for the 'scans' history table
        is_aligned = getattr(request, "is_aligned_with_compass", False)

        data = {
            "user_id": user_id,
            "object_name": request.object_name,
            "chosen_lens": request.chosen_lens,
            "image_url": request.image_url,
            "learning_deck": request.learning_deck,
            "xp_awarded": request.xp_awarded,
            "is_aligned_with_compass": is_aligned
        }

        # 2. Insert into the scans table
        response = db_client.table("scans").insert(data).execute()

        if not response.data:
            raise ValueError(
                "Insert succeeded but no data returned from Supabase.")

        scan_id = response.data[0]["id"]

        # 3. 🚀 CRITICAL: Execute the Postgres Function to update Streaks and Profile XP!
        db_client.rpc(
            "award_xp_and_update_streak",
            {
                "p_user_id": user_id,
                "p_strand": request.chosen_lens,
                "p_base_xp": request.xp_awarded,
                "p_is_aligned": is_aligned
            }
        ).execute()

        return scan_id

    except Exception as e:
        logger.error(
            f"Failed to save scan to Supabase for user {user_id}: {str(e)}")
        raise HTTPException(
            status_code=500, detail="Database error while saving scan history.")
