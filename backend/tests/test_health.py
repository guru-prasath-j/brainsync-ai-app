"""Smoke tests for the application entrypoint.

These tests don't touch the database or any external service; they verify that
the app boots, the health endpoint responds, and the OpenAPI schema exposes the
routers we expect to be mounted.
"""


def test_health_check_returns_ok(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert body["service"] == "BrainSync AI"


def test_openapi_schema_is_served(client):
    resp = client.get("/openapi.json")
    assert resp.status_code == 200
    assert resp.json()["info"]["title"] == "BrainSync AI API"


def test_expected_routers_are_mounted(client):
    """Every feature area built over the plan should expose at least one path."""
    paths = client.get("/openapi.json").json()["paths"]
    expected_prefixes = [
        "/api/auth",
        "/api/users",
        "/api/notes",
        "/api/summaries",
        "/api/flashcards",
        "/api/quizzes",
        "/api/chat",
    ]
    for prefix in expected_prefixes:
        assert any(p.startswith(prefix) for p in paths), f"missing routes for {prefix}"
