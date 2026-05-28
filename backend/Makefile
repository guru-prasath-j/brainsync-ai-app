.PHONY: run lint format test migrate clean install help

# Default target
help:
	@echo "BrainSync AI - Backend Developer Commands"
	@echo "========================================="
	@echo "make run       - Start the development server (hot reload)"
	@echo "make lint      - Run flake8 linter and black format check"
	@echo "make format    - Auto-format code with black and isort"
	@echo "make test      - Run all tests with pytest"
	@echo "make migrate   - Run Alembic database migrations"
	@echo "make install   - Install all Python dependencies"
	@echo "make clean     - Remove __pycache__ and .pyc files"

# Start FastAPI dev server
run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Lint: check code style without modifying files
lint:
	flake8 app/ tests/
	black --check app/ tests/
	isort --check-only app/ tests/

# Format: auto-fix code style
format:
	black app/ tests/
	isort app/ tests/

# Run tests
test:
	pytest tests/ -v --tb=short

# Run tests with coverage report
test-cov:
	pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

# Run Alembic migrations
migrate:
	alembic upgrade head

# Create a new migration (usage: make migration MSG="your message")
migration:
	alembic revision --autogenerate -m "$(MSG)"

# Rollback last migration
rollback:
	alembic downgrade -1

# Install dependencies
install:
	pip install -r requirements.txt

# Install dev dependencies
install-dev:
	pip install -r requirements-dev.txt

# Clean compiled Python files
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf htmlcov/ .coverage
