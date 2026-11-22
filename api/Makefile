
.PHONY: up down migrate test test-isolated deploy deploy-sync deploy-up deploy-migrate deploy-health

up:
	docker-compose up --build

down:
	docker-compose down -v

migrate:
	docker-compose run --rm api alembic upgrade head

test:
	poetry install --no-interaction --no-ansi
	poetry run pytest -q

# The suite in Docker on its own database and Redis index, so runs can go
# side by side - see scripts/test_isolated.sh. REPO=<checkout> ARGS="<pytest args>"
test-isolated:
	REPO="$(REPO)" ARGS="$(ARGS)" scripts/test_isolated.sh

# Deploys are not made from here: images are built on the Mac and pulled on
# the server (docs/DEPLOY_RUNBOOK.md). The old targets rsynced this folder to a
# server and built there with the development compose file.
deploy deploy-sync deploy-up deploy-migrate deploy-health:
	@echo "Not from here: follow docs/DEPLOY_RUNBOOK.md (deploy/scripts/build-and-push.sh, then deploy/scripts/dc on the server)."; exit 1
