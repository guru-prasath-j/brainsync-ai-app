"""Shared pytest fixtures for the BrainSync AI backend test suite."""
import os

import pytest

# Ensure tests never accidentally hit a real database or external services.
os.environ.setdefault("DATABASE_URL", "sqlite:///./test.db")
os.environ.setdefault("SECRET_KEY", "test-secret-key")
os.environ.setdefault("OPENAI_API_KEY", "test-key")

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


@pytest.fixture(scope="session")
def client() -> TestClient:
    """A reusable FastAPI test client for the whole session."""
    with TestClient(app) as test_client:
        yield test_client
