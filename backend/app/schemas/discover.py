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


# What Gemini outputs
class DiscoverLLMResponse(BaseModel):
    scanned_object: str
    teaser_doors: list[TeaserDoor]
    matched_quest_ids: list[str] = Field(
        default_factory=list,
        description="If active quests were provided, list the IDs of the ones satisfied by the image.",
    )


# What the API sends to the frontend
class DiscoverResponse(DiscoverLLMResponse):
    gamification_token: str | None = None
    quest_target_lenses: list[str] = Field(
        default_factory=list, description="Lenses to highlight in UI"
    )
