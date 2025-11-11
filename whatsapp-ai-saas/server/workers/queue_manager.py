# app/workers/queue_manager.py

import redis
from rq import Queue
from typing import Optional
from settings import settings

class QueueManager:
    """Centralized, lazy-loading RQ queue manager."""

    # Central Redis URL (could also come from env var)
    REDIS_URL = settings.REDIS_URL      #"redis://redis:6379"

    # Registry of valid queue names (optional safety)
    VALID_QUEUES = {
        "file_processing",
        "campaigns",
        "web_crwalling",
    }

    def __init__(self):
        """Initialize Redis connection only once."""
        self.connection = redis.from_url(self.REDIS_URL)

    def get_queue(self, name: str) -> Optional[Queue]:
        """
        Lazily return an RQ Queue by name.
        Only creates the queue object when needed.
        """
        if name not in self.VALID_QUEUES:
            raise ValueError(f"Invalid queue name: {name}")
        return Queue(name, connection=self.connection)
