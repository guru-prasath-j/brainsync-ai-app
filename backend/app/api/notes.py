"""Notes API router for file uploads and management."""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, BackgroundTasks
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.storage import save_upload_file
from app.models.note import Note
from app.models.user import User
from app.schemas.note import NoteCreate, NoteResponse
from app.tasks.process_note import process_note

router = APIRouter()


@router.post("/upload", response_model=NoteResponse)
async def upload_note(
    file: UploadFile = File(...),
    title: str = Form(...),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upload a PDF or text file and create a note."""
    # Validate file type
    allowed_types = {"application/pdf", "text/plain", "text/markdown"}
    if file.content_type not in allowed_types:
        raise HTTPException(status_code=400, detail="File type not supported")

    # Save file
    file_path = await save_upload_file(file, current_user.id)
    file_size = file.size or 0

    # Create note record in database
    note = Note(
        user_id=current_user.id,
        title=title,
        file_name=file.filename,
        file_size=file_size,
        file_path=file_path,
        status="uploaded",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    db.add(note)
    db.commit()
    db.refresh(note)

    # Queue background task to process file
    background_tasks.add_task(process_note, note.id, db)

    return NoteResponse.from_orm(note)


@router.get("/", response_model=List[NoteResponse])
def list_notes(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List all notes for the current user (newest first)."""
    notes = (
        db.query(Note)
        .filter(Note.user_id == current_user.id)
        .order_by(Note.created_at.desc())
        .all()
    )
    return [NoteResponse.from_orm(note) for note in notes]


@router.get("/{note_id}", response_model=NoteResponse)
def get_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a single note by ID."""
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if note.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    return NoteResponse.from_orm(note)
