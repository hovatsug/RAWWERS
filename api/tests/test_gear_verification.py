"""Gear as a real, verified prerequisite.

The floor is one full-frame body and one qualifying lens - a prime, or a zoom
that holds its maximum aperture across its range. Niches whose work is
studio-lit by definition add lighting.

Fixtures are JPEGs carrying real EXIF rather than RAW files, because the
verification reads headers and a JPEG header is the same header. Shipping a
60MB CR2 into the repository to prove that would test the file format rather
than the rule.
"""
import io
import uuid
from decimal import Decimal

import pytest
from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gear_verification import (
    ApertureType,
    GearVerification,
    SensorSize,
    VerificationStatus,
)
from app.models.repair import GearCategory
from app.services.gear_floor import evaluate_gear_floor
from app.services.gear_verify import normalise_model, release_verification, verify_from_raw
from PIL import Image
from PIL.TiffImagePlugin import IFDRational


def _frame(
    *,
    make: str = "Sony",
    model: str = "ILCE-7M4",
    serial: str | None = "SER123456",
    lens: str | None = None,
    lens_spec: tuple[float, float, float, float] | None = None,
) -> bytes:
    """A photograph carrying the EXIF a real camera would write."""
    exif = Image.Exif()
    exif[0x010F] = make
    exif[0x0110] = model
    sub: dict = {}
    if serial:
        sub[0xA431] = serial
    if lens:
        sub[0xA434] = lens
    if lens_spec:
        sub[0xA432] = tuple(IFDRational(int(v * 100), 100) for v in lens_spec)
    exif[0x8769] = sub

    buffer = io.BytesIO()
    Image.new("RGB", (8, 8), (40, 40, 40)).save(buffer, format="JPEG", exif=exif)
    return buffer.getvalue()


def _pro(db_session) -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=user_id, display_name="Gear Test"))
    db_session.flush()
    return user_id


@pytest.fixture()
def reference(db_session):
    """The reference rows these tests look things up in."""
    from app.models.gear_verification import CameraModelReference, LensModelReference

    for model, display, sensor in [
        ("ILCE-7M4", "Sony A7 IV", SensorSize.full_frame),
        ("ILCE-6700", "Sony A6700", SensorSize.crop),
    ]:
        db_session.merge(
            CameraModelReference(
                normalised_model=normalise_model(model),
                make="Sony",
                display_name=display,
                sensor_size=sensor,
            )
        )
    db_session.merge(
        LensModelReference(
            normalised_model=normalise_model("Vintage 50mm"),
            make="Other",
            display_name="Vintage 50mm",
            aperture_type=ApertureType.prime,
        )
    )
    db_session.flush()


def _body(db_session, pro_id, **kwargs) -> GearVerification:
    return verify_from_raw(
        db_session, pro_user_id=pro_id, category=GearCategory.camera_body, data=_frame(**kwargs)
    )


def _lens(db_session, pro_id, **kwargs) -> GearVerification:
    return verify_from_raw(
        db_session, pro_user_id=pro_id, category=GearCategory.lens, data=_frame(**kwargs)
    )


# ---------------------------------------------------------------------------
# The floor.
# ---------------------------------------------------------------------------


def test_full_frame_body_and_a_fixed_zoom_passes(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 24-70mm F2.8 GM", lens_spec=(24, 70, 2.8, 2.8))

    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.has_full_frame_body
    assert floor.has_qualifying_lens
    assert floor.meets_floor
    assert floor.missing == []


def test_a_prime_qualifies_too(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    lens = _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))

    assert lens.aperture_type == ApertureType.prime
    assert evaluate_gear_floor(db_session, pro_id).meets_floor


def test_a_crop_body_is_rejected_whatever_the_lens(db_session, reference):
    pro_id = _pro(db_session)
    body = _body(db_session, pro_id, model="ILCE-6700", serial="CROP1")
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))

    assert body.status == VerificationStatus.rejected
    assert "not a full-frame body" in body.review_reason
    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.has_full_frame_body is False
    assert floor.meets_floor is False
    assert "full_frame_body" in floor.missing


