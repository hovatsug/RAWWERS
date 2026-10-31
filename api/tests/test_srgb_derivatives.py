"""Previews are made in sRGB, whatever profile the original carries.

Owner's decision 6. Derivatives are saved without a colour profile, which
browsers and phones read as sRGB; an Adobe RGB export read that way looks
washed out in the client's watermarked previews. The worker converts any
other embedded profile to sRGB first. The original - the client's final
download - is never rewritten.

The wide-gamut profile is built here from Adobe RGB (1998)'s published
primaries (a matrix/TRC ICC v2 profile), so no third-party profile file is
needed. Storage is a fake: no network in tests.
"""
import io
import struct
import uuid

import pytest
from PIL import Image, ImageCms

import app.tasks.media_tasks as tasks
from app.models.media import (
    MediaAsset,
    MediaKind,
    MediaObject,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
    ObjectStatus,
)


def _s15(x: float) -> bytes:
    return struct.pack(">i", round(x * 65536))


def _xyz(x, y, z) -> bytes:
    return b"XYZ " + b"\0" * 4 + _s15(x) + _s15(y) + _s15(z)


def _wide_rgb_profile() -> bytes:
    """An ICC v2 RGB display profile with Adobe RGB (1998) primaries, D50
    adapted, and a 2.2 gamma: enough for LittleCMS to convert from."""
    desc_text = b"Wide RGB (test, Adobe RGB primaries)\0"
    tags = {
        b"desc": b"desc" + b"\0" * 4 + struct.pack(">I", len(desc_text)) + desc_text + b"\0" * 4 + b"\0" * 4 + b"\0" * 3 + b"\0" * 67,
        b"wtpt": _xyz(0.9642, 1.0, 0.8249),
        b"rXYZ": _xyz(0.6097, 0.3111, 0.0195),
        b"gXYZ": _xyz(0.2052, 0.6257, 0.0609),
        b"bXYZ": _xyz(0.1492, 0.0632, 0.7446),
        b"rTRC": b"curv" + b"\0" * 4 + struct.pack(">IH", 1, 0x0233) + b"\0\0",
        b"cprt": b"text" + b"\0" * 4 + b"No copyright, test data\0",
    }
    tags[b"gTRC"] = tags[b"rTRC"]
    tags[b"bTRC"] = tags[b"rTRC"]
    order = [b"desc", b"wtpt", b"rXYZ", b"gXYZ", b"bXYZ", b"rTRC", b"gTRC", b"bTRC", b"cprt"]
    offset = 128 + 4 + 12 * len(order)
    table, data = b"", b""
    for sig in order:
        body = tags[sig]
        table += sig + struct.pack(">II", offset + len(data), len(body))
        data += body + b"\0" * (-len(body) % 4)
    size = offset + len(data)
    header = (
        struct.pack(">I", size) + b"\0" * 4 + struct.pack(">I", 0x02100000) + b"mntr" + b"RGB " + b"XYZ "
        + b"\0" * 12 + b"acsp" + b"\0" * 24 + struct.pack(">I", 0) + _s15(0.9642) + _s15(1.0) + _s15(0.8249) + b"\0" * 48
    )
    assert len(header) == 128
    return header + struct.pack(">I", len(order)) + table + data


WIDE = _wide_rgb_profile()
# A saturated green: where reading Adobe RGB as sRGB goes most visibly wrong.
COLOUR = (40, 170, 60)


def _jpeg(icc: bytes | None) -> bytes:
    buf = io.BytesIO()
    kwargs = {"icc_profile": icc} if icc else {}
    Image.new("RGB", (1200, 800), COLOUR).save(buf, "JPEG", quality=95, **kwargs)
    return buf.getvalue()


def _expected_srgb(colour) -> tuple[int, int, int]:
    pixel = Image.new("RGB", (1, 1), colour)
    srgb = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB"))
    converted = ImageCms.profileToProfile(
        pixel, ImageCms.ImageCmsProfile(io.BytesIO(WIDE)), srgb, renderingIntent=ImageCms.Intent.PERCEPTUAL, outputMode="RGB"
    )
    return converted.getpixel((0, 0))


def _close(a, b, tolerance=6) -> bool:
    return all(abs(x - y) <= tolerance for x, y in zip(a, b))


