import pdfplumber
import re
from typing import List


class PDFService:
    """Service for extracting and chunking text from PDF files."""

    def extract_text(self, file_path: str) -> str:
        """Extract raw text from a PDF file using pdfplumber."""
        text_parts = []
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text_parts.append(page_text)
        return "\n".join(text_parts)

    def clean_text(self, text: str) -> str:
        """Clean extracted text by removing extra whitespace and artifacts."""
        # Remove multiple spaces
        text = re.sub(r' +', ' ', text)
        # Remove multiple newlines
        text = re.sub(r'\n{3,}', '\n\n', text)
        # Remove non-printable characters except newlines and tabs
        text = re.sub(r'[^\x09\x0A\x0D\x20-\x7E]', '', text)
        return text.strip()

    def chunk_text(
        self,
        text: str,
        chunk_size: int = 500,
        overlap: int = 50,
    ) -> List[str]:
        """Split text into overlapping chunks of approximately chunk_size words."""
        words = text.split()
        if not words:
            return []

        chunks = []
        start = 0
        while start < len(words):
            end = min(start + chunk_size, len(words))
            chunk = " ".join(words[start:end])
            chunks.append(chunk)
            if end == len(words):
                break
            start += chunk_size - overlap

        return chunks
