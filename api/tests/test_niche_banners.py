"""Niche banners: chosen by an admin, kept with their history, served by the home and niche screens.

Storage is faked: what is under test is what the server decides - what it
accepts, what it keeps, what it serves and when the cached screens change -
not the bucket.
"""
import io
import uuid

import pytest
from PIL import Image
from sqlalchemy import select

from app.core.config import get_settings
from app.models.admin import AdminAuditLog
from app.models.media import MediaObject
from app.models.niche import Niche, NicheBanner, SkillTier
from app.services import niche_banners as service
from app.services.niche_catalog import ensure_initial_niches
from tests.test_client_home_rows import _city, _clear_home_cache, _home, _niche_page, _pro, _skill  # noqa: F401 - the fixture clears the cache around each test

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}
settings = get_settings()


def _image(width=2400, height=1350, color=(90, 90, 90), fmt="JPEG") -> bytes:
    out = io.BytesIO()
    Image.new("RGB", (width, height), color).save(out, format=fmt)
    return out.getvalue()


class _Store:
    def __init__(self):
        self.objects: dict[str, bytes] = {}
        self.cache_control: dict[str, str | None] = {}
        self.deleted: list[str] = []

    def size(self, key):
        return len(self.objects[key]) if key in self.objects else None

    def download(self, key, max_bytes=None):
        return self.objects[key]

    def upload(self, key, payload, content_type="image/jpeg", cache_control=None):
        self.objects[key] = payload
        self.cache_control[key] = cache_control

    def delete(self, key):
        self.deleted.append(key)
        self.objects.pop(key, None)


@pytest.fixture
def store(monkeypatch):
    s = _Store()
    monkeypatch.setattr(service, "object_size", s.size)
    monkeypatch.setattr(service, "download_object_bytes", s.download)
    monkeypatch.setattr(service, "upload_object_bytes", s.upload)
    monkeypatch.setattr(service, "delete_object", s.delete)
    return s


@pytest.fixture
def niches(db_session):
    ensure_initial_niches(db_session)
    db_session.commit()


def _start(client, *, content_type="image/jpeg", file_name="banner.jpg", headers=ADMIN):
    return client.post(
        "/v1/admin/niche-banner-uploads", json={"content_type": content_type, "file_name": file_name}, headers=headers
    )


def _upload(client, store, payload: bytes, *, content_type="image/jpeg"):
    """The browser's part: start, PUT straight to storage, complete."""
    started = _start(client, content_type=content_type)
    assert started.status_code == 200, started.text
    body = started.json()
    store.objects[body["upload"]["storage_key"]] = payload
    return client.post(f"/v1/admin/niche-banner-uploads/{body['media_asset_id']}/complete", headers=ADMIN)


def _ready(client, store, **image_kwargs) -> str:
    done = _upload(client, store, _image(**image_kwargs))
    assert done.status_code == 200, done.text
    return done.json()["media_asset_id"]


def _attach(client, slug, asset_id, **overrides):
    body = {"media_asset_id": asset_id, "alt_text": "A couple walking out of a church", "focal_x": 0.5, "focal_y": 0.4,
            "source": "owner"}
    body.update(overrides)
    return client.put(f"/v1/admin/niche-banners/{slug}/image", json=body, headers=ADMIN)


def _admin_row(client, slug):
    rows = client.get("/v1/admin/niche-banners", headers=ADMIN).json()["items"]
    return next(r for r in rows if r["slug"] == slug)


def _public(db_session, slug):
    niche = db_session.execute(select(Niche).where(Niche.slug == slug)).scalar_one()
    return service.banner_views(db_session, [niche], expires_in=600)[slug]


# --- The fallback, and the flag that stops it being overlooked. ---


def test_a_niche_set_to_image_with_none_uploaded_falls_back_and_is_flagged(client, db_session, niches):
    row = _admin_row(client, "weddings")
    assert row["banner_style"] == "image"
    assert row["status"] == "image_missing"

    view = _public(db_session, "weddings")
    assert view.style == "image"
    assert view.image is None, "nothing to show: the app draws the neutral ground"
    assert view.name == "Weddings"


# --- Upload, replace, revert, remove. ---


