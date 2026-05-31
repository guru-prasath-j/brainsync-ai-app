"""File storage utilities for uploaded notes."""
import os
import uuid
from fastapi import UploadFile


async def save_upload_file(file: UploadFile, user_id: int) -> str:
    """
    Save an uploaded file to disk with a unique name.

    Returns the absolute file path.
    """
    # Create uploads directory structure
    uploads_dir = f"uploads/{user_id}"
    os.makedirs(uploads_dir, exist_ok=True)

    # Generate unique filename with uuid prefix
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(uploads_dir, unique_filename)

    # Save file
    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    return os.path.abspath(file_path)
