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



<img width="716" height="1600" alt="IMG-20260623-WA0160 1" src="https://github.com/user-attachments/assets/86510066-e025-4f11-b766-07f69213972a" />


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

## How It Works

### End-to-end flow

```mermaid
flowchart TD
    A[Register / Login] -->|JWT issued| B[Upload PDF / text note]
    B --> C[BackgroundTask: process_note]
    C --> C1[Extract text - pdfplumber / plain read]
    C1 --> C2[Clean text]
    C2 --> C3[Chunk: 500 words, 50-word overlap]
    C3 --> C4[Embed & store in ChromaDB collection note_&lcub;id&rcub;]
    C4 --> D[Note status: processed]
    D --> E[Summary]
    D --> F[Flashcards]
    D --> G[Quiz]
    D --> H[RAG Chat]
    D --> I[Progress Dashboard]
```

### 1. Auth
`POST /api/auth/register` hashes the password (bcrypt) and creates the user, but does **not** auto-login — the Flutter app deliberately routes back to the login screen. `POST /api/auth/login` verifies the password and issues a JWT (HS256, `SECRET_KEY`, expiry from `ACCESS_TOKEN_EXPIRE_MINUTES`). Every protected route decodes the bearer token via `get_current_user` and loads the user by the token's `sub` claim.

### 2. Note upload & ingestion
`POST /api/notes/upload` saves the file to `uploads/{user_id}/{uuid}_{filename}` and creates a `Note` row (`status="uploaded"`), then kicks off ingestion as a FastAPI `BackgroundTask` (no Celery/Redis — runs in-process right after the response is sent):
1. Extract text (`pdfplumber` for PDFs, plain read for `.txt`/`.md`)
2. Clean whitespace/non-printable characters
3. Chunk into ~500-word windows with 50-word overlap
4. Embed and store each chunk in a per-note ChromaDB collection (`note_{note_id}`, cosine similarity), with `{note_id, user_id, chunk_index}` metadata
5. Mark the note `processed` (or `failed` if extraction yields nothing)

### 3. AI Summary
`POST /api/summaries/{note_id}/generate` re-reads the source file, truncates to 12k characters, and makes a single GPT-4o-mini call (`temperature=0.3`) with a prompt that forces a strict JSON response: `{tldr, key_points, concepts}`. The result is upserted as one `Summary` row per note.

### 4. Flashcards
`POST /api/flashcards/{note_id}/generate` clears existing cards, re-extracts the note text, and asks GPT-4o-mini (`temperature=0.4`) for 8–12 Q&A pairs as JSON, persisted as `Flashcard` rows. `PATCH /api/flashcards/{id}/rate` records a simple known/unknown flag — self-assessment tracking, not a spaced-repetition scheduler.

### 5. Quiz
`POST /api/quizzes/{note_id}/generate` (note must already be `processed`) sends the first 4,000 characters of the note to GPT-4o-mini (`temperature=0.7`) requesting a JSON array of 4-option MCQs with explanations, stored as a `QuizSession` + `QuizQuestion` rows. `POST /api/quizzes/{session_id}/submit` grades answers with a plain server-side equality check (no AI call), updates the score, and marks the session complete once every question is answered.

### 6. RAG Chat
Chat messages optionally attach to a note. On each message, `RAGService` runs a semantic search (`n_results=4`) against that note's ChromaDB collection, joins the retrieved chunks as context, adds the last 10 messages of conversation history, and sends everything to GPT-4o-mini (`temperature=0.7`) to produce a grounded reply. Both the user message and the AI reply are persisted to the session history.

### 7. Progress Dashboard
`GET /api/progress/dashboard` is a pure SQL aggregation (no AI calls): total/processed note counts, quiz count and average score across completed sessions, total chat messages, a 7-day daily-activity histogram, and a day-streak counter derived by walking backward from today until the first day with no note upload.

### Notes on the implementation
- All AI generation calls (summary, flashcards, quiz, chat) are synchronous — the HTTP request blocks until OpenAI responds. Only ingestion runs in the background.
- Each AI-calling service instantiates its own `AsyncOpenAI` client; there is no shared client wrapper, and all of them hardcode `gpt-4o-mini`.
- The Flutter app talks to the API through a single Dio-based `ApiClient` that attaches the stored JWT to every request via an interceptor.

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
