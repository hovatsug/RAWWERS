# Dependencies: every build installs the same versions

Each part of the repository has a committed lockfile, and its build installs exactly what the lockfile says.

| Part | Tool | Lockfile | Where the build enforces it |
|---|---|---|---|
| API (`api/`) | Poetry 1.8.4 (`POETRY_VERSION` in `api/Dockerfile`) | `api/poetry.lock` | `api/Dockerfile` copies `pyproject.toml` and `poetry.lock` and runs `poetry install --no-root`. Poetry refuses a lock that no longer matches `pyproject.toml`, so the build fails rather than resolving afresh. |
| Web admin and landing (`web/`) | pnpm (through corepack) | `web/pnpm-lock.yaml` | `web/Dockerfile`: `pnpm install --frozen-lockfile` |
| Apps (`app/`) | Flutter pub | `app/pubspec.lock` | `flutter pub get` installs the locked versions; only `flutter pub upgrade` changes them. |
| Lightroom plug-in (`lightroom/`) | — | none needed | Plain Lua, no third-party packages. |

## The API lock, checked (2026-11-11)

The runtime stage was built twice from the same commit with `--no-cache`. `pip freeze --all` gave the same 92 lines both times. The app was imported in that image with the dev settings. Before the lock, two builds of one commit had installed pydantic 2.13 and 2.14.

The first lock (2026-11-11) moved these packages on from the dev image built on 2026-11-10: boto3 and botocore (1.43.123 → 1.44.0), celery (5.6.3 → 5.7.0), click, coverage, pydantic (2.14.2 → 2.14.3), pydantic-core, SQLAlchemy (2.1.6 → 2.1.8), typing-inspection and tzdata. The tests at the next gate run on them.

## Updating a dependency

API (from `api/`, inside the same Poetry version as the image, so the lock format matches):

    docker run --rm -v "$PWD":/src -w /src python:3.12-slim sh -c \
      'pip install -q "poetry==1.8.4" && poetry add "<package>@^<version>"'   # a new or changed dependency
    # or, to move one package within its existing range:
    #   ... sh -c 'pip install -q "poetry==1.8.4" && poetry update <package>'
    # or, after editing pyproject.toml by hand, without upgrading anything else:
    #   ... sh -c 'pip install -q "poetry==1.8.4" && poetry lock --no-update'

1. Commit `pyproject.toml` and `poetry.lock` together, in the same commit as the code that needs the change.
2. Rebuild the dev images (`--target dev`) and run the tests for what the package touches.
3. A dependency change is listed in `docs/UNGATED_COMMITS.md` like any other commit. `poetry lock` without `--no-update` moves every package to its newest allowed version. Do it only on purpose, at a gate.

Web: `pnpm add <package>@<version>` or `pnpm update <package>` in `web/`, then commit `package.json` and `pnpm-lock.yaml` together.

Apps: edit `pubspec.yaml`, then `flutter pub get` (or `flutter pub upgrade <package>`) in `app/`, then commit `pubspec.yaml` and `pubspec.lock` together. Riverpod stays at 2.6.1 (see `app/README.md`).
