# BrainSync AI — Full-Stack AI Study Companion

BrainSync AI turns your study notes and PDFs into interactive learning experiences powered by GPT-4 and ChromaDB RAG.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter (Dart) |
| Backend API | FastAPI (Python 3.11) |
| Database | PostgreSQL + SQLAlchemy |
| Migrations | Alembic |
| AI / LLM | OpenAI GPT-4o-mini |
| Vector Store | ChromaDB (RAG) |
| Auth | JWT (python-jose) |
| File Storage | Local filesystem (S3-ready) |
| CI | GitHub Actions |

---

## Project Structure

```
brainsync-ai-app/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/             # Route handlers
│   │   │   ├── auth.py
│   │   │   ├── users.py
│   │   │   ├── notes.py
│   │   │   ├── summaries.py
│   │   │   ├── flashcards.py
│   │   │   ├── quizzes.py
│   │   │   ├── chat.py
│   │   │   └── progress.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   ├── database.py
│   │   │   ├── security.py
│   │   │   ├── exceptions.py
│   │   │   └── middleware.py
│   │   ├── models/          # SQLAlchemy ORM models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── services/        # Business logic & AI services
│   │   └── tasks/           # Background tasks
│   ├── alembic/             # DB migrations
│   ├── alembic.ini
│   ├── requirements.txt
│   ├── Makefile
│   ├── pyproject.toml
│   └── .flake8
├── frontend/                # Flutter app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── router.dart
│   │   │   └── theme.dart
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── analysis_options.yaml
└── .github/workflows/ci.yml
```

---

## Backend Setup

### Prerequisites
- Python 3.11+
- PostgreSQL running locally (or via Docker)
- OpenAI API key

### Installation

```bash
cd backend
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Environment Variables

Create `backend/.env`:

```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/brainsync
SECRET_KEY=your-super-secret-jwt-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
OPENAI_API_KEY=sk-...
UPLOAD_DIR=uploads
```

### Database

```bash
make migrate          # run alembic upgrade head
```

### Run

```bash
make run              # uvicorn with hot-reload on :8000
```

Interactive docs: http://localhost:8000/docs

### Lint & Format

```bash
make lint             # flake8 + black --check
make format           # black . && isort .
make test             # pytest
```

---

## Frontend Setup

### Prerequisites
- Flutter SDK ≥ 3.19 (stable channel)

### Installation

```bash
cd frontend
flutter pub get
```

### Configuration

Edit `frontend/lib/core/config.dart` (or your API base URL constant) to point to your backend:

```dart
const String kBaseUrl = 'http://localhost:8000/api';
```

### Run

```bash
flutter run            # pick a device / simulator
```

### Analyze

```bash
flutter analyze
flutter test
```

---

## API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/auth/register | ✗ | Register new user |
| POST | /api/auth/login | ✗ | Login, receive JWT |
| GET | /api/users/me | ✓ | Get current user profile |
| PUT | /api/users/me | ✓ | Update display name |
| PATCH | /api/users/me/password | ✓ | Change password |
| POST | /api/notes/upload | ✓ | Upload PDF/text note |
| GET | /api/notes/ | ✓ | List user's notes |
| GET | /api/notes/{id} | ✓ | Get single note |
| GET | /api/summaries/{note_id} | ✓ | Get AI summary |
| POST | /api/summaries/{note_id}/generate | ✓ | Generate AI summary |
| POST | /api/flashcards/{note_id}/generate | ✓ | Generate flashcards |
| GET | /api/flashcards/{note_id} | ✓ | List flashcards |
| PATCH | /api/flashcards/{id}/rate | ✓ | Rate a flashcard |
| POST | /api/quizzes/{note_id}/generate | ✓ | Generate MCQ quiz |
| POST | /api/quizzes/{session_id}/submit | ✓ | Submit quiz answers |
| GET | /api/quizzes/history | ✓ | Past quiz sessions |
| POST | /api/chat/message | ✓ | Send RAG chat message |
| GET | /api/chat/{session_id}/history | ✓ | Chat history |
| GET | /api/progress/dashboard | ✓ | Dashboard stats & streak |

---

## CI / CD

GitHub Actions runs on every push to `main` and on pull requests:

- **backend** job: Python 3.11, install deps, `flake8` lint, `black --check`
- **frontend** job: Flutter stable, `flutter analyze`, `flutter test`

---

## 20-Day Build Log

| Days | Focus |
|------|-------|
| 1 | Project scaffold + JWT auth |
| 2 | Dev tooling, linting, CI |
| 3–4 | Alembic migrations + user profile |
| 5–6 | File upload & ingestion |
| 7–8 | PDF parsing & text chunking + ChromaDB |
| 9–10 | AI summarization (GPT-4o-mini) |
| 11–12 | Flashcard generation with 3D flip UI |
| 13–14 | MCQ quiz engine |
| 15–16 | RAG chat interface |
| 17–18 | Progress tracking dashboard |
| 19–20 | Polish, error handling & final cleanup |

---

## License

MIT
