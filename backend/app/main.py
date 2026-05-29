from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, users

app = FastAPI(
    title="BrainSync AI",
    description="AI-powered study companion backend API",
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


@app.get("/health")
async def health_check() -> dict:
    return {"status": "ok", "service": "brainsync-ai"}
