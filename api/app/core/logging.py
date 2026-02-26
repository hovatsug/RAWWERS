import logging
from pythonjsonlogger import jsonlogger

from app.core.request_context import get_request_id, get_tenant_id, get_user_id


class RequestContextFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        record.request_id = getattr(record, "request_id", None) or get_request_id()
        record.user_id = getattr(record, "user_id", None) or get_user_id()
        record.tenant_id = getattr(record, "tenant_id", None) or get_tenant_id()
        return True


def configure_logging(level: str) -> None:
    root = logging.getLogger()
    root.setLevel(level.upper())
    handler = logging.StreamHandler()
    formatter = jsonlogger.JsonFormatter(
        "%(asctime)s %(levelname)s %(name)s %(message)s %(request_id)s %(user_id)s %(tenant_id)s"
    )
    handler.addFilter(RequestContextFilter())
    handler.setFormatter(formatter)
    root.handlers = [handler]
