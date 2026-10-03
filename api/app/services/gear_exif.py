"""What a RAW file says about the camera and lens that made it.

Reads headers only - no image decode, no libraw, no subprocess. Maker notes
are read too: several makers keep their body serial there (a Nikon D850 has it
nowhere else) and Nikon keeps the lens's focal and aperture range there, so
switching them off left the fallbacks below unable to ever fire.

Two containers exifread cannot open are unwrapped first:

  - Canon CR3 is an ISO-BMFF file, not a TIFF. The EXIF lives in three small
    TIFF streams (CMT1..CMT3) inside a Canon `uuid` box in `moov`, which ends
    within the first ~35 KB.
  - Fujifilm RAF is a proprietary wrapper around a full JPEG whose offset is
    stored at byte 84; the JPEG carries the EXIF.

Everything else the maker calls RAW is a TIFF underneath (ARW, NEF, CR2, DNG,
RW2) and needs no help. Every expectation here was read off a real file; the
tests in test_gear_exif_real_files.py use header slices of them.

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

import io
import struct
from dataclasses import dataclass
from decimal import Decimal
from fractions import Fraction
from typing import Any, Iterator

import exifread

#: How much of a file to read. Every real file tried needed under 64 KB (a CR3's
#: metadata ends by ~35 KB); a megabyte leaves generous room for the makers not
#: yet tried, and never touches the image payload - a 60 MB RAW costs the same
#: as a small JPEG.
HEADER_READ_BYTES = 1024 * 1024

#: Canon's `uuid` box inside a CR3's `moov`, which holds the CMT boxes.
_CANON_UUID = bytes.fromhex("85c0b687820f11e08111f4ce462b6a48")

#: Where a RAF stores the offset of the JPEG it wraps (big-endian u32).
_RAF_JPEG_OFFSET = 84


class ExifUnreadable(Exception):
    """The file carried no usable EXIF at all."""


_PREFIXES = ("EXIF", "Image", "MakerNote")


def _tag(streams: list[dict[str, Any]], name: str, prefixes: tuple[str, ...] = _PREFIXES) -> Any:
    """The first stream's value for `name`, under whichever IFD wrote it.

    A CR3's EXIF IFD is a TIFF stream of its own, so exifread reports its
    fields as "Image BodySerialNumber" where a JPEG gives "EXIF
    BodySerialNumber". The IFD a tag sits in is an accident of the container,
    not something this needs to know.
    """
    for prefix in prefixes:
        for tags in streams:
            value = tags.get(f"{prefix} {name}")
            if value is not None:
                return value
    return None


def _text(streams: list[dict[str, Any]], name: str, prefixes: tuple[str, ...] = _PREFIXES) -> str | None:
    value = _tag(streams, name, prefixes)
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


def _boxes(data: bytes, start: int, end: int) -> Iterator[tuple[bytes, int, int]]:
    """ISO-BMFF boxes in [start, end): (type, payload start, box end).

    A box that claims to run past `end` is clamped, because the bytes this
    sees are a header slice and the file is meant to be cut off.
    """
    pos = start
    while pos + 8 <= end:
        size, kind = struct.unpack(">I4s", data[pos : pos + 8])
        header = 8
        if size == 1:
            if pos + 16 > end:
                return
            size = struct.unpack(">Q", data[pos + 8 : pos + 16])[0]
            header = 16
        elif size == 0:
            size = end - pos
        if size < header:
            return
        yield kind, pos + header, min(pos + size, end)
        pos += size


def _cr3_streams(data: bytes) -> list[bytes]:
    for kind, start, end in _boxes(data, 0, len(data)):
        if kind != b"moov":
            continue
        for inner, inner_start, inner_end in _boxes(data, start, end):
            if inner == b"uuid" and data[inner_start : inner_start + 16] == _CANON_UUID:
                return [
                    data[s : e]
                    for kind3, s, e in _boxes(data, inner_start + 16, inner_end)
                    if kind3 in (b"CMT1", b"CMT2", b"CMT3")
                ]
    return []


def _parse(blob: bytes) -> dict[str, Any]:
    # details=True: maker notes carry the body serial on Nikon and the lens
    # range on Nikon. strict=False so a truncated slice yields what it holds.
    return exifread.process_file(io.BytesIO(blob), details=True, strict=False)


def _streams(data: bytes) -> list[dict[str, Any]]:
    """Every metadata stream this file holds, parsed."""
    if data[4:12] == b"ftypcrx ":
        return [_parse(blob) for blob in _cr3_streams(data)]
    if data[:15] == b"FUJIFILMCCD-RAW":
        offset = struct.unpack(">I", data[_RAF_JPEG_OFFSET : _RAF_JPEG_OFFSET + 4])[0]
        return [_parse(data[offset:])] if 0 < offset < len(data) else []
    return [_parse(data)]


def _positive(value: Decimal | None) -> Decimal | None:
    """Canon writes 0 for a lens's maximum aperture, meaning "not recorded".

    Left as a number, two zeroes compare equal and a variable-aperture zoom
    reads as constant-aperture - the exact opposite of the truth, and the one
    mistake this check exists to prevent.
    """
    return value if value is not None and value > 0 else None


def read_exif(data: bytes) -> ExifFacts:
    """Pull the equipment facts out of a RAW or JPEG header."""
    streams = [tags for tags in _streams(data) if tags]
    if not streams:
        raise ExifUnreadable("no EXIF headers found in this file")

    # Standard LensSpecification first; Nikon's maker-note range is the same
    # four numbers for bodies that do not write the standard tag.
    spec = _ratios(_tag(streams, "LensSpecification", ("EXIF", "Image"))) or _ratios(
        _tag(streams, "LensMinMaxFocalMaxAperture", ("MakerNote",))
    )
    fnumber = _tag(streams, "FNumber", ("EXIF", "Image"))
    aperture = _ratios(fnumber)

    def _one(value: Any) -> Decimal | None:
        values = getattr(value, "values", None)
        if not values:
            return None
        try:
            return Decimal(str(float(Fraction(values[0].num, values[0].den))))
        except (AttributeError, ZeroDivisionError, ValueError):
            return None

    facts = ExifFacts(
        make=_text(streams, "Make", ("Image",)),
        model=_text(streams, "Model", ("Image",)),
        # Standard field first; a maker-note serial for bodies that keep it
        # only there. Best effort: exifread reads the common ones and not the
        # obscure ones - Sony's is encrypted and is not read at all.
        body_serial=(
            _text(streams, "BodySerialNumber", ("EXIF", "Image"))
            or _text(streams, "SerialNumber", ("MakerNote",))
            or _text(streams, "InternalSerialNumber", ("MakerNote",))
        ),
        lens_model=_text(streams, "LensModel", ("EXIF", "Image")),
        lens_serial=_text(streams, "LensSerialNumber", ("EXIF", "Image")),
        min_focal_mm=_positive(spec[0]) if spec else None,
        max_focal_mm=_positive(spec[1]) if spec else None,
        max_aperture_at_min_focal=_positive(spec[2]) if spec else None,
        max_aperture_at_max_focal=_positive(spec[3]) if spec else None,
        shot_aperture=_one(fnumber) if aperture is None else aperture[0],
        shot_at=_text(streams, "DateTimeOriginal", ("EXIF", "Image")),
    )

    if facts.make is None and facts.model is None:
        raise ExifUnreadable("EXIF present but names no camera")
    return facts
