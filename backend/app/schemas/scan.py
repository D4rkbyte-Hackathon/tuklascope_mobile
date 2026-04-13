from pydantic import BaseModel, Field
from typing import Any


class SaveScanRequest(BaseModel):
    object_name: str = Field(...,
                             description="The primary name of the scanned object")
    chosen_lens: str = Field(...,
                             description="The strand chosen: STEM, ABM, HUMSS, or TVL")
    image_url: str = Field(...,
                           description="The public Supabase Storage URL for the history tab")
    learning_deck: dict[str, Any] = Field(...,
                                          description="The completed deck JSON payload")
    xp_awarded: int = Field(...,
                            description="The exact XP to be awarded for this action")


class SaveScanResponse(BaseModel):
    status: str
    message: str
    scan_id: str
    xp_awarded: int
