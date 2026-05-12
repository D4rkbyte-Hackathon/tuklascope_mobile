from enum import Enum
from pydantic import BaseModel, Field


class PathwayStatus(str, Enum):
    AVAILABLE = "available"
    ACTIVE = "active"
    COMPLETED = "completed"
    ABANDONED = "abandoned"


class PathwayDifficulty(str, Enum):
    BEGINNER = "Beginner"
    INTERMEDIATE = "Intermediate"
    ADVANCED = "Advanced"


class PathwayStrand(str, Enum):
    STEM = "STEM"
    HUMSS = "HUMSS"
    ABM = "ABM"
    TVL = "TVL"
    GENERAL = "GENERAL"


class PathwayTaskSchema(BaseModel):
    id: str
    description: str = Field(description="The visible task instruction for the user")
    is_completed: bool = Field(default=False)


class PathwaySchema(BaseModel):
    id: str
    title: str
    description: str
    image_url: str
    difficulty: PathwayDifficulty
    total_points: int
    target_strand: PathwayStrand
    status: PathwayStatus = Field(description="User's current status for this pathway")
    progress_percentage: int = Field(default=0)
    tasks: list[PathwayTaskSchema] = []


class PathwayCatalogResponse(BaseModel):
    active_pathways_count: int
    average_progress: float
    total_points_earned: int
    pathways: list[PathwaySchema]
