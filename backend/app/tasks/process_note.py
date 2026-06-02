import uuid
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.models.note import Note
from app.services.pdf_service import pdf_service
from app.services.vector_store import vector_store_service

COLLECTION_NAME = "brainsync_notes"


async def process_note(note_id: int, db: Session = None) -> None:
    """
    Background task: extract text from an uploaded note file,
    chunk it, embed it into ChromaDB, and update the note status.

    Args:
        note_id: Primary key of the Note record to process
        db: Optional SQLAlchemy session; creates its own if not provided
    """
    close_db = False
    if db is None:
        db = SessionLocal()
        close_db = True

    try:
        note = db.query(Note).filter(Note.id == note_id).first()
        if not note:
            return

        # Mark as processing
        note.status = "processing"
        db.commit()

        # 1. Extract text
        raw_text = pdf_service.extract_text(note.file_path)

        # 2. Clean text
        clean = pdf_service.clean_text(raw_text)

        # 3. Chunk text
        chunks = pdf_service.chunk_text(clean, chunk_size=500, overlap=50)

        if chunks:
            # 4. Build metadata and IDs
            metadatas = [
                {
                    "note_id": note_id,
                    "user_id": note.user_id,
                    "chunk_index": i,
                    "title": note.title,
                }
                for i, _ in enumerate(chunks)
            ]
            ids = [f"note_{note_id}_chunk_{i}_{uuid.uuid4().hex[:8]}" for i in range(len(chunks))]

            # 5. Remove stale chunks for this note (re-processing scenario)
            vector_store_service.delete_chunks_by_note(COLLECTION_NAME, note_id)

            # 6. Store in ChromaDB
            vector_store_service.add_chunks(
                collection_name=COLLECTION_NAME,
                chunks=chunks,
                metadata=metadatas,
                ids=ids,
            )

        # 7. Mark as processed
        note.status = "processed"
        db.commit()

    except Exception as exc:
        # Mark as failed and re-raise so caller can log
        try:
            if note:
                note.status = "failed"
                db.commit()
        except Exception:
            pass
        raise exc

    finally:
        if close_db:
            db.close()
