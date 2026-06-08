from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.note import Note
from app.models.quiz import QuizSession, QuizQuestion
from app.services.quiz_service import quiz_service

router = APIRouter()


# --- Schemas ---
class GenerateQuizRequest(BaseModel):
    note_id: int
    num_questions: int = 5
    difficulty: str = 'medium'


class QuestionResponse(BaseModel):
    id: int
    question_text: str
    options: list
    difficulty: str
    order_index: int
    selected_index: int | None = None
    is_correct: bool | None = None
    explanation: str | None = None

    class Config:
        from_attributes = True


class QuizSessionResponse(BaseModel):
    id: int
    note_id: int
    difficulty: str
    total_questions: int
    score: int
    completed: bool
    questions: List[QuestionResponse] = []

    class Config:
        from_attributes = True


class SubmitAnswerRequest(BaseModel):
    session_id: int
    question_id: int
    selected_index: int


class AnswerResult(BaseModel):
    is_correct: bool
    correct_index: int
    explanation: str | None
    session_score: int
    session_completed: bool


# --- Endpoints ---
@router.post('/generate', response_model=QuizSessionResponse, status_code=status.HTTP_201_CREATED)
async def generate_quiz(
    req: GenerateQuizRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate a quiz from a note."""
    note = db.query(Note).filter(Note.id == req.note_id, Note.user_id == current_user.id).first()
    if not note:
        raise HTTPException(status_code=404, detail='Note not found')
    if note.status != 'processed':
        raise HTTPException(status_code=400, detail='Note has not been processed yet')

    # Read file content for quiz generation
    try:
        with open(note.file_path, 'r', errors='ignore') as f:
            text = f.read()
    except Exception:
        raise HTTPException(status_code=500, detail='Could not read note file')

    raw_questions = await quiz_service.generate_quiz(
        text=text,
        num_questions=req.num_questions,
        difficulty=req.difficulty,
    )

    session = QuizSession(
        user_id=current_user.id,
        note_id=note.id,
        difficulty=req.difficulty,
        total_questions=len(raw_questions),
    )
    db.add(session)
    db.flush()

    for idx, q in enumerate(raw_questions):
        qq = QuizQuestion(
            session_id=session.id,
            question_text=q['question'],
            options=q['options'],
            correct_index=q['correct_index'],
            explanation=q.get('explanation', ''),
            difficulty=q.get('difficulty', req.difficulty),
            order_index=idx,
        )
        db.add(qq)

    db.commit()
    db.refresh(session)
    return session


@router.get('/{session_id}', response_model=QuizSessionResponse)
def get_quiz_session(
    session_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get a quiz session with questions."""
    session = db.query(QuizSession).filter(
        QuizSession.id == session_id,
        QuizSession.user_id == current_user.id,
    ).first()
    if not session:
        raise HTTPException(status_code=404, detail='Quiz session not found')
    return session


@router.post('/submit-answer', response_model=AnswerResult)
async def submit_answer(
    req: SubmitAnswerRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Submit an answer for a quiz question."""
    session = db.query(QuizSession).filter(
        QuizSession.id == req.session_id,
        QuizSession.user_id == current_user.id,
    ).first()
    if not session:
        raise HTTPException(status_code=404, detail='Session not found')
    if session.completed:
        raise HTTPException(status_code=400, detail='Quiz already completed')

    question = db.query(QuizQuestion).filter(
        QuizQuestion.id == req.question_id,
        QuizQuestion.session_id == req.session_id,
    ).first()
    if not question:
        raise HTTPException(status_code=404, detail='Question not found')

    result = await quiz_service.evaluate_answer(
        correct_index=question.correct_index,
        selected_index=req.selected_index,
        explanation=question.explanation or '',
    )

    question.selected_index = req.selected_index
    question.is_correct = result['is_correct']
    if result['is_correct']:
        session.score += 1

    # Check if all questions answered
    answered = db.query(QuizQuestion).filter(
        QuizQuestion.session_id == session.id,
        QuizQuestion.selected_index.isnot(None),
    ).count()
    if answered >= session.total_questions:
        session.completed = True

    db.commit()
    return AnswerResult(
        is_correct=result['is_correct'],
        correct_index=result['correct_index'],
        explanation=result['explanation'],
        session_score=session.score,
        session_completed=session.completed,
    )


@router.get('/', response_model=List[QuizSessionResponse])
def list_quiz_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List all quiz sessions for current user."""
    return db.query(QuizSession).filter(
        QuizSession.user_id == current_user.id,
    ).order_by(QuizSession.id.desc()).all()