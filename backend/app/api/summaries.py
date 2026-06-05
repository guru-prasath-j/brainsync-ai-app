"""
Summaries API — generate and retrieve AI summaries for notes.
"""
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.auth import get_current_user
from app.core.database import get_db
from app.models.note import Note
from app.models.summary import Summary
from app.models.user import User
from app.schemas.summary import SummaryGenerateRequest, SummaryResponse
from app.services.ai_service import ai_service

router = APIRouter()


def _get_note_for_user(note_id: int, user: User, db: Session) -> Note:
    """Fetch a note belonging to the current user or raise 404."""
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == user.id).first()
    if not note:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Note not found")
    return note


async def _do_generate(note_id: int, user_id: int, db: Session) -> Summary:
    """Core generation logic — called directly or via background task."""
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == user_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    # Read note text from file if available, else use title as placeholder
    text = note.title  # fallback
    try:
        if note.file_path:
            with open(note.file_path, "r", errors="replace") as f:
                text = f.read()
    except (OSError, AttributeError):
        pass

    result = await ai_service.summarize(text)

    # Upsert summary
    summary = db.query(Summary).filter(Summary.note_id == note_id).first()
    if summary:
        summary.tldr = result["tldr"]
        summary.key_points = result["key_points"]
        summary.concepts = result["concepts"]
    else:
        summary = Summary(
            note_id=note_id,
            user_id=user_id,
            tldr=result["tldr"],
            key_points=result["key_points"],
            concepts=result["concepts"],
        )
        db.add(summary)

    db.commit()
    db.refresh(summary)
    return summary


@router.get("/{note_id}", response_model=SummaryResponse)
async def get_summary(
    note_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve existing summary for a note."""
    _get_note_for_user(note_id, current_user, db)

    summary = db.query(Summary).filter(Summary.note_id == note_id).first()
    if not summary:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No summary found. Call POST /summaries/{note_id}/generate first.",
        )
    return summary


@router.post("/{note_id}/generate", response_model=SummaryResponse, status_code=status.HTTP_201_CREATED)
async def generate_summary(
    note_id: int,
    request: SummaryGenerateRequest = SummaryGenerateRequest(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate (or regenerate) an AI summary for a note."""
    _get_note_for_user(note_id, current_user, db)
    summary = await _do_generate(note_id, current_user.id, db)
    return summary
