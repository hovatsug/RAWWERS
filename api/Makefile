.PHONY: up down migrate test

up:
	docker-compose up --build

down:
	docker-compose down -v

migrate:
	docker-compose run --rm api alembic upgrade head

test:
	poetry install --no-interaction --no-ansi
	poetry run pytest -q