def test_a_variable_zoom_alone_does_not_qualify(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    lens = _lens(db_session, pro_id, lens="E PZ 16-50mm F3.5-5.6 OSS", lens_spec=(16, 50, 3.5, 5.6))

    assert lens.aperture_type == ApertureType.variable_zoom
    assert lens.status == VerificationStatus.rejected
    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.has_qualifying_lens is False
    assert floor.meets_floor is False


def test_one_qualifying_lens_is_enough_alongside_consumer_glass(db_session, reference):
    """A photographer is not disqualified for also owning a kit zoom."""
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="E PZ 16-50mm F3.5-5.6 OSS", lens_spec=(16, 50, 3.5, 5.6))
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))

    assert evaluate_gear_floor(db_session, pro_id).meets_floor


# ---------------------------------------------------------------------------
# Exclusivity.
# ---------------------------------------------------------------------------


def test_a_second_account_cannot_claim_the_same_body(db_session, reference):
    first = _pro(db_session)
    _body(db_session, first, serial="SHARED-STUDIO-1")
    db_session.flush()

    second = _pro(db_session)
    with pytest.raises(APIError) as caught:
        _body(db_session, second, serial="SHARED-STUDIO-1")
    assert caught.value.status_code == 409
    assert "already registered" in caught.value.message


def test_releasing_gear_frees_its_serial_for_the_next_owner(db_session, reference):
    """Selling a camera has to work. A permanent claim would make the platform
    a reason not to sell equipment."""
    seller = _pro(db_session)
    row = _body(db_session, seller, serial="SOLD-ON-1")
    db_session.flush()

    release_verification(db_session, pro_user_id=seller, verification_id=row.id)
    db_session.flush()

    buyer = _pro(db_session)
    claimed = _body(db_session, buyer, serial="SOLD-ON-1")
    assert claimed.status == VerificationStatus.verified


def test_removing_a_body_drops_the_photographer_below_the_floor(db_session, reference):
    pro_id = _pro(db_session)
    body = _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))
    assert evaluate_gear_floor(db_session, pro_id).meets_floor

    release_verification(db_session, pro_user_id=pro_id, verification_id=body.id)
    db_session.flush()

    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.meets_floor is False
    assert floor.missing == ["full_frame_body"]


# ---------------------------------------------------------------------------
# The two things that route to a human rather than a verdict.
# ---------------------------------------------------------------------------


def test_an_unknown_model_waits_for_review_rather_than_being_rejected(db_session, reference):
    """New or unusual, not disqualified. Rejecting would turn away a real
    photographer for owning something the table has not heard of."""
    pro_id = _pro(db_session)
    row = _body(db_session, pro_id, model="ILCE-9M4", serial="FUTURE-1")

    assert row.status == VerificationStatus.pending_review
    assert "not in our reference list" in row.review_reason
    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.has_full_frame_body is False, "an unreviewed claim counted toward the floor"
    assert floor.awaiting_review == 1


def test_a_body_with_no_serial_waits_for_review(db_session, reference):
    """A firmware setting is not grounds to refuse somebody. The exclusivity
    rule gets a narrow, recorded exception instead."""
    pro_id = _pro(db_session)
    row = _body(db_session, pro_id, serial=None)

    assert row.status == VerificationStatus.pending_review
    assert "no serial number" in row.review_reason
    assert row.serial_number is None


def test_a_lens_the_frame_cannot_describe_falls_back_to_the_table(db_session, reference):
    """Older bodies omit LensSpecification. The reference table exists for
    exactly those, rather than for every lens ever made."""
    pro_id = _pro(db_session)
    row = _lens(db_session, pro_id, lens="Vintage 50mm", lens_spec=None)

    assert row.aperture_type == ApertureType.prime
    assert row.status == VerificationStatus.verified


def test_a_lens_that_is_neither_described_nor_listed_waits_for_review(db_session, reference):
    pro_id = _pro(db_session)
    row = _lens(db_session, pro_id, lens="Unknown 28mm", lens_spec=None)

    assert row.status == VerificationStatus.pending_review
    assert evaluate_gear_floor(db_session, _pro_of(row)).has_qualifying_lens is False


def _pro_of(row: GearVerification) -> uuid.UUID:
    return row.pro_user_id


# ---------------------------------------------------------------------------
# Lighting, for the niches that need it.
# ---------------------------------------------------------------------------


