from supabase import Client
from app.schemas.scan import SaveScanRequest
from fastapi import HTTPException


def save_user_discovery(db_client: Client, user_id: str, data: SaveScanRequest, calculated_xp: int) -> str:
    """
    Saves the finalized scan and the entire learning deck to Supabase JSONB.
    """
    try:
        scan_data = {
            "user_id": user_id,
            "object_name": data.object_name,
            "chosen_lens": data.chosen_lens,
            "image_url": data.image_url,
            "learning_deck": data.learning_deck,  # Saves the whole JSON object
            "xp_awarded": calculated_xp
        }

        response = db_client.table("scans").insert(scan_data).execute()

        if not response.data:
            raise Exception("Failed to insert scan record.")

        return response.data[0]['id']

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Database execution error: {str(e)}")
