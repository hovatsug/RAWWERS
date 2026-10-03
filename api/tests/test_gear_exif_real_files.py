"""The EXIF reader, against what real cameras actually write.

The first version was tested only against JPEGs that Pillow synthesised, and
those tests passed. Real files then showed, in one afternoon:

  - Canon CR3 and Fujifilm RAF unreadable outright (exifread has no CR3 support
    and does not look inside a RAF);
  - every Sony body reporting no serial, because `details=False` switched off
    the maker-note parsing the fallback depended on;
  - a Nikon D850 with no lens data, which Nikon keeps in the maker note;
  - Canon writing `0` for a lens's maximum aperture, so a variable-aperture zoom
    compared equal to itself and passed as fixed.

Each expectation below was read off the real file. The fixtures are header
slices; see fixtures/raw/README.md for where they came from.
"""
from decimal import Decimal
from pathlib import Path

import pytest
from app.services.gear_exif import ExifUnreadable, read_exif

FIXTURES = Path(__file__).parent / "fixtures" / "raw"


def _read(name: str):
    return read_exif((FIXTURES / name).read_bytes())


# name, make, model, body serial, lens model, min focal, max focal, wide max aperture, long max aperture
REAL_FILES = [
    ("canon_eos_r5.cr3.head", "Canon", "Canon EOS R5", "083023000411",
     "50mm F1.4 DG HSM | Art 014", "50", "50", None, None),
    ("canon_eos_r.cr3.head", "Canon", "Canon EOS R", "033021004689",
     "RF85mm F2 MACRO IS STM", "85", "85", None, None),
    ("sony_ilce7m4.arw.head", "SONY", "ILCE-7M4", None,
     "FE 50mm F2.5 G", "50", "50", "2.5", "2.5"),
    ("sony_ilce7m3.arw.head", "SONY", "ILCE-7M3", None,
     "FE 16-35mm F2.8 GM", "16", "35", "2.8", "2.8"),
    ("nikon_d850.nef.head", "NIKON CORPORATION", "NIKON D850", "6003734",
     None, "35", "35", "1.4", "1.4"),
    ("nikon_z6.nef.head", "NIKON CORPORATION", "NIKON Z 6", "6035906",
     "NIKKOR Z 24-70mm f/4 S", "24", "70", "4", "4"),
    ("panasonic_dcs5.rw2.head", "Panasonic", "DC-S5", "WJ1CA001515",
     None, None, None, None, None),
    ("fujifilm_xt4.raf.head", "FUJIFILM", "X-T4", "0BQ00325",
     "XF16-55mmF2.8 R LM WR", "16", "55", "2.8", "2.8"),
]


def _dec(value):
    return None if value is None else Decimal(value)


@pytest.mark.parametrize(
    "name,make,model,serial,lens,min_focal,max_focal,wide,long_", REAL_FILES, ids=[r[0] for r in REAL_FILES]
)
def test_a_real_file_yields_what_the_camera_wrote(name, make, model, serial, lens, min_focal, max_focal, wide, long_):
    facts = _read(name)

    assert facts.make == make
    assert facts.model == model
    assert facts.body_serial == serial
    assert facts.lens_model == lens
    assert facts.min_focal_mm == _dec(min_focal)
    assert facts.max_focal_mm == _dec(max_focal)
    assert facts.max_aperture_at_min_focal == _dec(wide)
    assert facts.max_aperture_at_max_focal == _dec(long_)


def test_a_maker_note_serial_is_used_when_the_standard_field_is_absent():
    """The Nikon D850 keeps its serial only in the maker note. With
    `details=False` the fallback in the reader could never fire."""
    assert _read("nikon_d850.nef.head").body_serial == "6003734"


def test_a_maker_note_lens_specification_stands_in_when_exif_has_none():
    """The D850 writes no EXIF LensSpecification. Nikon's own
    LensMinMaxFocalMaxAperture is the same four numbers."""
    facts = _read("nikon_d850.nef.head")
    assert facts.is_prime is True
    assert facts.is_fixed_aperture is True


def test_a_maximum_aperture_of_zero_means_unknown_not_a_value():
    """Canon writes 0 for both apertures. Read as numbers they are equal, so a
    24-70 zoom - which has no single maximum aperture - would look fixed."""
    facts = _read("canon_eos_r5.cr3.head")

    assert facts.max_aperture_at_min_focal is None
    assert facts.max_aperture_at_max_focal is None
    # Unknown, not "fixed": only a person or a lens table may decide that.
    assert facts.is_fixed_aperture is None
    # A prime is still a prime - that comes from the focal length.
    assert facts.is_prime is True


def test_a_canon_zoom_with_zero_apertures_is_not_reported_as_fixed():
    """The same rule, on a frame shaped like a real Canon zoom rather than the
    prime the fixture happens to hold."""
    import io

    from PIL import Image
    from PIL.TiffImagePlugin import IFDRational

    exif = Image.Exif()
    exif[0x010F], exif[0x0110] = "Canon", "Canon EOS R5"
    exif[0x8769] = {
        0xA431: "083023000411",
        0xA434: "RF24-105mm F4-7.1 IS STM",
        0xA432: (IFDRational(24, 1), IFDRational(105, 1), IFDRational(0, 1), IFDRational(0, 1)),
    }
    buffer = io.BytesIO()
    Image.new("RGB", (8, 8)).save(buffer, format="JPEG", exif=exif)

    facts = read_exif(buffer.getvalue())

    assert facts.is_prime is False
    assert facts.is_fixed_aperture is None, "a variable-aperture zoom read as fixed because 0 == 0"


def test_a_file_with_no_camera_data_is_unreadable_rather_than_empty():
    with pytest.raises(ExifUnreadable):
        read_exif(b"not a photograph at all" * 100)


def test_a_truncated_cr3_that_lost_its_metadata_is_unreadable():
    """A CR3 cut off before the moov box has ended still says what it can;
    one cut off before it has begun says nothing."""
    data = (FIXTURES / "canon_eos_r5.cr3.head").read_bytes()
    with pytest.raises(ExifUnreadable):
        read_exif(data[:24])