def test_upload_then_replace_then_revert(client, db_session, niches, store):
    first = _ready(client, store)
    assert _attach(client, "weddings", first).status_code == 200
    second = _ready(client, store)
    assert _attach(client, "weddings", second).status_code == 200

    detail = client.get("/v1/admin/niche-banners/weddings", headers=ADMIN).json()
    assert detail["current"]["media_asset_id"] == second
    assert detail["previous"]["media_asset_id"] == first

    reverted = client.post("/v1/admin/niche-banners/weddings/image/revert", headers=ADMIN)
    assert reverted.status_code == 200, reverted.text
    detail = client.get("/v1/admin/niche-banners/weddings", headers=ADMIN).json()
    assert detail["current"]["media_asset_id"] == first
    assert detail["previous"]["media_asset_id"] == second, "reverting must not lose the image it replaced"
    assert {h["media_asset_id"] for h in detail["history"]} == {first, second}


def test_nothing_to_revert_to_says_so(client, niches):
    resp = client.post("/v1/admin/niche-banners/weddings/image/revert", headers=ADMIN)
    assert resp.status_code == 409
    assert "no previous image" in resp.json()["error"]["message"].lower()


def test_removing_an_image_leaves_it_in_history_and_revertable(client, db_session, niches, store):
    asset = _ready(client, store)
    _attach(client, "weddings", asset)

    assert client.delete("/v1/admin/niche-banners/weddings/image", headers=ADMIN).status_code == 200
    assert _admin_row(client, "weddings")["status"] == "image_missing"
    assert _public(db_session, "weddings").image is None

    client.post("/v1/admin/niche-banners/weddings/image/revert", headers=ADMIN)
    assert _admin_row(client, "weddings")["status"] == "image_set"


# --- Text only: a choice, not a fallback. ---


def test_text_only_serves_no_image_at_all(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store))
    resp = client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "text", "banner_tagline": "Your day, quietly kept"}, headers=ADMIN)
    assert resp.status_code == 200, resp.text

    view = _public(db_session, "weddings")
    assert view.style == "text"
    assert view.image is None, "a text-only banner must give the app nothing to fetch"
    assert view.tagline == "Your day, quietly kept"
    assert _admin_row(client, "weddings")["status"] == "text_only"


def test_switching_style_keeps_the_image_and_its_history(client, db_session, niches, store):
    first = _ready(client, store)
    _attach(client, "weddings", first)
    second = _ready(client, store)
    _attach(client, "weddings", second)

    client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "text"}, headers=ADMIN)
    client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "image"}, headers=ADMIN)

    detail = client.get("/v1/admin/niche-banners/weddings", headers=ADMIN).json()
    assert detail["current"]["media_asset_id"] == second
    assert detail["previous"]["media_asset_id"] == first
    assert _public(db_session, "weddings").image is not None


def test_a_style_must_be_one_of_the_two(client, niches):
    resp = client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "video"}, headers=ADMIN)
    assert resp.status_code == 422


# --- What an image needs. ---


def test_an_image_needs_alt_text(client, niches, store):
    resp = _attach(client, "weddings", _ready(client, store), alt_text="  ")
    assert resp.status_code == 422
    assert "alt text" in resp.json()["error"]["message"].lower()


def test_a_stock_image_needs_its_source_credit_and_licence(client, niches, store):
    asset = _ready(client, store)
    resp = _attach(client, "weddings", asset, source="stock")
    assert resp.status_code == 422
    message = resp.json()["error"]["message"].lower()
    assert "credit" in message and "licence" in message and "source" in message

    ok = _attach(client, "weddings", asset, source="stock", credit="Ana Silva", licence="Pexels licence",
                 source_url="https://www.pexels.com/photo/123/")
    assert ok.status_code == 200, ok.text


def test_an_owner_upload_needs_no_source_record(client, niches, store):
    assert _attach(client, "weddings", _ready(client, store), source="owner").status_code == 200


def test_the_focal_point_is_inside_the_image(client, niches, store):
    asset = _ready(client, store)
    assert _attach(client, "weddings", asset, focal_x=1.2).status_code == 422
    assert _attach(client, "weddings", asset, focal_y=-0.1).status_code == 422


