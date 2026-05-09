from pydantic import BaseModel, Field
from typing import Any


class SaveScanRequest(BaseModel):
    object_name: str = Field(..., description="The primary name of the scanned object")
    chosen_lens: str = Field(
        ..., description="The strand chosen: STEM, ABM, HUMSS, or TVL"
    )
    image_url: str = Field(
        ..., description="The public Supabase Storage URL for the history tab"
    )
    learning_deck: dict[str, Any] = Field(
        ..., description="The completed deck JSON payload"
    )

    is_aligned_with_compass: bool = Field(
        default=False,
        description="Whether this strand matches their top compass affinity",
    )
    # 🚀 FIX: xp_awarded has been completely eliminated from the Request.


class SaveScanResponse(BaseModel):
    status: str
    message: str
    scan_id: str
    xp_awarded: int
