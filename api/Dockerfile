FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.4 \
    PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

COPY pyproject.toml /app/
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi --without dev

COPY . /app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# Everything above is what ships. This stage exists because the runtime image
# installs `--without dev`, so a freshly built API image has no pytest in it -
# rebuilding the API silently removed the ability to test it, which is the
# kind of thing that surfaces mid-incident rather than in review.
#
# Selected by BUILD_TARGET in docker-compose.yml, which defaults to `runtime`.
# Local development sets BUILD_TARGET=dev; a server that never sets it keeps
# the lean image, so production cannot acquire test dependencies by accident.
FROM runtime AS dev

RUN poetry install --no-interaction --no-ansi --with dev
