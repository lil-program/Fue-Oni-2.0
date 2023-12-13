from pydantic import BaseModel


class Mission(BaseModel):
    name: str
    description: str
