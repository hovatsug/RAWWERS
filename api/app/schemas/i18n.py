from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class I18nBundleView(BaseModel):
    id: uuid.UUID
    locale: str
    namespace: str
    version: int
    content: dict = Field(default_factory=dict)
    is_active: bool
    created_at: datetime
    updated_at: datetime


class I18nBundleCreateRequest(BaseModel):
    locale: str
    namespace: str
    version: int
    content: dict = Field(default_factory=dict)
    is_active: bool = False


class I18nBundleFetchResponse(BaseModel):
    locale: str
    namespace: str
    version: int
    content: dict = Field(default_factory=dict)


class I18nLocaleListResponse(BaseModel):
    locales: list[str] = Field(default_factory=list)


class I18nMissingKeysResponse(BaseModel):
    locale: str
    namespace: str
    missing: list[str] = Field(default_factory=list)
    unused: list[str] = Field(default_factory=list)
