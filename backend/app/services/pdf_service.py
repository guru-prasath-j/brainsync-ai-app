import pdfplumber
import re
from typing import List


class PDFService:
    """Service for extracting and processing text from PDF files."""

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
        """Clean extracted text: normalize whitespace, remove junk characters."""
        # Replace multiple newlines with double newline
        text = re.sub(r"\n{3,}", "\n\n", text)
        # Replace multiple spaces/tabs with single space
        text = re.sub(r"[ \t]+", " ", text)
        # Strip leading/trailing whitespace per line
        lines = [line.strip() for line in text.split("\n")]
        # Remove lines that are just numbers (page numbers)
        lines = [line for line in lines if not re.match(r"^\d+$", line)]
        return "\n".join(lines).strip()

    def chunk_text(
        self, text: str, chunk_size: int = 500, overlap: int = 50
    ) -> List[str]:
        """
        Split text into overlapping chunks by word count.

        Args:
            text: cleaned text to chunk
            chunk_size: number of words per chunk
            overlap: number of words to overlap between consecutive chunks

        Returns:
            List of text chunk strings
        """
        words = text.split()
        if not words:
            return []

        chunks = []
        start = 0
        while start < len(words):
            end = start + chunk_size
            chunk = " ".join(words[start:end])
            chunks.append(chunk)
            if end >= len(words):
                break
            start += chunk_size - overlap

        return chunks


pdf_service = PDFService()
