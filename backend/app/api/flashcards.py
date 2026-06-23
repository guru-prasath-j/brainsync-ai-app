from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.note import Note
from app.models.flashcard import Flashcard
from app.services.ai_service import generate_flashcards

router = APIRouter()


class FlashcardOut(BaseModel):
    id: int
    question: str
    answer: str
    known: Optional[bool]

    class Config:
        from_attributes = True


class RateRequest(BaseModel):
    known: bool


@router.post("/{note_id}/generate", response_model=list[FlashcardOut])
async def generate(
    note_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    # Delete existing flashcards for this note before regenerating
    db.query(Flashcard).filter(
        Flashcard.note_id == note_id,
        Flashcard.user_id == current_user.id,
    ).delete()
    db.flush()

    # Read note text from file
    try:
        with open(note.file_path, "rb") as f:
            raw = f.read()
        # Try to extract text (PDF or plain text)
        try:
            import pdfplumber, io
            with pdfplumber.open(io.BytesIO(raw)) as pdf:
                text = "\n".join(p.extract_text() or "" for p in pdf.pages)
        except Exception:
            text = raw.decode("utf-8", errors="ignore")
    except Exception:
        raise HTTPException(status_code=422, detail="Could not read note file")

    if not text.strip():
        raise HTTPException(status_code=422, detail="Note has no readable text content")

    pairs = await generate_flashcards(text)
    if not pairs:
        raise HTTPException(status_code=500, detail="AI returned no flashcards")

    cards = []
    for pair in pairs:
        card = Flashcard(
            note_id=note_id,
            user_id=current_user.id,
            question=pair.get("question", ""),
            answer=pair.get("answer", ""),
        )
        db.add(card)
        cards.append(card)

    db.commit()
    for c in cards:
        db.refresh(c)

    return cards


@router.get("/{note_id}", response_model=list[FlashcardOut])
def list_flashcards(
    note_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    note = db.query(Note).filter(Note.id == note_id, Note.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return db.query(Flashcard).filter(
        Flashcard.note_id == note_id,
        Flashcard.user_id == current_user.id,
    ).all()


@router.patch("/{flashcard_id}/rate", response_model=FlashcardOut)
def rate_flashcard(
    flashcard_id: int,
    body: RateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    card = db.query(Flashcard).filter(
        Flashcard.id == flashcard_id,
        Flashcard.user_id == current_user.id,
    ).first()
    if not card:
        raise HTTPException(status_code=404, detail="Flashcard not found")
    card.known = body.known
    db.commit()
    db.refresh(card)
    return card
