from pydantic import BaseModel
from typing import Optional, Dict, Any


class SaveScanRequest(BaseModel):
    object_name: str
    chosen_lens: str
    # We pass the entire deck exactly as Gemini generated it
    learning_deck: Dict[str, Any]
    image_url: Optional[str] = None


class SaveScanResponse(BaseModel):
    status: str
    message: str
    scan_id: str
    xp_awarded: int  # We return the hardcoded XP so the Flutter UI can animate it
