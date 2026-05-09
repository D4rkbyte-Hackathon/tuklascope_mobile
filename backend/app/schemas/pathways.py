from pydantic import BaseModel, Field


class PathwayTaskSchema(BaseModel):
    id: str
    description: str = Field(description="The visible task instruction for the user")
    is_completed: bool = Field(default=False)


class PathwaySchema(BaseModel):
    id: str
    title: str
    description: str
    image_url: str
    difficulty: str
    total_points: int
    target_strand: str
    status: str = Field(description="'available', 'active', or 'completed'")
    progress_percentage: int = Field(default=0)
    tasks: list[PathwayTaskSchema] = []


class PathwayCatalogResponse(BaseModel):
    active_pathways_count: int
    average_progress: float
    total_points_earned: int
    pathways: list[PathwaySchema]
