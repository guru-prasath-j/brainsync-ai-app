import openai
import os
from typing import Any

client = openai.AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))


class AIService:
    """Service for AI-powered summarization using GPT-4o-mini."""

    MODEL = "gpt-4o-mini"

    async def summarize(self, text: str) -> dict[str, Any]:
        """
        Summarize the provided text.

        Returns a dict with:
          - tldr: one-sentence summary
          - key_points: list of key points (up to 7)
          - concepts: list of important concepts/terms
        """
        prompt = (
            "You are an expert study assistant. Analyze the following text and provide:\n"
            "1. A concise TL;DR (one sentence).\n"
            "2. Key points (up to 7 bullet points).\n"
            "3. Important concepts or terms (as a list of short phrases).\n\n"
            "Respond ONLY with valid JSON in this exact shape:\n"
            '{\n'
            '  "tldr": "...",\n'
            '  "key_points": ["...", "..."],\n'
            '  "concepts": ["...", "..."]\n'
            '}\n\n'
            f"TEXT:\n{text[:8000]}"
        )

        response = await client.chat.completions.create(
            model=self.MODEL,
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.3,
        )

        import json
        raw = response.choices[0].message.content
        return json.loads(raw)

    async def generate_tldr(self, text: str) -> str:
        """Quick one-sentence summary."""
        result = await self.summarize(text)
        return result.get("tldr", "")
