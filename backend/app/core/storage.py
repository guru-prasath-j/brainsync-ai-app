import os
import uuid
from fastapi import UploadFile


UPLOAD_BASE_DIR = "uploads"


async def save_upload_file(file: UploadFile, user_id: int) -> str:
    """Save uploaded file to disk with a UUID prefix to avoid collisions.

    Args:
        file: The uploaded file object.
        user_id: The ID of the user uploading the file.

    Returns:
        The absolute path to the saved file.
    """
    user_dir = os.path.join(UPLOAD_BASE_DIR, str(user_id))
    os.makedirs(user_dir, exist_ok=True)

    file_ext = os.path.splitext(file.filename or "")[1]
    unique_filename = f"{uuid.uuid4().hex}{file_ext}"
    file_path = os.path.join(user_dir, unique_filename)

    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    return os.path.abspath(file_path)


def delete_file(file_path: str) -> bool:
    """Delete a file from disk.

    Args:
        file_path: Absolute path to the file.

    Returns:
        True if deleted successfully, False otherwise.
    """
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            return True
    except OSError:
        pass
    return False


def get_file_size(file_path: str) -> int:
    """Return file size in bytes, or 0 if file doesn't exist."""
    try:
        return os.path.getsize(file_path)
    except OSError:
        return 0
