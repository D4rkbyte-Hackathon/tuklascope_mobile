from supabase import Client
from app.schemas.scan import SaveScanRequest
from fastapi import HTTPException


def save_user_discovery(db_client: Client, user_id: str, data: SaveScanRequest) -> str:
    """
    Saves the finalized scan to the database. 
    Because db_client is authenticated via JWT, Supabase automatically maps it to the correct user_id!
    """
    try:
        # 1. Insert the scan
        # We don't need to pass user_id because RLS and the authenticated client handle it securely!
        scan_data = {
            "user_id": user_id,
            "object_name": data.object_name,
            "chosen_lens": data.chosen_lens,
            "ai_explanation": data.ai_explanation,
            "xp_awarded": data.xp_awarded,
            "image_url": data.image_url
        }

        response = db_client.table("scans").insert(scan_data).execute()

        if not response.data:
            raise Exception("Failed to insert scan record.")

        return response.data[0]['id']

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Database execution error: {str(e)}")
