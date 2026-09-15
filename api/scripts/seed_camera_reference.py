#!/usr/bin/env python3
"""Which camera models are full-frame.

An allowlist, not a denylist. Roughly ninety bodies covers everything
full-frame sold since 2005 across the seven makers that sell one; the crop
list runs to several hundred and would never be complete, so a model absent
from here is unknown rather than disqualified and routes to review.

Each body is listed under both the name EXIF usually writes and the name a
person would recognise, because they differ constantly: Sony writes
"ILCE-7M4" for what the box calls an A7 IV.

A handful of crop bodies are listed deliberately. They are the ones most
likely to be submitted in good faith by someone who does not know the
distinction, and naming them means that photographer gets told exactly why
rather than waiting in a review queue for a decision that was never in doubt.

    docker compose exec api python scripts/seed_camera_reference.py
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.gear_verification import (  # noqa: E402
    ApertureType,
    CameraModelReference,
    LensModelReference,
    SensorSize,
)
from app.services.gear_verify import normalise_model  # noqa: E402

FULL_FRAME: list[tuple[str, str, str]] = [
    # (make, EXIF model string, display name)
    ("Sony", "ILCE-7", "Sony A7"), ("Sony", "ILCE-7M2", "Sony A7 II"),
    ("Sony", "ILCE-7M3", "Sony A7 III"), ("Sony", "ILCE-7M4", "Sony A7 IV"),
    ("Sony", "ILCE-7M5", "Sony A7 V"),
    ("Sony", "ILCE-7R", "Sony A7R"), ("Sony", "ILCE-7RM2", "Sony A7R II"),
    ("Sony", "ILCE-7RM3", "Sony A7R III"), ("Sony", "ILCE-7RM4", "Sony A7R IV"),
    ("Sony", "ILCE-7RM5", "Sony A7R V"),
    ("Sony", "ILCE-7S", "Sony A7S"), ("Sony", "ILCE-7SM2", "Sony A7S II"),
    ("Sony", "ILCE-7SM3", "Sony A7S III"),
    ("Sony", "ILCE-7C", "Sony A7C"), ("Sony", "ILCE-7CM2", "Sony A7C II"),
    ("Sony", "ILCE-9", "Sony A9"), ("Sony", "ILCE-9M2", "Sony A9 II"),
    ("Sony", "ILCE-9M3", "Sony A9 III"), ("Sony", "ILCE-1", "Sony A1"),
    ("Canon", "Canon EOS 5D", "Canon EOS 5D"),
    ("Canon", "Canon EOS 5D Mark II", "Canon EOS 5D Mark II"),
    ("Canon", "Canon EOS 5D Mark III", "Canon EOS 5D Mark III"),
    ("Canon", "Canon EOS 5D Mark IV", "Canon EOS 5D Mark IV"),
    ("Canon", "Canon EOS 5DS", "Canon EOS 5DS"), ("Canon", "Canon EOS 5DS R", "Canon EOS 5DS R"),
    ("Canon", "Canon EOS 6D", "Canon EOS 6D"),
    ("Canon", "Canon EOS 6D Mark II", "Canon EOS 6D Mark II"),
    ("Canon", "Canon EOS-1D X", "Canon EOS-1D X"),
    ("Canon", "Canon EOS-1D X Mark II", "Canon EOS-1D X Mark II"),
    ("Canon", "Canon EOS-1D X Mark III", "Canon EOS-1D X Mark III"),
    ("Canon", "Canon EOS R", "Canon EOS R"), ("Canon", "Canon EOS RP", "Canon EOS RP"),
    ("Canon", "Canon EOS R3", "Canon EOS R3"), ("Canon", "Canon EOS R5", "Canon EOS R5"),
    ("Canon", "Canon EOS R5 Mark II", "Canon EOS R5 Mark II"),
    ("Canon", "Canon EOS R6", "Canon EOS R6"),
    ("Canon", "Canon EOS R6 Mark II", "Canon EOS R6 Mark II"),
    ("Canon", "Canon EOS R8", "Canon EOS R8"), ("Canon", "Canon EOS R1", "Canon EOS R1"),
    ("Nikon", "NIKON D610", "Nikon D610"), ("Nikon", "NIKON D700", "Nikon D700"),
    ("Nikon", "NIKON D750", "Nikon D750"), ("Nikon", "NIKON D780", "Nikon D780"),
    ("Nikon", "NIKON D800", "Nikon D800"), ("Nikon", "NIKON D800E", "Nikon D800E"),
    ("Nikon", "NIKON D810", "Nikon D810"), ("Nikon", "NIKON D850", "Nikon D850"),
    ("Nikon", "NIKON D4", "Nikon D4"), ("Nikon", "NIKON D4S", "Nikon D4S"),
    ("Nikon", "NIKON D5", "Nikon D5"), ("Nikon", "NIKON D6", "Nikon D6"),
    ("Nikon", "NIKON Z 5", "Nikon Z5"), ("Nikon", "NIKON Z 6", "Nikon Z6"),
    ("Nikon", "NIKON Z 6_2", "Nikon Z6 II"), ("Nikon", "NIKON Z 6_3", "Nikon Z6 III"),
    ("Nikon", "NIKON Z 7", "Nikon Z7"), ("Nikon", "NIKON Z 7_2", "Nikon Z7 II"),
    ("Nikon", "NIKON Z 8", "Nikon Z8"), ("Nikon", "NIKON Z 9", "Nikon Z9"),
    ("Nikon", "NIKON Z f", "Nikon Zf"),
    ("Panasonic", "DC-S1", "Panasonic S1"), ("Panasonic", "DC-S1R", "Panasonic S1R"),
    ("Panasonic", "DC-S1H", "Panasonic S1H"), ("Panasonic", "DC-S5", "Panasonic S5"),
    ("Panasonic", "DC-S5M2", "Panasonic S5 II"),
    ("Leica", "LEICA M10", "Leica M10"), ("Leica", "LEICA M11", "Leica M11"),
    ("Leica", "LEICA SL2", "Leica SL2"), ("Leica", "LEICA Q2", "Leica Q2"),
    ("Leica", "LEICA Q3", "Leica Q3"),
    ("Sigma", "SIGMA fp", "Sigma fp"), ("Sigma", "SIGMA fp L", "Sigma fp L"),
    ("Pentax", "PENTAX K-1", "Pentax K-1"), ("Pentax", "PENTAX K-1 Mark II", "Pentax K-1 II"),
]

MEDIUM_FORMAT: list[tuple[str, str, str]] = [
    ("Fujifilm", "GFX 50S", "Fujifilm GFX 50S"), ("Fujifilm", "GFX 50R", "Fujifilm GFX 50R"),
    ("Fujifilm", "GFX100", "Fujifilm GFX 100"), ("Fujifilm", "GFX100S", "Fujifilm GFX 100S"),
    ("Fujifilm", "GFX100 II", "Fujifilm GFX 100 II"),
    ("Hasselblad", "X1D II 50C", "Hasselblad X1D II"),
]

# Named so a photographer submitting one in good faith is told why, rather
# than waiting for a human to confirm what the table already knows.
COMMON_CROP: list[tuple[str, str, str]] = [
    ("Canon", "Canon EOS 90D", "Canon EOS 90D"), ("Canon", "Canon EOS 7D Mark II", "Canon EOS 7D Mark II"),
    ("Canon", "Canon EOS R7", "Canon EOS R7"), ("Canon", "Canon EOS R10", "Canon EOS R10"),
    ("Canon", "Canon EOS 250D", "Canon EOS 250D"),
    ("Nikon", "NIKON D500", "Nikon D500"), ("Nikon", "NIKON D7500", "Nikon D7500"),
    ("Nikon", "NIKON Z 50", "Nikon Z50"), ("Nikon", "NIKON Z fc", "Nikon Zfc"),
    ("Sony", "ILCE-6400", "Sony A6400"), ("Sony", "ILCE-6600", "Sony A6600"),
    ("Sony", "ILCE-6700", "Sony A6700"),
    ("Fujifilm", "X-T4", "Fujifilm X-T4"), ("Fujifilm", "X-T5", "Fujifilm X-T5"),
    ("Fujifilm", "X-H2", "Fujifilm X-H2"), ("Fujifilm", "X100V", "Fujifilm X100V"),
    ("OM Digital Solutions", "OM-1", "OM System OM-1"),
    ("Panasonic", "DC-GH6", "Panasonic GH6"),
]

# Only for bodies that omit LensSpecification. The frame answers this itself
# on anything modern, so this stays deliberately short rather than trying to
# be a catalogue of every lens ever made.
LENSES: list[tuple[str, str, str, ApertureType]] = [
    ("Canon", "EF24-70mm f/2.8L II USM", "Canon EF 24-70mm f/2.8L II", ApertureType.fixed_zoom),
    ("Canon", "EF70-200mm f/2.8L IS III USM", "Canon EF 70-200mm f/2.8L IS III", ApertureType.fixed_zoom),
    ("Canon", "RF24-70mm F2.8 L IS USM", "Canon RF 24-70mm f/2.8L", ApertureType.fixed_zoom),
    ("Canon", "EF50mm f/1.2L USM", "Canon EF 50mm f/1.2L", ApertureType.prime),
    ("Canon", "EF-S18-55mm f/3.5-5.6 IS STM", "Canon EF-S 18-55mm f/3.5-5.6", ApertureType.variable_zoom),
    ("Nikon", "24.0-70.0 mm f/2.8", "Nikon 24-70mm f/2.8", ApertureType.fixed_zoom),
    ("Nikon", "NIKKOR Z 50mm f/1.8 S", "Nikon Z 50mm f/1.8 S", ApertureType.prime),
    ("Nikon", "18.0-140.0 mm f/3.5-5.6", "Nikon 18-140mm f/3.5-5.6", ApertureType.variable_zoom),
    ("Sony", "FE 24-70mm F2.8 GM", "Sony FE 24-70mm f/2.8 GM", ApertureType.fixed_zoom),
    ("Sony", "FE 85mm F1.4 GM", "Sony FE 85mm f/1.4 GM", ApertureType.prime),
    ("Sony", "E PZ 16-50mm F3.5-5.6 OSS", "Sony E 16-50mm f/3.5-5.6", ApertureType.variable_zoom),
    ("Sigma", "35mm F1.4 DG HSM", "Sigma 35mm f/1.4 Art", ApertureType.prime),
    ("Tamron", "SP 24-70mm F/2.8 Di VC USD G2", "Tamron 24-70mm f/2.8 G2", ApertureType.fixed_zoom),
]


def main() -> int:
    assert_environment_is_seedable()
    db = SessionLocal()
    try:
        bodies = (
            [(mk, m, d, SensorSize.full_frame) for mk, m, d in FULL_FRAME]
            + [(mk, m, d, SensorSize.medium_format) for mk, m, d in MEDIUM_FORMAT]
            + [(mk, m, d, SensorSize.crop) for mk, m, d in COMMON_CROP]
        )
        created = updated = 0
        for make, model, display, sensor in bodies:
            key = normalise_model(model)
            row = db.get(CameraModelReference, key)
            if row is None:
                db.add(
                    CameraModelReference(
                        normalised_model=key, make=make, display_name=display, sensor_size=sensor
                    )
                )
                created += 1
            else:
                row.make, row.display_name, row.sensor_size = make, display, sensor
                updated += 1

        lens_created = lens_updated = 0
        for make, model, display, aperture in LENSES:
            key = normalise_model(model)
            row = db.get(LensModelReference, key)
            if row is None:
                db.add(
                    LensModelReference(
                        normalised_model=key, make=make, display_name=display, aperture_type=aperture
                    )
                )
                lens_created += 1
            else:
                row.make, row.display_name, row.aperture_type = make, display, aperture
                lens_updated += 1

        db.commit()
        total = db.execute(select(CameraModelReference)).scalars().all()
        full = [r for r in total if r.sensor_size == SensorSize.full_frame]
        print(f"camera models: {len(total)} ({len(full)} full-frame), created {created}, updated {updated}")
        print(f"lens models  : created {lens_created}, updated {lens_updated}")
        return 0
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
