from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.storage import save_upload_file
from app.models.note import Note
from app.models.user import User
from app.schemas.note import NoteResponse
from app.tasks.process_note import process_note

router = APIRouter()


@router.post("/upload", response_model=NoteResponse, status_code=201)
async def upload_note(
    background_tasks: BackgroundTasks,
    title: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upload a PDF/text file and queue it for processing."""
    allowed_types = {
        "application/pdf",
        "text/plain",
        "application/octet-stream",
    }
    if file.content_type not in allowed_types and not file.filename.endswith((".pdf", ".txt")):
        raise HTTPException(status_code=400, detail="Only PDF and text files are supported.")

    file_path = await save_upload_file(file, current_user.id)

    # Read file size after save
    import os
    file_size = os.path.getsize(file_path)

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
    background_tasks.add_task(process_note, note.id)

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
    """Get a single note by ID (must belong to current user)."""
    note = (
        db.query(Note)
        .filter(Note.id == note_id, Note.user_id == current_user.id)
        .first()
    )
    if not note:
        raise HTTPException(status_code=404, detail="Note not found.")
    return note
