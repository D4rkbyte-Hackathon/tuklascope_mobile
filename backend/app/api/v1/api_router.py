from fastapi import APIRouter
from app.api.v1.endpoints import discover

api_router = APIRouter()
api_router.include_router(
    discover.router, prefix="/discover", tags=["Discovery"])
