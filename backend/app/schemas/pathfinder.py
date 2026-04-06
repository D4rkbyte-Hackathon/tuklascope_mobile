from pydantic import BaseModel, Field


class CareerPath(BaseModel):
    title: str = Field(..., description="The name of the college degree or career (e.g., BS Mechanical Engineering)")
    description: str = Field(
        ..., description="A short, inspiring explanation of why this fits their scanned objects")
    match_confidence: int = Field(
        ..., description="A percentage (0-100) indicating how well this matches their exploration")


class PathfinderResponse(BaseModel):
    dominant_strand: str = Field(...,
                                 description="The strand they interact with the most")
    total_xp_in_strand: int = Field(...,
                                    description="Their XP in that specific strand")
    recommendations: list[CareerPath]
