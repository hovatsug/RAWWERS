"""What a RAW file says about the camera and lens that made it.

Reads standard EXIF headers only. No maker notes, no image decode - the
headers carry everything this needs, and parsing them does not require
libraw or a subprocess.

Two things worth knowing about what EXIF can and cannot prove:

**Sensor size is not in EXIF.** No tag states it. `FocalPlaneXResolution`
can imply it for some makers and is absent or misleading for others, so the
body is identified by model name and looked up in a reference table instead.

**Aperture type is in EXIF, once.** `LensSpecification` carries four values -
shortest focal, longest focal, and the widest aperture available at each end.
That distinguishes a prime, a constant-aperture zoom and a variable one from
a single frame, which `FNumber` alone cannot: an f/3.5-5.6 zoom shot at 3.5
reports the same number as an f/2.8 lens stopped down.
"""
from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal
from fractions import Fraction
from typing import Any

import exifread

#: How much of the file to read. EXIF lives in the header, so this never
#: touches the image payload - a 60MB RAW costs the same as a small JPEG.
_READ_TAGS = (
    "Image Make",
    "Image Model",
    "EXIF BodySerialNumber",
    "EXIF LensModel",
    "EXIF LensMake",
    "EXIF LensSerialNumber",
    "EXIF LensSpecification",
    "EXIF FNumber",
    "EXIF FocalLength",
    "EXIF DateTimeOriginal",
    "MakerNote SerialNumber",
    "MakerNote InternalSerialNumber",
)


class ExifUnreadable(Exception):
    """The file carried no usable EXIF at all."""


def _text(tags: dict[str, Any], key: str) -> str | None:
    value = tags.get(key)
    if value is None:
        return None
    text = str(value).strip()
    # Some bodies write a field of zeroes or spaces rather than omitting it.
    if not text or set(text) <= {"0", " ", "-"}:
        return None
    return text


def _ratios(value: Any) -> list[Decimal] | None:
    """A LensSpecification's four rationals, as decimals."""
    values = getattr(value, "values", None)
    if not values or len(values) < 4:
        return None
    out: list[Decimal] = []
    for item in values[:4]:
        try:
            out.append(Decimal(str(float(Fraction(item.num, item.den)))))
        except (AttributeError, ZeroDivisionError, ValueError):
            return None
    return out


@dataclass(frozen=True)
class ExifFacts:
    """What one frame states about the equipment that made it."""

    make: str | None
    model: str | None

    #: Absent on plenty of real bodies. A firmware setting, not a fault, and
    #: never a reason on its own to conclude the photographer is lying.
    body_serial: str | None

    lens_model: str | None
    lens_serial: str | None

    #: From LensSpecification. All None when the tag is absent, which is the
    #: case the lens reference table exists to cover.
    min_focal_mm: Decimal | None
    max_focal_mm: Decimal | None
    max_aperture_at_min_focal: Decimal | None
    max_aperture_at_max_focal: Decimal | None

    shot_aperture: Decimal | None
    shot_at: str | None

    @property
    def is_prime(self) -> bool | None:
        """A single focal length. None when the tag was absent."""
        if self.min_focal_mm is None or self.max_focal_mm is None:
            return None
        return self.min_focal_mm == self.max_focal_mm

    @property
    def is_fixed_aperture(self) -> bool | None:
        """Holds one maximum aperture across its whole range.

        True for a prime and for a constant-aperture zoom, which is exactly
        the set that qualifies. None when LensSpecification was absent - not
        False, because "we could not tell" and "it varies" are different
        answers and only one of them should reject a photographer.
        """
        wide, long = self.max_aperture_at_min_focal, self.max_aperture_at_max_focal
        if wide is None or long is None:
            return None
        return wide == long


def read_exif(data: bytes) -> ExifFacts:
    """Pull the equipment facts out of a RAW or JPEG header."""
    import io

    tags = exifread.process_file(io.BytesIO(data), details=False, strict=False)
    if not tags:
        raise ExifUnreadable("no EXIF headers found in this file")

    spec = _ratios(tags.get("EXIF LensSpecification"))
    aperture = _ratios(tags.get("EXIF FNumber"))

    def _one(value: Any) -> Decimal | None:
        values = getattr(value, "values", None)
        if not values:
            return None
        try:
            return Decimal(str(float(Fraction(values[0].num, values[0].den))))
        except (AttributeError, ZeroDivisionError, ValueError):
            return None

    facts = ExifFacts(
        make=_text(tags, "Image Make"),
        model=_text(tags, "Image Model"),
        # Falls back to the maker-note serials some bodies use instead. Best
        # effort: exifread reads the common ones and not the obscure ones.
        body_serial=(
            _text(tags, "EXIF BodySerialNumber")
            or _text(tags, "MakerNote SerialNumber")
            or _text(tags, "MakerNote InternalSerialNumber")
        ),
        lens_model=_text(tags, "EXIF LensModel"),
        lens_serial=_text(tags, "EXIF LensSerialNumber"),
        min_focal_mm=spec[0] if spec else None,
        max_focal_mm=spec[1] if spec else None,
        max_aperture_at_min_focal=spec[2] if spec else None,
        max_aperture_at_max_focal=spec[3] if spec else None,
        shot_aperture=_one(tags.get("EXIF FNumber")) if aperture is None else aperture[0],
        shot_at=_text(tags, "EXIF DateTimeOriginal"),
    )

    if facts.make is None and facts.model is None:
        raise ExifUnreadable("EXIF present but names no camera")
    return facts
