import os
from typing import List, Dict, Any
import chromadb
from chromadb.config import Settings


class VectorStoreService:
    """Service for storing and retrieving text chunks using ChromaDB."""

    def __init__(self):
        persist_dir = os.environ.get("CHROMA_PERSIST_DIR", "./chroma_data")
        self.client = chromadb.PersistentClient(
            path=persist_dir,
            settings=Settings(anonymized_telemetry=False),
        )

    def get_or_create_collection(self, collection_name: str):
        """Get an existing collection or create one if it doesn't exist."""
        return self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"},
        )

    def add_chunks(
        self,
        collection_name: str,
        chunks: List[str],
        metadata: List[Dict[str, Any]],
        ids: List[str],
    ) -> None:
        """
        Add text chunks to a collection.

        Args:
            collection_name: Name of the ChromaDB collection
            chunks: List of text strings to embed and store
            metadata: List of metadata dicts (one per chunk)
            ids: Unique string IDs for each chunk
        """
        collection = self.get_or_create_collection(collection_name)
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
        where: Dict[str, Any] = None,
    ) -> Dict[str, Any]:
        """
        Search for similar chunks in a collection.

        Args:
            collection_name: Name of the ChromaDB collection
            query: Query text to search against
            n_results: Number of results to return
            where: Optional metadata filter dict

        Returns:
            Dict with 'documents', 'metadatas', 'distances', and 'ids' keys
        """
        collection = self.get_or_create_collection(collection_name)
        kwargs: Dict[str, Any] = {
            "query_texts": [query],
            "n_results": n_results,
            "include": ["documents", "metadatas", "distances"],
        }
        if where:
            kwargs["where"] = where

        results = collection.query(**kwargs)
        return {
            "documents": results["documents"][0] if results["documents"] else [],
            "metadatas": results["metadatas"][0] if results["metadatas"] else [],
            "distances": results["distances"][0] if results["distances"] else [],
            "ids": results["ids"][0] if results["ids"] else [],
        }

    def delete_collection(self, collection_name: str) -> None:
        """Delete a collection entirely."""
        self.client.delete_collection(name=collection_name)

    def delete_chunks_by_note(self, collection_name: str, note_id: int) -> None:
        """Remove all chunks associated with a specific note_id."""
        collection = self.get_or_create_collection(collection_name)
        collection.delete(where={"note_id": note_id})


vector_store_service = VectorStoreService()