def test_a_wedding_photographer_needs_lighting(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))

    floor = evaluate_gear_floor(db_session, pro_id, niche_slugs=["weddings"])
    assert floor.lighting_required
    assert floor.meets_floor is False
    assert floor.missing == ["lighting"]


def test_a_portrait_photographer_does_not(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))

    floor = evaluate_gear_floor(db_session, pro_id, niche_slugs=["portraits"])
    assert floor.lighting_required is False
    assert floor.meets_floor


def test_lighting_satisfies_the_niches_that_require_it(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))
    verify_from_raw(
        db_session,
        pro_user_id=pro_id,
        category=GearCategory.lighting,
        data=_frame(serial="LIGHT-1"),
    )

    assert evaluate_gear_floor(db_session, pro_id, niche_slugs=["weddings", "food"]).meets_floor


def test_model_names_normalise_across_the_spellings_exif_writes(db_session):
    assert normalise_model("ILCE-7M4") == normalise_model("ilce 7m4") == normalise_model("ILCE7M4 ")
    assert normalise_model(None) == ""


def test_lighting_is_recorded_as_declared_not_verified(db_session, reference):
    """The one honesty-based piece of an otherwise proven gate.

    Nothing in a photograph identifies the strobe that lit it, so a lighting
    claim is the photographer's word. It is accepted, and it is kept in a
    different state from the EXIF checks so no screen can present the two with
    equal weight.
    """
    pro_id = _pro(db_session)
    row = verify_from_raw(
        db_session,
        pro_user_id=pro_id,
        category=GearCategory.lighting,
        data=_frame(serial="LIGHT-9"),
    )

    assert row.status == VerificationStatus.declared
    assert row.status != VerificationStatus.verified
    assert "cannot be checked from a photo" in row.review_reason


def test_a_declared_body_would_not_count_toward_the_floor(db_session, reference):
    """Only lighting may be declared. If the declared state ever leaked onto a
    body or lens, it must not satisfy the requirement those have to prove."""
    pro_id = _pro(db_session)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))
    row = _body(db_session, pro_id)
    row.status = VerificationStatus.declared
    db_session.flush()

    floor = evaluate_gear_floor(db_session, pro_id)
    assert floor.has_full_frame_body is False
    assert floor.meets_floor is False


def test_the_floor_reports_that_its_lighting_was_only_declared(db_session, reference):
    pro_id = _pro(db_session)
    _body(db_session, pro_id)
    _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))
    verify_from_raw(
        db_session, pro_user_id=pro_id, category=GearCategory.lighting, data=_frame(serial="L-2")
    )

    floor = evaluate_gear_floor(db_session, pro_id, niche_slugs=["weddings"])
    assert floor.meets_floor
    assert floor.lighting_is_declared is True, (
        "a screen reading this could present declared lighting as proven"
    )


# ---------------------------------------------------------------------------
# The three gates.
#
# Gear was absent from all of them: 40 of 42 live photographers had none
# registered. These assert it now carries the same weight as KYC and packages
# at each, including the admin gate, which previously validated only that a
# state transition was legal and checked no content whatsoever.
# ---------------------------------------------------------------------------


def _ready_pro(db_session, *, with_gear: bool, status=None) -> uuid.UUID:
    """A photographer who passes everything except, optionally, gear."""
    from app.models.admin import KYCStatus
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    pro_id = _pro(db_session)
    profile = db_session.get(ProProfile, pro_id)
    profile.headline = "Headline"
    profile.bio = "Bio"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.languages = ["en"]
    profile.styles = ["editorial"]
    profile.kyc_status = KYCStatus.approved
    profile.completeness_score = 90

    onboarding = db_session.get(ProOnboarding, pro_id)
    if onboarding is None:
        onboarding = ProOnboarding(
            pro_user_id=pro_id, status=status or ProOnboardingStatus.kyc_approved
        )
        db_session.add(onboarding)

    if with_gear:
        _body(db_session, pro_id)
        _lens(db_session, pro_id, lens="FE 85mm F1.4 GM", lens_spec=(85, 85, 1.4, 1.4))
    db_session.flush()
    return pro_id