def test_the_focal_point_reaches_the_app(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store), focal_x=0.25, focal_y=0.8)
    image = _public(db_session, "weddings").image
    assert (image.focal_x, image.focal_y) == (0.25, 0.8)


def test_the_tagline_has_a_limit(client, niches):
    limit = settings.niche_banner_tagline_max
    ok = client.patch("/v1/admin/niche-banners/weddings", json={"banner_tagline": "x" * limit}, headers=ADMIN)
    assert ok.status_code == 200, ok.text
    too_long = client.patch("/v1/admin/niche-banners/weddings", json={"banner_tagline": "x" * (limit + 1)}, headers=ADMIN)
    assert too_long.status_code == 422
    assert str(limit) in too_long.json()["error"]["message"]


def test_an_empty_tagline_is_no_tagline(client, db_session, niches):
    client.patch("/v1/admin/niche-banners/weddings", json={"banner_tagline": "   "}, headers=ADMIN)
    assert _public(db_session, "weddings").tagline is None


# --- Upload validation, in words an admin can act on. ---


def test_a_format_that_is_not_allowed_is_refused_before_upload(client, niches, store):
    resp = _start(client, content_type="image/gif", file_name="banner.gif")
    assert resp.status_code == 422
    assert "jpeg" in resp.json()["error"]["message"].lower()


def test_a_file_that_is_not_really_an_allowed_image_is_refused(client, niches, store):
    resp = _upload(client, store, _image(fmt="GIF"))
    assert resp.status_code == 422
    assert "jpeg" in resp.json()["error"]["message"].lower()


def test_a_file_over_the_size_cap_is_refused_and_deleted(client, niches, store, monkeypatch):
    monkeypatch.setattr(service.settings, "niche_banner_max_bytes", 1000)
    resp = _upload(client, store, _image())
    assert resp.status_code == 422
    assert "mb" in resp.json()["error"]["message"].lower()
    assert store.deleted, "an oversized upload must not stay in the bucket"


def test_an_image_too_small_for_a_full_width_banner_is_refused(client, niches, store):
    resp = _upload(client, store, _image(width=1200, height=700))
    assert resp.status_code == 422
    message = resp.json()["error"]["message"]
    assert "1200" in message and str(settings.niche_banner_min_width) in message


def test_a_portrait_image_warns_but_is_accepted(client, niches, store):
    resp = _upload(client, store, _image(width=1800, height=2600))
    assert resp.status_code == 200, resp.text
    assert any("portrait" in w.lower() for w in resp.json()["warnings"])


def test_a_landscape_image_has_no_warning(client, niches, store):
    resp = _upload(client, store, _image())
    assert resp.json()["warnings"] == []


# --- Derivatives. ---


def test_each_upload_has_its_own_derivative_keys(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store))
    first = _public(db_session, "weddings").image
    _attach(client, "weddings", _ready(client, store))
    second = _public(db_session, "weddings").image

    def path(url):
        return url.split("?")[0]

    assert path(first.tile_url) != path(second.tile_url), "a new upload served under an old key would be a stale cache"
    assert path(first.hero_url) != path(second.hero_url)


def test_derivatives_are_made_at_their_sizes_and_cached_like_portfolio_work(client, niches, store):
    _ready(client, store, width=4000, height=2250)
    made = {key: Image.open(io.BytesIO(data)) for key, data in store.objects.items() if "_banner_" in key}
    widths = {key.rsplit("_banner_", 1)[1].split(".")[0]: im.width for key, im in made.items()}
    assert widths["tile"] == settings.niche_banner_tile_width
    assert widths["hero"] == settings.niche_banner_hero_width
    assert widths["placeholder"] == settings.niche_banner_placeholder_width
    for key in made:
        assert store.cache_control[key].startswith("public, max-age="), "banners are public, like portfolio work"


def test_the_placeholder_travels_with_the_banner(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store))
    image = _public(db_session, "weddings").image
    assert image.placeholder.startswith("data:image/jpeg;base64,")
    assert len(image.placeholder) < 4000, "a placeholder bigger than a few KB defeats the point"


# --- The legibility scrim. ---


