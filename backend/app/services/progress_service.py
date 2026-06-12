from datetime import date, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.models.note import Note
from app.models.flashcard import Flashcard
from app.models.quiz import QuizSession
from app.models.chat import ChatMessage


class ProgressService:
    def __init__(self, db: Session):
        self.db = db

    def get_dashboard_stats(self, user_id: int) -> dict:
        today = date.today()
        week_ago = today - timedelta(days=6)

        # Notes stats
        total_notes = (
            self.db.query(Note)
            .filter(Note.user_id == user_id)
            .count()
        )
        processed_notes = (
            self.db.query(Note)
            .filter(Note.user_id == user_id, Note.status == "processed")
            .count()
        )

        # Flashcard stats
        total_flashcards = (
            self.db.query(Flashcard)
            .filter(Flashcard.user_id == user_id)
            .count()
        )

        # Quiz stats
        total_quizzes = (
            self.db.query(QuizSession)
            .filter(QuizSession.user_id == user_id)
            .count()
        )
        avg_score_row = (
            self.db.query(func.avg(QuizSession.score))
            .filter(QuizSession.user_id == user_id, QuizSession.completed.is_(True))
            .scalar()
        )
        avg_score = round(float(avg_score_row), 1) if avg_score_row else 0.0

        # Chat messages sent
        total_messages = (
            self.db.query(ChatMessage)
            .filter(ChatMessage.user_id == user_id, ChatMessage.role == "user")
            .count()
        )

        # Daily activity for last 7 days (notes uploaded per day)
        activity = []
        for i in range(6, -1, -1):
            day = today - timedelta(days=i)
            count = (
                self.db.query(Note)
                .filter(
                    Note.user_id == user_id,
                    func.date(Note.created_at) == day,
                )
                .count()
            )
            activity.append({"date": day.isoformat(), "count": count})

        # Streak: consecutive days with at least one note uploaded
        streak = self._calculate_streak(user_id, today)

        return {
            "total_notes": total_notes,
            "processed_notes": processed_notes,
            "total_flashcards": total_flashcards,
            "total_quizzes": total_quizzes,
            "avg_quiz_score": avg_score,
            "total_messages": total_messages,
            "streak_days": streak,
            "daily_activity": activity,
        }

    def _calculate_streak(self, user_id: int, today: date) -> int:
        streak = 0
        current_day = today
        while True:
            count = (
                self.db.query(Note)
                .filter(
                    Note.user_id == user_id,
                    func.date(Note.created_at) == current_day,
                )
                .count()
            )
            if count == 0:
                break
            streak += 1
            current_day -= timedelta(days=1)
        return streak
