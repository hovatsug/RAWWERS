SERVER ?= root@46.225.123.43
REMOTE_API_DIR ?= /opt/rawwers/api
APP_HEALTH_URL ?= https://app.rawwers.com/healthz
RSYNC_EXCLUDES = --exclude ".env" --exclude ".DS_Store" --exclude "._*" --exclude "__pycache__/" --exclude ".pytest_cache/" --exclude ".mypy_cache/"

.PHONY: up down migrate test deploy deploy-sync deploy-up deploy-migrate deploy-health

up:
	docker-compose up --build

down:
	docker-compose down -v

migrate:
	docker-compose run --rm api alembic upgrade head

test:
	poetry install --no-interaction --no-ansi
	poetry run pytest -q

deploy: deploy-sync deploy-up deploy-migrate deploy-health

deploy-sync:
	rsync -az --delete $(RSYNC_EXCLUDES) ./ $(SERVER):$(REMOTE_API_DIR)/

deploy-up:
	ssh $(SERVER) "cd $(REMOTE_API_DIR) && docker compose up -d --build"

deploy-migrate:
	ssh $(SERVER) "cd $(REMOTE_API_DIR) && docker compose run --rm -e PYTHONPATH=/app api alembic upgrade head"

deploy-health:
	curl -fsS $(APP_HEALTH_URL)
