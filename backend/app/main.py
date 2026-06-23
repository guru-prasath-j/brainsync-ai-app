from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, users, notes, summaries, flashcards, quizzes, progress

app = FastAPI(title='BrainSync AI API', version='1.0.0')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allow_headers=['*'],
    expose_headers=['*'],
)

app.include_router(auth.router, prefix='/api/auth', tags=['auth'])
app.include_router(users.router, prefix='/api/users', tags=['users'])
app.include_router(notes.router, prefix='/api/notes', tags=['notes'])
app.include_router(summaries.router, prefix='/api/summaries', tags=['summaries'])
app.include_router(flashcards.router, prefix='/api/flashcards', tags=['flashcards'])
app.include_router(quizzes.router, prefix='/api/quizzes', tags=['quizzes'])
app.include_router(progress.router, prefix='/api/progress', tags=['progress'])


@app.get('/health')
def health_check():
    return {'status': 'ok', 'service': 'BrainSync AI'}
# Chat (RAG) endpoints
from app.api import chat as chat_router
app.include_router(chat_router.router, prefix="/api/chat", tags=["chat"])
