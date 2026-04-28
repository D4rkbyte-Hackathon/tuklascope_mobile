from pydantic import BaseModel, Field


class TeaserDoor(BaseModel):
    lens: str = Field(..., description="The track lens: STEM, ABM, HUMSS, or TVL")
    title: str = Field(..., description="A catchy, short title (Maximum 40 characters)")
    teaser_text: str = Field(
        ..., description="A punchy, engaging teaser (Maximum 85 characters)"
    )


class DiscoverResponse(BaseModel):
    scanned_object: str
    teaser_doors: list[TeaserDoor]
