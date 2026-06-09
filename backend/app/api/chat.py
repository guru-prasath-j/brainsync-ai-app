"""Chat API endpoints."""
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.auth import get_current_user
from app.core.database import get_db
from app.models.chat import ChatMessage, ChatSession
from app.models.user import User
from app.services.rag_service import RAGService

router = APIRouter()
rag_service = RAGService()


# ---------- Schemas ----------


class SessionCreate(BaseModel):
    note_id: Optional[int] = None
    title: str = "New Chat"


class SessionResponse(BaseModel):
    id: int
    note_id: Optional[int]
    title: str
    created_at: str

    class Config:
        from_attributes = True


class MessageCreate(BaseModel):
    content: str


class MessageResponse(BaseModel):
    id: int
    role: str
    content: str
    created_at: str

    class Config:
        from_attributes = True


# ---------- Session Endpoints ----------


@router.post("/sessions", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    body: SessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new chat session."""
    session = ChatSession(
        user_id=current_user.id,
        note_id=body.note_id,
        title=body.title,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return _session_to_response(session)


@router.get("/sessions", response_model=List[SessionResponse])
async def list_sessions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List all chat sessions for the current user."""
    sessions = (
        db.query(ChatSession)
        .filter(ChatSession.user_id == current_user.id)
        .order_by(ChatSession.updated_at.desc())
        .all()
    )
    return [_session_to_response(s) for s in sessions]


@router.delete("/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a chat session and all its messages."""
    session = _get_session_or_404(session_id, current_user.id, db)
    db.delete(session)
    db.commit()


# ---------- Message Endpoints ----------


@router.get("/sessions/{session_id}/messages", response_model=List[MessageResponse])
async def get_messages(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all messages in a session."""
    session = _get_session_or_404(session_id, current_user.id, db)
    messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.session_id == session.id)
        .order_by(ChatMessage.created_at.asc())
        .all()
    )
    return [_msg_to_response(m) for m in messages]


@router.post(
    "/sessions/{session_id}/messages",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
)
async def send_message(
    session_id: int,
    body: MessageCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send a message and receive an AI response."""
    session = _get_session_or_404(session_id, current_user.id, db)

    # Persist user message
    user_msg = ChatMessage(
        session_id=session.id,
        role="user",
        content=body.content,
    )
    db.add(user_msg)
    db.commit()

    # Generate AI response
    ai_text = await rag_service.chat(
        user_id=current_user.id,
        session_id=session.id,
        message=body.content,
        note_id=session.note_id,
        db=db,
    )

    # Persist AI message
    ai_msg = ChatMessage(
        session_id=session.id,
        role="assistant",
        content=ai_text,
    )
    db.add(ai_msg)
    db.commit()
    db.refresh(ai_msg)

    return _msg_to_response(ai_msg)


# ---------- Helpers ----------


def _get_session_or_404(session_id: int, user_id: int, db: Session) -> ChatSession:
    session = (
        db.query(ChatSession)
        .filter(ChatSession.id == session_id, ChatSession.user_id == user_id)
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Chat session not found")
    return session


def _session_to_response(s: ChatSession) -> dict:
    return {
        "id": s.id,
        "note_id": s.note_id,
        "title": s.title,
        "created_at": s.created_at.isoformat(),
    }


def _msg_to_response(m: ChatMessage) -> dict:
    return {
        "id": m.id,
        "role": m.role,
        "content": m.content,
        "created_at": m.created_at.isoformat(),
    }
