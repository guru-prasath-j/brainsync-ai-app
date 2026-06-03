import logging
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.note import Note
from app.services.pdf_service import PDFService
from app.services.vector_store import VectorStoreService

logger = logging.getLogger(__name__)

pdf_service = PDFService()
vector_store = VectorStoreService()


async def process_note(note_id: int, db: Session) -> None:
    """
    Background task: extract text from uploaded file, chunk it,
    store in ChromaDB, and update note status.
    """
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        logger.error(f"Note {note_id} not found for processing")
        return

    try:
        # Update status to processing
        note.status = "processing"
        db.commit()

        # Extract text based on file type
        file_path = note.file_path
        file_name = note.file_name.lower()

        if file_name.endswith(".pdf"):
            raw_text = pdf_service.extract_text(file_path)
        else:
            # Plain text files
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                raw_text = f.read()

        # Clean and chunk
        clean = pdf_service.clean_text(raw_text)
        chunks = pdf_service.chunk_text(clean, chunk_size=500, overlap=50)

        if not chunks:
            logger.warning(f"No text extracted from note {note_id}")
            note.status = "failed"
            db.commit()
            return

        # Store in ChromaDB collection named by note id
        collection_name = f"note_{note_id}"
        metadata = [
            {"note_id": note_id, "user_id": note.user_id, "chunk_index": i}
            for i in range(len(chunks))
        ]
        vector_store.add_chunks(
            collection_name=collection_name,
            chunks=chunks,
            metadata=metadata,
        )

        # Mark as processed
        note.status = "processed"
        db.commit()
        logger.info(f"Note {note_id} processed: {len(chunks)} chunks stored")

    except Exception as e:
        logger.error(f"Error processing note {note_id}: {e}", exc_info=True)
        note.status = "failed"
        db.commit()