def test_the_checks_endpoint_reports_gear_as_a_requirement(db_session, reference):
    from app.services.launch_ops import onboarding_checks

    without = _ready_pro(db_session, with_gear=False)
    checks = onboarding_checks(db_session, pro_user_id=without)
    assert checks["gear_verified"] is False
    assert checks["ready_for_review"] is False, "a photographer with no gear was ready to go live"
    assert "full_frame_body" in checks["gear_missing"]

    with_gear = _ready_pro(db_session, with_gear=True)
    assert onboarding_checks(db_session, pro_user_id=with_gear)["gear_verified"] is True


def test_the_checks_name_which_part_is_missing(db_session, reference):
    """"Gear required" leaves a photographer guessing between three things."""
    from app.services.launch_ops import onboarding_checks

    pro_id = _ready_pro(db_session, with_gear=False)
    _body(db_session, pro_id)
    db_session.flush()

    checks = onboarding_checks(db_session, pro_user_id=pro_id)
    assert checks["gear_missing"] == ["qualifying_lens"]


def test_gear_awaiting_review_is_reported_separately_from_missing(db_session, reference):
    """Waiting on the platform is not the same as not having done the work,
    and the wording a photographer sees depends on which it is."""
    from app.services.launch_ops import onboarding_checks

    pro_id = _ready_pro(db_session, with_gear=False)
    _body(db_session, pro_id, model="ILCE-9M4", serial="UNKNOWN-1")
    db_session.flush()

    checks = onboarding_checks(db_session, pro_user_id=pro_id)
    assert checks["gear_awaiting_review"] == 1
    assert checks["gear_verified"] is False


def test_self_activation_refuses_a_photographer_without_gear(client, db_session, reference):
    """The call that actually makes somebody bookable. A requirement enforced
    only on the screen that reports it is not enforced."""
    pro_id = _ready_pro(db_session, with_gear=False)
    from app.models.booking import ProPackage
    from app.models.niche import Niche
    from sqlalchemy import select as _select

    niche = db_session.execute(_select(Niche).where(Niche.slug == "portraits")).scalar_one()
    db_session.add(
        ProPackage(
            pro_user_id=pro_id, niche_id=niche.id, title="Session", duration_minutes=60,
            price=Decimal("5.00"), currency="EUR", included_photos=10,
            extra_photo_price=Decimal("5.00"), proofs_sla_days=3, finals_sla_days=7,
            addons=[], is_active=True,
        )
    )
    db_session.commit()

    resp = client.post("/v1/pro/me/activate", headers={"X-User-Id": str(pro_id)})
    assert resp.status_code == 409, resp.text
    assert "Verified gear required" in resp.json()["error"]["message"]
    assert "full_frame_body" in resp.json()["error"]["message"]


def test_admin_approval_refuses_a_photographer_without_gear(client, db_session, reference):
    """This gate previously validated only that a state transition was legal
    and checked no content at all."""
    from app.models.admin import UserRole, UserRoleType

    pro_id = _ready_pro(db_session, with_gear=False)
    admin_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=admin_id))
    db_session.flush()
    db_session.add(UserRole(user_id=admin_id, role=UserRoleType.admin))
    db_session.commit()

    resp = client.post(
        f"/v1/admin/onboarding/pros/{pro_id}/approve", headers={"X-User-Id": str(admin_id)}
    )
    assert resp.status_code == 409, resp.text
    assert "does not meet the floor" in resp.json()["error"]["message"]


def test_admin_approval_allows_a_photographer_who_meets_it(client, db_session, reference):
    from app.models.admin import UserRole, UserRoleType
    from app.models.launch_ops import ProOnboardingStatus

    # ready_for_review, because the state machine only allows approval from
    # there. The gear check runs before that rule, which is why the negative
    # case above reaches the gear message rather than this one.
    pro_id = _ready_pro(
        db_session, with_gear=True, status=ProOnboardingStatus.ready_for_review
    )
    admin_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=admin_id))
    db_session.flush()
    db_session.add(UserRole(user_id=admin_id, role=UserRoleType.admin))
    db_session.commit()

    resp = client.post(
        f"/v1/admin/onboarding/pros/{pro_id}/approve", headers={"X-User-Id": str(admin_id)}
    )
    assert resp.status_code == 200, resp.text
