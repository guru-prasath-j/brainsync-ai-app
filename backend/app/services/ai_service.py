"""
AI Service - GPT-4o-mini integration for text summarization.
"""
import json
import os
from typing import Optional

import openai
from openai import AsyncOpenAI

client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

SUMMARIZE_SYSTEM_PROMPT = """You are an expert study assistant that helps students understand complex material.
When given text content, produce a structured summary with:
1. A concise TL;DR (2-3 sentences)
2. 3-7 key points (bullet form, each 1-2 sentences)
3. 5-10 important concepts/terms

Return ONLY valid JSON with this exact structure:
{
  "tldr": "...",
  "key_points": ["...", "..."],
  "concepts": ["term1", "term2", ...]
}"""


class AIService:
    """Service for AI-powered text analysis using GPT-4o-mini."""

    def __init__(self):
        self.model = "gpt-4o-mini"
        self.max_tokens = 4096

    async def summarize(self, text: str, max_chunk_chars: int = 12000) -> dict:
        """
        Summarize text content and return structured data.

        Args:
            text: The text to summarize
            max_chunk_chars: Maximum characters to send in one request

        Returns:
            dict with keys: tldr, key_points, concepts
        """
        # Truncate if too long (GPT-4o-mini context limit safety)
        if len(text) > max_chunk_chars:
            text = text[:max_chunk_chars] + "\n\n[Content truncated for summarization]"

        try:
            response = await client.chat.completions.create(
                model=self.model,
                max_tokens=self.max_tokens,
                temperature=0.3,
                messages=[
                    {"role": "system", "content": SUMMARIZE_SYSTEM_PROMPT},
                    {
                        "role": "user",
                        "content": f"Please summarize the following study material:\n\n{text}",
                    },
                ],
            )

            raw = response.choices[0].message.content.strip()

            # Strip markdown code fences if present
            if raw.startswith("```"):
                raw = raw.split("```")[1]
                if raw.startswith("json"):
                    raw = raw[4:]
                raw = raw.strip()

            result = json.loads(raw)
            return {
                "tldr": result.get("tldr", ""),
                "key_points": result.get("key_points", []),
                "concepts": result.get("concepts", []),
            }

        except json.JSONDecodeError as e:
            # Fallback: return raw text in tldr
            return {
                "tldr": raw[:500] if "raw" in dir() else "Summary unavailable",
                "key_points": [],
                "concepts": [],
            }
        except openai.OpenAIError as e:
            raise RuntimeError(f"OpenAI API error: {str(e)}") from e

    async def generate_title(self, text: str) -> str:
        """Generate a concise title for a piece of text."""
        truncated = text[:2000]
        response = await client.chat.completions.create(
            model=self.model,
            max_tokens=30,
            temperature=0.5,
            messages=[
                {
                    "role": "user",
                    "content": (
                        f"Generate a short (max 6 words) descriptive title for this text:\n\n{truncated}"
                        "\n\nReturn only the title, no quotes."
                    ),
                }
            ],
        )
        return response.choices[0].message.content.strip().strip('"')


ai_service = AIService()
