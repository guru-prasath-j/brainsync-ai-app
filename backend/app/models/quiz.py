from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, JSON, DateTime, func
from sqlalchemy.orm import relationship
from app.core.database import Base


class QuizSession(Base):
    __tablename__ = 'quiz_sessions'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    note_id = Column(Integer, ForeignKey('notes.id'), nullable=False)
    difficulty = Column(String, default='medium')
    total_questions = Column(Integer, default=0)
    score = Column(Integer, default=0)
    completed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    questions = relationship('QuizQuestion', back_populates='session', cascade='all, delete-orphan')


class QuizQuestion(Base):
    __tablename__ = 'quiz_questions'

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey('quiz_sessions.id'), nullable=False)
    question_text = Column(String, nullable=False)
    options = Column(JSON, nullable=False)  # List of 4 option strings
    correct_index = Column(Integer, nullable=False)
    explanation = Column(String, nullable=True)
    difficulty = Column(String, default='medium')
    selected_index = Column(Integer, nullable=True)  # User's answer
    is_correct = Column(Boolean, nullable=True)
    order_index = Column(Integer, default=0)

    session = relationship('QuizSession', back_populates='questions')