@pytest.fixture
def store(monkeypatch):
    objects: dict[str, bytes] = {}
    monkeypatch.setattr(tasks, "download_object_bytes", lambda key, max_bytes=0: objects[key])
    monkeypatch.setattr(tasks, "object_size", lambda key: len(objects[key]) if key in objects else None)
    monkeypatch.setattr(tasks, "upload_object_bytes", lambda key, payload, *_a, **_k: objects.__setitem__(key, payload))
    monkeypatch.setattr(tasks, "_watermark_text", lambda db, asset: "RAWWERS • Test")
    return objects


def _processed(db_session, store, blob: bytes) -> tuple[str, dict[str, bytes]]:
    owner = uuid.uuid4()
    key = f"users/{owner}/photos/{uuid.uuid4()}.jpg"
    store[key] = blob
    asset = MediaAsset(
        owner_user_id=owner,
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.processing,
        visibility=MediaVisibility.client_only,
        content_type="image/jpeg",
        byte_size=len(blob),
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    db_session.commit()
    tasks.process_photo_variants.push_request(retries=0)
    try:
        tasks.process_photo_variants.run(str(asset.id))
    finally:
        tasks.process_photo_variants.pop_request()
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset.id).status == MediaStatus.ready
    return key, store


def _thumbnail(store) -> Image.Image:
    (blob,) = [v for k, v in store.items() if k.endswith("_thumbnail.jpg")]
    return Image.open(io.BytesIO(blob))


def test_the_test_colour_really_shows_the_difference():
    # Guard on the test itself: were the conversion a no-op for this colour,
    # the tests below would pass against a worker that converts nothing.
    expected = _expected_srgb(COLOUR)
    assert not _close(expected, COLOUR, tolerance=15), expected


def test_a_wide_gamut_export_is_converted_to_srgb_for_its_previews(db_session, store):
    _, objects = _processed(db_session, store, _jpeg(WIDE))

    centre = _thumbnail(objects).convert("RGB").getpixel((100, 100))
    assert _close(centre, _expected_srgb(COLOUR)), f"thumbnail {centre}, sRGB would be {_expected_srgb(COLOUR)}"


@pytest.mark.parametrize("suffix", ["_watermark_preview.jpg", "_web_res.jpg", "_preview_watermarked.jpg"])
def test_every_derivative_is_in_srgb(db_session, store, suffix):
    _, objects = _processed(db_session, store, _jpeg(WIDE))
    matches = [v for k, v in objects.items() if k.endswith(suffix)]
    assert matches, f"no {suffix} made: {sorted(objects)}"
    corner = Image.open(io.BytesIO(matches[0])).convert("RGB").getpixel((5, 5))
    assert _close(corner, _expected_srgb(COLOUR), tolerance=8), corner


def test_the_original_is_never_rewritten(db_session, store):
    blob = _jpeg(WIDE)
    key, objects = _processed(db_session, store, blob)
    assert objects[key] == blob
    assert Image.open(io.BytesIO(objects[key])).info.get("icc_profile") == WIDE


@pytest.mark.parametrize("icc", [None, ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()], ids=["no-profile", "srgb"])
def test_srgb_and_untagged_photos_are_left_as_they_are(db_session, store, icc):
    _, objects = _processed(db_session, store, _jpeg(icc))
    assert _close(_thumbnail(objects).convert("RGB").getpixel((100, 100)), COLOUR)


def test_an_unreadable_profile_is_treated_as_none_not_a_failure(db_session, store):
    _, objects = _processed(db_session, store, _jpeg(b"not an icc profile at all, just bytes" * 4))
    assert _close(_thumbnail(objects).convert("RGB").getpixel((100, 100)), COLOUR)


def test_a_derivative_made_again_later_is_in_srgb_too(db_session, store):
    # The single-derivative tasks (a missing thumbnail remade on demand) read
    # the original through their own path; it converts the same way.
    key, objects = _processed(db_session, store, _jpeg(WIDE))
    for k in [k for k in objects if k.endswith("_thumbnail.jpg")]:
        del objects[k]
    (asset_id,) = [
        str(o.media_asset_id) for o in db_session.query(MediaObject).filter(MediaObject.storage_key == key)
    ]

    tasks.generate_thumbnail(asset_id)

    assert _close(_thumbnail(objects).convert("RGB").getpixel((100, 100)), _expected_srgb(COLOUR))
