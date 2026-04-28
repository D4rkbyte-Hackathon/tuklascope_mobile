from pydantic import BaseModel, Field
from enum import Enum


class GradeLevel(str, Enum):
    ELEM = "Elementary (Grades 4-6)"
    JHS = "JHS (Grades 7-10)"
    SHS = "SHS (Grades 11-12)"


class TeaserDoor(BaseModel):
    lens: str = Field(..., description="The track lens: STEM, ABM, HUMSS, or TVL")
    title: str = Field(..., description="A catchy, short title (Maximum 45 characters)")
    teaser_text: str = Field(
        ..., description="A punchy, engaging teaser (Maximum 90 characters)"
    )


class DiscoverResponse(BaseModel):
    scanned_object: str
    teaser_doors: list[TeaserDoor]
