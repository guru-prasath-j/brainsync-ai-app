"""Pydantic schemas for Note API."""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class NoteCreate(BaseModel):
    """Schema for creating a note."""

    title: str
    file_name: str
    file_size: int

    class Config:
        from_attributes = True


class NoteResponse(BaseModel):
    """Schema for note API responses."""

    id: int
    title: str
    file_name: str
    file_size: int
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
