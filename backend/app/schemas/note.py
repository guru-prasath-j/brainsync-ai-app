from datetime import datetime
from pydantic import BaseModel


class NoteCreate(BaseModel):
    title: str
    file_name: str
    file_size: int


class NoteResponse(BaseModel):
    id: int
    title: str
    file_name: str
    file_size: int
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
