from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import auth

app = FastAPI(
    title="BrainSync AI API",
    description="AI-Powered Study Companion Backend",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers (added incrementally over 20 days)
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
# app.include_router(notes.router, prefix="/api/notes", tags=["notes"])
# app.include_router(summaries.router, prefix="/api/summaries", tags=["summaries"])
# app.include_router(flashcards.router, prefix="/api/flashcards", tags=["flashcards"])
# app.include_router(quizzes.router, prefix="/api/quizzes", tags=["quizzes"])
# app.include_router(chat.router, prefix="/api/chat", tags=["chat"])


@app.get("/")
async def root():
    return {"message": "BrainSync AI API", "version": "1.0.0", "status": "running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
