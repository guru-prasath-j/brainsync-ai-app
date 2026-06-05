"""
Pydantic schemas for Summary endpoints.
"""
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class SummaryBase(BaseModel):
    tldr: Optional[str] = None
    key_points: Optional[List[str]] = []
    concepts: Optional[List[str]] = []


class SummaryResponse(SummaryBase):
    id: int
    note_id: int
    model_used: str
    generated_at: datetime

    class Config:
        from_attributes = True


class SummaryGenerateRequest(BaseModel):
    """Optional request body — future use (e.g. custom instructions)."""
    extra_instructions: Optional[str] = None
