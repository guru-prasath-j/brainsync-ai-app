from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.note import Note
from app.models.user import User
from app.schemas.summary import SummaryResponse
from app.services.ai_service import AIService
from app.services.pdf_service import PDFService
from datetime import datetime

router = APIRouter()
ai_service = AIService()
pdf_service = PDFService()

# In-memory cache: {note_id: SummaryResponse} — replace with DB table in production
_summary_cache: dict[int, dict] = {}


@router.get("/{note_id}", response_model=SummaryResponse)
async def get_summary(
    note_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return cached summary for a note, or 404 if not yet generated."""
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    if note_id not in _summary_cache:
        raise HTTPException(status_code=404, detail="Summary not yet generated. POST to /generate first.")

    return _summary_cache[note_id]


@router.post("/{note_id}/generate", response_model=SummaryResponse)
async def generate_summary(
    note_id: int,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Trigger AI summarization for the given note."""
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    if note.status not in ("processed", "uploaded"):
        raise HTTPException(
            status_code=400,
            detail=f"Note is in status '{note.status}'. Cannot summarize yet.",
        )

    # Extract text synchronously (fast path); for large files use background task
    try:
        text = pdf_service.extract_text(note.file_path)
        text = pdf_service.clean_text(text)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Text extraction failed: {exc}")

    if not text.strip():
        raise HTTPException(status_code=422, detail="No text could be extracted from this file.")

    result = await ai_service.summarize(text)
    summary = {
        "note_id": note_id,
        "tldr": result.get("tldr", ""),
        "key_points": result.get("key_points", []),
        "concepts": result.get("concepts", []),
        "generated_at": datetime.utcnow(),
    }
    _summary_cache[note_id] = summary
    return summary
