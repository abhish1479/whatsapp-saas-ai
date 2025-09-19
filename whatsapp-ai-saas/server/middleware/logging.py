import logging
import time
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

logger = logging.getLogger("uvicorn.access")

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        trace_id = str(uuid.uuid4())
        start = time.time()
        response = None
        try:
            response = await call_next(request)
            return response
        finally:
            duration = time.time() - start
            logger.info({
                "trace_id": trace_id,
                "method": request.method,
                "path": request.url.path,
                "status": response.status_code if response else None,
                "duration_ms": int(duration*1000)
            })
