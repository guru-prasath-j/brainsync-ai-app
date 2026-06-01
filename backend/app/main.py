from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, users, notes

app = FastAPI(
    title="BrainSync AI API",
    description="AI-powered study companion backend",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(notes.router, prefix="/api/notes", tags=["notes"])


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "BrainSync AI"}
