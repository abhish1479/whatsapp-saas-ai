FROM python:3.11-slim

WORKDIR /app

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 1. Copy requirements and install Python dependencies FIRST
COPY server/requirements.txt .
RUN pip install --default-timeout=1000 --no-cache-dir -r requirements.txt

# 2. Install Chromium AND let Playwright handle all the system dependencies automatically
RUN playwright install chromium && \
    playwright install-deps chromium

# 3. Copy your application code
COPY server/ .

# 4. Start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]