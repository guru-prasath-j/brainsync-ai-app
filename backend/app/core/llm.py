"""
Shared LLM client.

Uses Google Gemini (via its OpenAI-compatible endpoint) when GEMINI_API_KEY is set,
otherwise falls back to OpenAI with OPENAI_API_KEY. Override the model with AI_MODEL.
"""
import os
from functools import lru_cache

import httpx
from openai import AsyncOpenAI

GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/openai/"


def _use_gemini() -> bool:
    return bool(os.getenv("GEMINI_API_KEY"))


def get_model() -> str:
    default = "gemini-2.5-flash" if _use_gemini() else "gpt-4o-mini"
    return os.getenv("AI_MODEL", default)


@lru_cache(maxsize=1)
def get_client() -> AsyncOpenAI:
    # verify=False bypasses AVG antivirus SSL interception in local dev
    http_client = httpx.AsyncClient(verify=False, timeout=120)
    if _use_gemini():
        return AsyncOpenAI(
            api_key=os.environ["GEMINI_API_KEY"],
            base_url=GEMINI_BASE_URL,
            http_client=http_client,
        )
    key = os.getenv("OPENAI_API_KEY")
    if not key:
        raise RuntimeError("Set GEMINI_API_KEY or OPENAI_API_KEY to enable AI features.")
    return AsyncOpenAI(api_key=key, http_client=http_client)


async def chat_completion(**kwargs):
    """chat.completions.create with the configured model and provider tweaks."""
    kwargs.setdefault("model", get_model())
    if _use_gemini():
        # Disable Gemini 2.5 "thinking" so it doesn't consume the max_tokens budget
        kwargs.setdefault("extra_body", {"reasoning_effort": "none"})
    return await get_client().chat.completions.create(**kwargs)
