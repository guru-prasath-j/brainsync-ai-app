import time
import uuid
import logging
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware that logs each request with timing and a trace ID."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = str(uuid.uuid4())[:8]
        start_time = time.perf_counter()

        # Attach trace ID so handlers can reference it
        request.state.request_id = request_id

        logger.info(
            f"[{request_id}] --> {request.method} {request.url.path}"
            + (f"?{request.url.query}" if request.url.query else "")
        )

        try:
            response = await call_next(request)
        except Exception as exc:  # pragma: no cover
            elapsed = (time.perf_counter() - start_time) * 1000
            logger.error(f"[{request_id}] !! UNHANDLED {type(exc).__name__} ({elapsed:.1f}ms)")
            raise

        elapsed = (time.perf_counter() - start_time) * 1000
        logger.info(
            f"[{request_id}] <-- {response.status_code} "
            f"{request.method} {request.url.path} ({elapsed:.1f}ms)"
        )

        response.headers["X-Request-ID"] = request_id
        response.headers["X-Response-Time"] = f"{elapsed:.1f}ms"
        return response
