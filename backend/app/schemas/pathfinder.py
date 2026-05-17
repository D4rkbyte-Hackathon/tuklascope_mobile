from pydantic import BaseModel, Field


class CareerPath(BaseModel):
    path_type: str = Field(
        ...,
        description="Must be one of: 'Master Specialist', 'Hybrid Architect', or 'Future Pioneer'",
    )
    title: str = Field(
        ...,
        description="The name of the college degree or career track (e.g., BS Food Technology)",
    )
    description: str = Field(
        ...,
        description="A short, inspiring explanation of why this fits their unique web of skills and objects.",
    )
    match_confidence: int = Field(
        ...,
        description="A percentage (0-100) indicating how well this matches their profile.",
    )


class PathfinderResponse(BaseModel):
    profile_summary: str = Field(
        ...,
        description="A one-sentence summary of the student's unique learning profile.",
    )
    recommendations: list[CareerPath] = Field(
        ..., description="Exactly 3 recommendations following the 3-Tiered strategy."
    )


# --- NEW: Define the structure of our rich JSON skill object ---
class SkillDetail(BaseModel):
    skill_name: str
    domains: list[str]
    strand: str
    level: int
    xp: int


class SkillWebResponse(BaseModel):
    xp_distribution: dict[str, int] = Field(
        default_factory=dict, description="Total XP per strand"
    )
    # Update to expect a list of dictionaries, not strings
    top_skills: list[SkillDetail] = Field(
        default_factory=list,
        description="List of specific mastered topics, their domains, and levels",
    )
