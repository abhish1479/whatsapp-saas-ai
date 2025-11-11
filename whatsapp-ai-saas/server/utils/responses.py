from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi import HTTPException
from pydantic import BaseModel
from typing import TypeVar, Generic

# This file contains your "global" standardized response models
# and the error handlers that create them.

T = TypeVar('T')

class ErrorDetail(BaseModel):
    """A model for a structured error code and message."""
    code: str
    details: list[str]

class StandardResponse(BaseModel, Generic[T]):
    """A generic, standardized API response model."""
    success: bool = True
    data: T | None = None
    message: str | None = None
    error: ErrorDetail | None = None

    class Config:
        from_attributes = True

# --- Global Error Handlers ---

async def http_exception_handler(request: Request, exc: HTTPException):
    """Custom handler for FastAPI's built-in HTTPExceptions."""
    return JSONResponse(
        status_code=exc.status_code,
        content=StandardResponse(
            success=False,
            data=None,
            message=str(exc.detail),
            error=ErrorDetail(
                code=f"HTTP_{exc.status_code}",
                details=[str(exc.detail)]
            )
        ).model_dump()
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Custom handler for Pydantic validation errors."""
    
    error_details = [
        f"{'.'.join(str(loc) for loc in err['loc'])}: {err['msg']}" 
        for err in exc.errors()
    ]
    
    return JSONResponse(
        status_code=422,
        content=StandardResponse(
            success=False,
            data=None,
            message="Validation failed",
            error=ErrorDetail(
                code="VALIDATION_ERROR",
                details=error_details
            )
        ).model_dump()
    )