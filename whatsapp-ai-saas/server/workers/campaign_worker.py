from rq import Worker, Queue, Connection
from redis import Redis
from settings import settings

listen = ['campaigns']

if __name__ == '__main__':
    conn = Redis.from_url(settings.REDIS_URL)
    with Connection(conn):
        worker = Worker(map(Queue, listen))
        worker.work()
