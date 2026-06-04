from datetime import datetime
from pydantic import BaseModel


class SummaryResponse(BaseModel):
    note_id: int
    tldr: str
    key_points: list[str]
    concepts: list[str]
    generated_at: datetime

    class Config:
        from_attributes = True
