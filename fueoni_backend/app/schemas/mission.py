from enum import Enum
from typing import Dict

from pydantic import BaseModel, Field


class Difficulty(str, Enum):
    easy = "easy"
    normal = "normal"
    hard = "hard"


class Mission(BaseModel):
    title: str
    description: str
    answer: str
    type: str
    difficulty: Difficulty
    time_limit: int


class PagingInfo(BaseModel):
    current_page: int = Field(..., description="Current page number")
    total_pages: int = Field(..., description="Total number of pages")


class MissionsResponse(BaseModel):
    missions: Dict[str, Mission]
    paging_info: PagingInfo
    next_page_token: str = Field(None, description="Token for the next page of results")


class AllMissionsResponse(BaseModel):
    missions: Dict[str, Mission]
