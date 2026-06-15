from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import NoResultFound
import logging

logger = logging.getLogger(__name__)


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Handle HTTP exceptions with consistent error format."""
    logger.warning(f"HTTP {exc.status_code} on {request.method} {request.url}: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.status_code,
                "message": exc.detail,
                "path": str(request.url.path),
            }
        },
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Handle Pydantic validation errors (422)."""
    errors = []
    for error in exc.errors():
        errors.append({
            "field": " -> ".join(str(loc) for loc in error["loc"]),
            "message": error["msg"],
            "type": error["type"],
        })
    logger.warning(f"Validation error on {request.method} {request.url}: {errors}")
    return JSONResponse(
        status_code=422,
        content={
            "error": {
                "code": 422,
                "message": "Validation failed",
                "details": errors,
                "path": str(request.url.path),
            }
        },
    )


async def not_found_exception_handler(request: Request, exc: NoResultFound) -> JSONResponse:
    """Handle SQLAlchemy NoResultFound as 404."""
    return JSONResponse(
        status_code=404,
        content={
            "error": {
                "code": 404,
                "message": "Resource not found",
                "path": str(request.url.path),
            }
        },
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handle unexpected exceptions as 500."""
    logger.error(f"Unhandled exception on {request.method} {request.url}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": 500,
                "message": "Internal server error",
                "path": str(request.url.path),
            }
        },
    )


def register_exception_handlers(app) -> None:
    """Register all exception handlers on the FastAPI app."""
    from fastapi.exceptions import RequestValidationError
    from sqlalchemy.exc import NoResultFound

    app.add_exception_handler(HTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(NoResultFound, not_found_exception_handler)
    app.add_exception_handler(Exception, generic_exception_handler)