def test_a_bright_image_gets_a_stronger_scrim_and_the_title_stays_legible(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store, color=(250, 250, 250)))
    bright = _public(db_session, "weddings").image.scrim_opacity
    _attach(client, "portraits", _ready(client, store, color=(20, 20, 20)))
    dark = _public(db_session, "portraits").image.scrim_opacity

    assert bright > dark
    # White text over the image darkened by the scrim, at its brightest.
    luminance = service.relative_luminance((250, 250, 250)) * (1 - bright)
    assert (1.05) / (luminance + 0.05) >= settings.niche_banner_min_contrast


# --- The cached screens change on the next load. ---


def _home_banner(client, viewer):
    return _home(client, viewer)["niche:weddings"]["banner"]


def _page_banner(client, viewer):
    return _niche_page(client, viewer, "weddings")["niche"]["banner"]


def test_every_change_reaches_the_home_and_niche_screens(client, db_session, niches, store):
    _city(db_session)
    _skill(db_session, _pro(db_session, name="Ana", gigs=3, niche_slug="weddings"), "weddings", SkillTier.pro)
    viewer = uuid.uuid4()
    from app.models.admin import UserAccount

    db_session.add(UserAccount(user_id=viewer))
    db_session.commit()

    def both():
        return _home_banner(client, viewer), _page_banner(client, viewer)

    home, page = both()  # now cached
    assert home["image"] is None and page["image"] is None

    first = _ready(client, store)
    _attach(client, "weddings", first)
    home, page = both()
    assert home["image"]["media_asset_id"] == first and page["image"]["media_asset_id"] == first, "upload"

    second = _ready(client, store)
    _attach(client, "weddings", second)
    home, page = both()
    assert home["image"]["media_asset_id"] == second and page["image"]["media_asset_id"] == second, "replace"

    client.post("/v1/admin/niche-banners/weddings/image/revert", headers=ADMIN)
    home, page = both()
    assert home["image"]["media_asset_id"] == first and page["image"]["media_asset_id"] == first, "revert"

    client.patch("/v1/admin/niche-banners/weddings/image", json={"focal_x": 0.1}, headers=ADMIN)
    home, page = both()
    assert home["image"]["focal_x"] == 0.1 and page["image"]["focal_x"] == 0.1, "edit"

    client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "text", "banner_tagline": "Kept quietly"}, headers=ADMIN)
    home, page = both()
    assert home["style"] == "text" and page["style"] == "text", "style"
    assert home["tagline"] == "Kept quietly" and page["tagline"] == "Kept quietly", "tagline"

    client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "image"}, headers=ADMIN)
    client.delete("/v1/admin/niche-banners/weddings/image", headers=ADMIN)
    home, page = both()
    assert home["image"] is None and page["image"] is None, "remove"


# --- Admins only, and every change on the record. ---


@pytest.mark.parametrize(
    "method, path, body",
    [
        ("get", "/v1/admin/niche-banners", None),
        ("get", "/v1/admin/niche-banners/weddings", None),
        ("post", "/v1/admin/niche-banner-uploads", {"content_type": "image/jpeg", "file_name": "b.jpg"}),
        ("post", f"/v1/admin/niche-banner-uploads/{uuid.uuid4()}/complete", None),
        ("put", "/v1/admin/niche-banners/weddings/image", {"media_asset_id": str(uuid.uuid4()), "alt_text": "x", "source": "owner"}),
        ("patch", "/v1/admin/niche-banners/weddings/image", {"alt_text": "x"}),
        ("delete", "/v1/admin/niche-banners/weddings/image", None),
        ("post", "/v1/admin/niche-banners/weddings/image/revert", None),
        ("patch", "/v1/admin/niche-banners/weddings", {"banner_style": "text"}),
    ],
)
def test_only_an_admin_can_touch_a_banner(client, db_session, niches, method, path, body):
    from app.models.admin import UserAccount, UserRole, UserRoleType

    someone = uuid.uuid4()
    db_session.add(UserAccount(user_id=someone))
    db_session.flush()
    db_session.add(UserRole(user_id=someone, role=UserRoleType.pro))
    db_session.commit()
    kwargs = {"headers": {"X-User-Id": str(someone)}}
    if body is not None:
        kwargs["json"] = body
    resp = getattr(client, method)(path, **kwargs)
    assert resp.status_code == 403, f"{method} {path}: {resp.status_code}"


