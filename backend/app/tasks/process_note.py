"""Background task for processing uploaded notes."""
from sqlalchemy.orm import Session

from app.models.note import Note
from app.core.database import SessionLocal


async def process_note(note_id: int, db: Session) -> None:
    """
    Background task to process a note after upload.

    This is a stub that will be expanded in Day 7-8
    to include PDF parsing, text extraction, and chunking.
    """
    # Get fresh DB session for background task
    db = SessionLocal()

    try:
        note = db.query(Note).filter(Note.id == note_id).first()
        if not note:
            return

        # Update status to processing
        note.status = "processing"
        db.commit()

        # TODO: In Day 7-8, implement:
        # - Extract text from PDF/file
        # - Chunk text
        # - Store in ChromaDB vector store
        # - Update status to "processed"

        # For now, mark as processed immediately
        note.status = "processed"
        db.commit()

    except Exception as e:
        # Mark as failed if there's an error
        note = db.query(Note).filter(Note.id == note_id).first()
        if note:
            note.status = "failed"
            db.commit()
        raise e
    finally:
        db.close()
