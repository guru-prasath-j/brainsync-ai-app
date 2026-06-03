import os
from typing import List, Dict, Any, Optional
import chromadb
from chromadb.config import Settings


class VectorStoreService:
    """Service for storing and querying text embeddings using ChromaDB."""

    def __init__(self):
        persist_dir = os.environ.get("CHROMA_PERSIST_DIR", "./chroma_data")
        self.client = chromadb.PersistentClient(
            path=persist_dir,
            settings=Settings(anonymized_telemetry=False),
        )

    def get_or_create_collection(self, collection_name: str) -> chromadb.Collection:
        """Get existing collection or create a new one."""
        return self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"},
        )

    def add_chunks(
        self,
        collection_name: str,
        chunks: List[str],
        metadata: Optional[List[Dict[str, Any]]] = None,
        ids: Optional[List[str]] = None,
    ) -> None:
        """Add text chunks with optional metadata to a collection."""
        collection = self.get_or_create_collection(collection_name)

        if ids is None:
            ids = [f"{collection_name}_chunk_{i}" for i in range(len(chunks))]

        if metadata is None:
            metadata = [{"chunk_index": i} for i in range(len(chunks))]

        # ChromaDB handles embedding automatically with default embedding function
        collection.add(
            documents=chunks,
            metadatas=metadata,
            ids=ids,
        )

    def search(
        self,
        collection_name: str,
        query: str,
        n_results: int = 5,
    ) -> Dict[str, Any]:
        """Search for similar chunks and return documents with distances."""
        collection = self.get_or_create_collection(collection_name)
        results = collection.query(
            query_texts=[query],
            n_results=n_results,
            include=["documents", "metadatas", "distances"],
        )
        return {
            "documents": results["documents"][0] if results["documents"] else [],
            "metadatas": results["metadatas"][0] if results["metadatas"] else [],
            "distances": results["distances"][0] if results["distances"] else [],
        }

    def delete_collection(self, collection_name: str) -> None:
        """Delete a collection by name."""
        try:
            self.client.delete_collection(collection_name)
        except Exception:
            pass

    def collection_exists(self, collection_name: str) -> bool:
        """Check if a collection exists."""
        try:
            self.client.get_collection(collection_name)
            return True
        except Exception:
            return False