def test_every_change_is_audited_with_who_and_from_what_to_what(client, db_session, niches, store):
    first = _ready(client, store)
    _attach(client, "weddings", first)
    second = _ready(client, store)
    _attach(client, "weddings", second)
    client.patch("/v1/admin/niche-banners/weddings/image", json={"alt_text": "New words"}, headers=ADMIN)
    client.post("/v1/admin/niche-banners/weddings/image/revert", headers=ADMIN)
    client.delete("/v1/admin/niche-banners/weddings/image", headers=ADMIN)
    client.patch("/v1/admin/niche-banners/weddings", json={"banner_style": "text", "banner_tagline": "Hi"}, headers=ADMIN)

    logs = db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_type == "niche_banner").order_by(AdminAuditLog.created_at)
    ).scalars().all()
    actions = [log.action for log in logs]
    assert actions == [
        "niche_banner_set", "niche_banner_set", "niche_banner_edited", "niche_banner_reverted",
        "niche_banner_removed", "niche_banner_style_changed",
    ]
    assert all(str(log.actor_user_id) == ADMIN["X-User-Id"] for log in logs)
    replaced = logs[1].meta
    assert replaced["from"]["media_asset_id"] == first and replaced["to"]["media_asset_id"] == second
    edited = logs[2].meta
    assert edited["alt_text"] == {"from": "A couple walking out of a church", "to": "New words"}
    style = logs[5].meta
    assert style["banner_style"] == {"from": "image", "to": "text"}


def test_a_banner_record_points_at_its_niche(client, db_session, niches, store):
    _attach(client, "weddings", _ready(client, store))
    banner = db_session.execute(select(NicheBanner)).scalar_one()
    assert banner.niche.slug == "weddings"


# --- The initial images go in the same way an admin's do. ---


def test_the_loader_uses_the_admin_upload_service_with_a_stock_record(db_session, niches, store):
    import importlib.util
    import pathlib

    spec = importlib.util.spec_from_file_location("load_niche_banners", pathlib.Path(__file__).parents[1] / "scripts" / "load_niche_banners.py")
    loader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loader)

    candidates = {
        "weddings": [{"choice": "weddings A", "pexels_id": 1, "photographer": "Ana Silva", "pexels_page": "https://www.pexels.com/photo/1/",
                      "pexels_alt": "A couple under an arch", "original": "https://images.pexels.com/photos/1/a.jpeg"}],
        "food": [{"choice": "food A", "pexels_id": 2, "photographer": "B", "pexels_page": "https://www.pexels.com/photo/2/",
                  "pexels_alt": "", "original": "https://images.pexels.com/photos/2/b.jpeg"}],
    }
    steps = loader.plan({"weddings": "A", "food": "text"}, candidates)
    admin = uuid.UUID(ADMIN["X-User-Id"])

    sent = []
    dry = loader.load(db_session, steps, admin_user_id=admin, apply=False, fetch=lambda url: _image(), send=lambda *a: sent.append(a))
    assert sent == [] and db_session.execute(select(NicheBanner)).first() is None, "a dry run changed something"
    assert dry == ["weddings: weddings A - Pexels 1 by Ana Silva", "food: Text only"]

    def send(url, headers, payload):
        sent.append((url, payload))
        # The browser's part: the bytes land under the presigned key.
        started_key = next(o.storage_key for o in db_session.execute(select(MediaObject)).scalars())
        store.objects[started_key] = payload

    loader.load(db_session, steps, admin_user_id=admin, apply=True, fetch=lambda url: _image(), send=send)
    banner = db_session.execute(select(NicheBanner)).scalar_one()
    assert (banner.source, banner.credit, banner.source_url) == ("stock", "Ana Silva", "https://www.pexels.com/photo/1/")
    assert "pexels" in banner.licence.lower()
    assert banner.alt_text == "A couple under an arch"
    food = db_session.execute(select(Niche).where(Niche.slug == "food")).scalar_one()
    assert food.banner_style == "text"
    assert len(sent) == 1 and sent[0][0].startswith("https://"), "the image went up through a presigned PUT"
