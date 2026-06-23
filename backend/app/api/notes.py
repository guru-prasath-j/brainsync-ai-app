import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.note import Note
from app.models.user import User
from app.schemas.note import NoteResponse

router = APIRouter()


def save_upload_file(file_content: bytes, filename: str, user_id: int) -> tuple[str, int]:
    """Save uploaded file to disk, return (file_path, file_size)."""
    upload_dir = os.path.join("uploads", str(user_id))
    os.makedirs(upload_dir, exist_ok=True)
    unique_name = f"{uuid.uuid4()}_{filename}"
    file_path = os.path.join(upload_dir, unique_name)
    with open(file_path, "wb") as f:
        f.write(file_content)
    return os.path.abspath(file_path), len(file_content)


@router.post("/upload", response_model=NoteResponse, status_code=201)
async def upload_note(
    background_tasks: BackgroundTasks,
    title: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upload a PDF or text file and queue it for processing."""
    allowed_types = {"application/pdf", "text/plain", "text/markdown", "application/octet-stream"}
    if file.content_type not in allowed_types and not (file.filename or '').endswith(('.pdf', '.txt', '.md')):
        raise HTTPException(status_code=400, detail="Only PDF and plain text files are supported")

    content = await file.read()
    file_path, file_size = save_upload_file(content, file.filename, current_user.id)

    note = Note(
        user_id=current_user.id,
        title=title,
        file_name=file.filename,
        file_size=file_size,
        file_path=file_path,
        status="uploaded",
    )
    db.add(note)
    db.commit()
    db.refresh(note)

    # Queue background processing
    from app.tasks.process_note import process_note
    background_tasks.add_task(process_note, note.id, db)

    return note


@router.get("/", response_model=List[NoteResponse])
def list_notes(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List all notes for the current user, newest first."""
    notes = (
        db.query(Note)
        .filter(Note.user_id == current_user.id)
        .order_by(Note.created_at.desc())
        .all()
    )
    return notes


@router.get("/{note_id}", response_model=NoteResponse)
def get_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a single note by ID. Returns 404 if not found or not owned by user."""
    note = (
        db.query(Note)
        .filter(Note.id == note_id, Note.user_id == current_user.id)
        .first()
    )
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.delete("/{note_id}", status_code=204)
def delete_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a note, its file, and all related sessions."""
    note = (
        db.query(Note)
        .filter(Note.id == note_id, Note.user_id == current_user.id)
        .first()
    )
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    # Delete related quiz sessions (and their questions via cascade)
    from app.models.quiz import QuizSession, QuizQuestion
    quiz_sessions = db.query(QuizSession).filter(QuizSession.note_id == note_id).all()
    for qs in quiz_sessions:
        db.query(QuizQuestion).filter(QuizQuestion.session_id == qs.id).delete()
        db.delete(qs)

    # Delete related chat sessions (and their messages via cascade)
    from app.models.chat import ChatSession, ChatMessage
    chat_sessions = db.query(ChatSession).filter(ChatSession.note_id == note_id).all()
    for cs in chat_sessions:
        db.query(ChatMessage).filter(ChatMessage.session_id == cs.id).delete()
        db.delete(cs)

    # Delete flashcards
    from app.models.flashcard import Flashcard
    db.query(Flashcard).filter(Flashcard.note_id == note_id).delete()

    db.flush()

    # Remove file from disk
    if note.file_path:
        try:
            os.remove(note.file_path)
        except OSError:
            pass

    db.delete(note)
    db.commit()
