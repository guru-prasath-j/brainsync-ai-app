# Contributing to BrainSync AI

Thanks for your interest in improving BrainSync AI — an AI-powered study companion
built with a FastAPI backend and a Flutter frontend.

## Project layout

| Path        | Description                                      |
|-------------|--------------------------------------------------|
| `backend/`  | FastAPI service (Python 3.11, SQLAlchemy, Alembic) |
| `frontend/` | Flutter (Dart) mobile/web client                 |
| `.github/`  | CI workflows                                      |

## Running locally with Docker

The fastest way to get the backend and a Postgres database running:

```bash
cp backend/.env.example backend/.env   # then fill in OPENAI_API_KEY etc.
docker compose up --build
```

The API will be available at http://localhost:8000 and interactive docs at
http://localhost:8000/docs.

## Backend development (without Docker)

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
make migrate        # apply Alembic migrations
make run            # start uvicorn with --reload
```

Common shortcuts (see `backend/Makefile`):

- `make lint` — flake8 + black --check
- `make format` — black + isort
- `make test` — run the pytest suite

## Frontend development

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run
```

## Tests

Backend tests live in `backend/tests/` and use `pytest` with FastAPI's
`TestClient`. They are designed to run without a live database or external API
keys. Run them with:

```bash
cd backend && pytest -q
```

Please add or update tests for any behavioural change.

## Commit & PR guidelines

- Keep commits focused and write clear messages.
- Ensure `make lint` and `make test` pass before opening a PR.
- CI (GitHub Actions) must be green before merge.

## Code style

- **Python:** black (line length 100) + isort (profile black) + flake8.
- **Dart:** the rules in `frontend/analysis_options.yaml`.
