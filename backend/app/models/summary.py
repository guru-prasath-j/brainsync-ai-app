"""
Summary database model.
"""
from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class Summary(Base):
    """Stores AI-generated summaries for notes."""

    __tablename__ = "summaries"

    id = Column(Integer, primary_key=True, index=True)
    note_id = Column(Integer, ForeignKey("notes.id", ondelete="CASCADE"), nullable=False, unique=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Summary content
    tldr = Column(Text, nullable=True)
    key_points = Column(JSON, nullable=True)  # List[str]
    concepts = Column(JSON, nullable=True)    # List[str]

    # Generation metadata
    model_used = Column(String(50), default="gpt-4o-mini")
    generated_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    note = relationship("Note", back_populates="summary")
    user = relationship("User")
