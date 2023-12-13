from app.api.api_v1.endpoints import missions
from fastapi import APIRouter

api_router = APIRouter()

api_router.include_router(missions.router, prefix="/missions", tags=["missions"])
