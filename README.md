# BrainSync AI — Intelligent Study Companion

> A full-stack AI-powered study app that transforms your PDFs and notes into summaries, flashcards, quizzes, and a RAG-powered chat interface.

**Flutter** · **FastAPI** · **PostgreSQL** · **OpenAI GPT-4** · **ChromaDB** · **JWT Auth**

## Features

- 📄 **PDF Upload & Parsing** — upload study material, extract and chunk text automatically
- 🧠 **AI Summarization** — GPT-4o-mini generates TL;DR, key points, and core concepts
- 🃏 **Flashcard Generation** — AI creates question/answer cards with difficulty ratings
- ❓ **Quiz Engine** — MCQ quizzes with explanations, scoring, and history
- 💬 **RAG Chat** — ask questions about your notes; answers grounded in your own documents via ChromaDB retrieval
- 📊 **Progress Dashboard** — study streaks, activity chart, session stats

## Architecture

```
Flutter App (Dart)
       ↕ HTTP / Dio
FastAPI Backend (Python)
       ↕
  ┌────────────────────────────────┐
  │  PostgreSQL (users, notes,     │
  │  flashcards, quizzes, chats)   │
  └────────────────────────────────┘
       ↕
  ChromaDB Vector Store
  (document chunks + embeddings)
       ↕
  OpenAI GPT-4 / GPT-4o-mini
  (summarize, generate, chat)
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter 3 (Dart) |
| Backend API | FastAPI + Python 3.11 |
| Database | PostgreSQL + SQLAlchemy + Alembic |
| Vector Store | ChromaDB |
| AI Models | OpenAI GPT-4, GPT-4o-mini |
| Auth | JWT (python-jose) + bcrypt |
| File Storage | Local filesystem (uploads/) |
| CI | GitHub Actions |

## Getting Started

### Backend

```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # add DATABASE_URL and OPENAI_API_KEY
alembic upgrade head
make run
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## Project Structure

```
brainsync-ai-app/
├── backend/
│   ├── app/
│   │   ├── api/          # FastAPI routers (auth, users, notes, summaries, flashcards, quiz, chat)
│   │   ├── core/         # DB, config, security, storage
│   │   ├── models/       # SQLAlchemy ORM models
│   │   ├── schemas/      # Pydantic request/response schemas
│   │   ├── services/     # AI, PDF parsing, RAG, vector store
│   │   └── tasks/        # Background processing (note ingestion)
│   └── alembic/          # DB migrations
└── frontend/
    └── lib/
        ├── core/         # Router, theme, API client
        ├── models/       # Dart data models
        ├── screens/      # UI screens
        ├── services/     # API service layer
        └── widgets/      # Reusable components
```

## Related Projects

- [self-healing-rag-eval](https://github.com/guru-prasath-j/self-healing-rag-eval) — Production RAG pipeline with LangGraph + self-healing critic loop
- [pocketmind](https://github.com/guru-prasath-j/pocketmind) — On-device AI with local LLM on Flutter
