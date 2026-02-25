from collections.abc import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()

primary_database_url = settings.primary_database_url or settings.database_url
replica_database_url = settings.replica_database_url

engine = create_engine(primary_database_url, future=True)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, class_=Session)

replica_engine = create_engine(replica_database_url, future=True) if replica_database_url else None
ReplicaSessionLocal = (
    sessionmaker(bind=replica_engine, autocommit=False, autoflush=False, class_=Session) if replica_engine else None
)


def get_db() -> Generator[Session, None, None]:
    # Backward compatible alias: default to write session.
    yield from get_db_write()


def get_db_write() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db_read() -> Generator[Session, None, None]:
    if ReplicaSessionLocal:
        replica_db = ReplicaSessionLocal()
        try:
            lag = get_replica_lag_seconds(replica_db)
            if lag is None or lag <= settings.max_replica_lag_seconds:
                yield replica_db
                return
        except Exception:
            # Fallback to primary if replica check/query fails.
            pass
        finally:
            replica_db.close()

    primary_db = SessionLocal()
    try:
        yield primary_db
    finally:
        primary_db.close()


def get_replica_lag_seconds(db: Session) -> float | None:
    if not replica_database_url:
        return None
    try:
        row = db.execute(
            text("SELECT EXTRACT(EPOCH FROM (NOW() - pg_last_xact_replay_timestamp()))")
        ).scalar_one_or_none()
        if row is None:
            return None
        lag = float(row)
        return max(0.0, lag)
    except Exception:
        return None
