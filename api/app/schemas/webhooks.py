from pydantic import BaseModel


class WebhookAckResponse(BaseModel):
    ok: bool
