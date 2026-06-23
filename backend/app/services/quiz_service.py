import os
from typing import List, Dict, Any
import json
import httpx
from openai import AsyncOpenAI

client = AsyncOpenAI(
    api_key=os.getenv('OPENAI_API_KEY'),
    http_client=httpx.AsyncClient(verify=False),
)


class QuizService:
    async def generate_quiz(
        self,
        text: str,
        num_questions: int = 5,
        difficulty: str = 'medium',
    ) -> List[Dict[str, Any]]:
        """Generate MCQ quiz questions from text using GPT-4o-mini."""
        prompt = (
            f'You are an expert quiz creator. Generate {num_questions} multiple-choice questions '
            f'from the following text.\nDifficulty level: {difficulty}\n\nTEXT:\n{text[:4000]}\n\n'
            'Return a JSON array. Each item must have:\n'
            '- question: the question text\n'
            '- options: array of exactly 4 answer strings\n'
            '- correct_index: integer 0-3\n'
            '- explanation: brief explanation\n'
            f'- difficulty: "{difficulty}"\n\nReturn ONLY valid JSON.'
        )

        response = await client.chat.completions.create(
            model='gpt-4o-mini',
            messages=[{'role': 'user', 'content': prompt}],
            temperature=0.7,
        )

        content = response.choices[0].message.content.strip()
        if content.startswith('```'):
            parts = content.split('```')
            content = parts[1]
            if content.startswith('json'):
                content = content[4:]
        content = content.strip()
        return json.loads(content)

    async def evaluate_answer(
        self,
        correct_index: int,
        selected_index: int,
        explanation: str,
    ) -> Dict[str, Any]:
        """Evaluate a submitted answer."""
        return {
            'is_correct': selected_index == correct_index,
            'correct_index': correct_index,
            'selected_index': selected_index,
            'explanation': explanation,
        }


quiz_service = QuizService()