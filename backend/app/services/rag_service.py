"""RAG (Retrieval-Augmented Generation) service using ChromaDB + GPT-4."""
from typing import List, Optional
import logging

from openai import AsyncOpenAI
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.chat import ChatMessage, ChatSession
from app.services.vector_store import VectorStoreService

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are BrainSync AI, an intelligent study assistant. 
You help students understand their study materials by answering questions 
based on the context retrieved from their uploaded notes.

When answering:
- Be concise but thorough
- Reference specific parts of the source material when relevant
- If the context does not contain enough information, say so clearly
- Use bullet points or numbered lists for complex explanations
- Encourage deeper understanding, not just memorization
"""


class RAGService:
    """Retrieval-Augmented Generation service for chat."""

    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.vector_store = VectorStoreService()

    async def chat(
        self,
        user_id: int,
        session_id: int,
        message: str,
        note_id: Optional[int],
        db: Session,
    ) -> str:
        """Process a chat message using RAG and return AI response."""
        context = ""
        if note_id:
            context = self._retrieve_context(user_id, note_id, message)

        history = self._get_history(session_id, db, limit=10)

        messages = [{"role": "system", "content": SYSTEM_PROMPT}]

        if context:
            messages.append(
                {
                    "role": "system",
                    "content": f"Relevant context from study materials:\n\n{context}",
                }
            )

        for msg in history:
            messages.append({"role": msg.role, "content": msg.content})

        messages.append({"role": "user", "content": message})

        response = await self.client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            max_tokens=1024,
            temperature=0.7,
        )

        return response.choices[0].message.content

    def _retrieve_context(self, user_id: int, note_id: int, query: str) -> str:
        """Retrieve relevant context chunks from ChromaDB."""
        try:
            collection_name = f"user_{user_id}_note_{note_id}"
            results = self.vector_store.search(
                collection_name=collection_name,
                query=query,
                n_results=4,
            )
            if not results:
                return ""
            return "\n\n---\n\n".join(results)
        except Exception as e:
            logger.warning(f"Context retrieval failed: {e}")
            return ""

    def _get_history(
        self, session_id: int, db: Session, limit: int = 10
    ) -> List[ChatMessage]:
        """Fetch recent chat history for a session."""
        return (
            db.query(ChatMessage)
            .filter(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.desc())
            .limit(limit)
            .all()[::-1]
        )
