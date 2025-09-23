import json
import logging
import time
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger("app.requests")  # << not uvicorn.access

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        t0 = time.perf_counter()
        try:
            response = await call_next(request)
            status = response.status_code
        except Exception:
            status = 500
            raise
        finally:
            duration_ms = int((time.perf_counter() - t0) * 1000)
            try:
                payload = {
                    "trace_id": request.headers.get("x-trace-id"),
                    "method": request.method,
                    "path": request.url.path,
                    "status": status,
                    "duration_ms": duration_ms,
                }
                # Log as one string so formatters don’t try to unpack tuples
                logger.info(json.dumps(payload, ensure_ascii=False))
            except Exception:
                # never let logging kill the request
                pass
        return response
