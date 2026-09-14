"""How one booking's money divides.

The platform's 20% take does not move. These cover the structure inside it -
15% retained, 5% back to the photographer as credit - and the photographer's
own choice to pass up to 10% of gross to their client out of their cash.

The property that matters is that the four shares sum to the gross exactly.
Three independently rounded percentages of the same number need not, and a
split that loses a cent per booking loses it from somebody.
"""
from decimal import Decimal

import pytest
from app.core.errors import APIError
from app.services.commission import split_booking, validate_client_credit_percent
from app.services.payouts import ensure_default_platform_fee_policy


@pytest.fixture()
def policy(db_session):
    return ensure_default_platform_fee_policy(db_session)


@pytest.mark.parametrize("credit", [0, 5, 10])
def test_every_share_sums_back_to_the_gross(db_session, policy, credit):
    split = split_booking(gross=Decimal("1490.00"), policy=policy, client_credit_percent=credit)

    assert split.reconciles(), (
        f"at {credit}% client credit the shares are "
        f"{split.platform_retained} + {split.pro_raww} + {split.pro_cash} + {split.client_raww} "
        f"against a gross of {split.gross}"
    )
    assert (
        split.platform_retained + split.pro_raww + split.pro_cash + split.client_raww
        == Decimal("1490.00")
    )


def test_the_documented_split_at_zero_credit(db_session, policy):
    split = split_booking(gross=Decimal("1000.00"), policy=policy, client_credit_percent=0)

    assert split.platform_retained == Decimal("150.00")
    assert split.pro_raww == Decimal("50.00")
    assert split.pro_cash == Decimal("800.00")
    assert split.client_raww == Decimal("0.00")


def test_the_documented_split_at_the_maximum(db_session, policy):
    """The photographer's generosity comes out of their own cash, never out of
    the platform's take."""
    split = split_booking(gross=Decimal("1000.00"), policy=policy, client_credit_percent=10)

    assert split.platform_retained == Decimal("150.00")
    assert split.pro_raww == Decimal("50.00")
    assert split.pro_cash == Decimal("700.00")
    assert split.client_raww == Decimal("100.00")
    assert split.platform_total == Decimal("200.00"), "the platform's take moved with client credit"


def test_the_platform_take_is_unchanged_by_client_credit(db_session, policy):
    generous = split_booking(gross=Decimal("847.33"), policy=policy, client_credit_percent=10)
    none = split_booking(gross=Decimal("847.33"), policy=policy, client_credit_percent=0)

    assert generous.platform_total == none.platform_total
    assert generous.platform_retained == none.platform_retained
    assert generous.pro_raww == none.pro_raww


@pytest.mark.parametrize("gross", ["0.01", "3.33", "99.99", "1234.56", "847.33"])
def test_awkward_amounts_still_reconcile(db_session, policy, gross):
    """Percentages of amounts that do not divide cleanly. The photographer's
    cash is a remainder rather than its own rounded percentage, so it absorbs
    the fraction instead of the total drifting off the gross."""
    for credit in range(0, 11):
        split = split_booking(gross=Decimal(gross), policy=policy, client_credit_percent=credit)
        assert split.reconciles(), f"{gross} at {credit}% does not reconcile"


# ---------------------------------------------------------------------------
# The cap.
# ---------------------------------------------------------------------------


def test_above_the_cap_is_rejected_and_the_limit_is_named(db_session, policy):
    with pytest.raises(APIError) as caught:
        split_booking(gross=Decimal("100.00"), policy=policy, client_credit_percent=11)
    assert "10" in caught.value.message


def test_a_negative_share_is_rejected(db_session, policy):
    with pytest.raises(APIError):
        split_booking(gross=Decimal("100.00"), policy=policy, client_credit_percent=-1)


def test_fractional_points_are_rejected(db_session):
    """Whole points only. A photographer cannot tell 7% from 7.5% on an
    invoice, and fractional rates make every downstream total an argument
    about rounding."""
    with pytest.raises(APIError):
        validate_client_credit_percent(7.5, maximum=10)  # type: ignore[arg-type]


def test_the_cap_comes_from_the_policy_not_a_constant(db_session, policy):
    policy.max_client_credit_percent = 4
    db_session.flush()

    split = split_booking(gross=Decimal("100.00"), policy=policy, client_credit_percent=4)
    assert split.client_raww == Decimal("4.00")
    with pytest.raises(APIError):
        split_booking(gross=Decimal("100.00"), policy=policy, client_credit_percent=5)


def test_a_policy_that_does_not_add_up_refuses_to_split(db_session, policy):
    """15 and 5 make the 20 the platform takes. If an admin edits one without
    the others the split would quietly invent or lose money on every booking,
    so it stops instead."""
    policy.retained_percent = 14
    db_session.flush()

    with pytest.raises(APIError) as caught:
        split_booking(gross=Decimal("100.00"), policy=policy, client_credit_percent=0)
    assert "does not add up" in caught.value.message


# ---------------------------------------------------------------------------
# One source for the rate.
# ---------------------------------------------------------------------------


def test_changing_the_policy_moves_what_a_booking_charges(db_session, policy):
    """The point of the consolidation.

    Booking acceptance used to read settings.platform_fee_bps while earnings
    read this row. Both said 20%, so nothing was visibly wrong - but editing
    this row as an admin changed what a photographer was paid without changing
    what the booking had charged. This fails if any caller goes back to
    reading the environment variable.
    """
    import uuid

    from app.models.admin import ProProfile, UserAccount
    from app.services.commission import split_for_pro

    pro_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id))
    db_session.flush()
    db_session.add(ProProfile(user_id=pro_id, display_name="Rate Test"))
    db_session.flush()

    at_twenty = split_for_pro(db_session, gross=Decimal("1000.00"), pro_user_id=pro_id)
    assert at_twenty.platform_total == Decimal("200.00")

    policy.fee_percent_gigs = 30
    policy.retained_percent = 25
    db_session.flush()

    at_thirty = split_for_pro(db_session, gross=Decimal("1000.00"), pro_user_id=pro_id)
    assert at_thirty.platform_total == Decimal("300.00"), (
        "the split ignored the policy row, so some caller is still reading a "
        "separately configured rate"
    )
    assert at_thirty.pro_cash == Decimal("700.00")


def test_a_photographers_default_is_used_when_the_booking_does_not_override(db_session, policy):
    import uuid

    from app.models.admin import ProProfile, UserAccount
    from app.services.commission import split_for_pro

    pro_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id))
    db_session.flush()
    db_session.add(ProProfile(user_id=pro_id, display_name="Generous", client_credit_percent=7))
    db_session.flush()

    split = split_for_pro(db_session, gross=Decimal("1000.00"), pro_user_id=pro_id)
    assert split.client_raww == Decimal("70.00")
    assert split.pro_cash == Decimal("730.00")


def test_a_booking_can_override_the_photographers_default(db_session, policy):
    """More generous on one large wedding, without changing their standing
    setting."""
    import uuid

    from app.models.admin import ProProfile, UserAccount
    from app.services.commission import split_for_pro

    pro_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id))
    db_session.flush()
    db_session.add(ProProfile(user_id=pro_id, display_name="Usually Thrifty", client_credit_percent=2))
    db_session.flush()

    split = split_for_pro(
        db_session, gross=Decimal("1000.00"), pro_user_id=pro_id, client_credit_percent_override=10
    )
    assert split.client_raww == Decimal("100.00")
    assert split.client_credit_percent == 10
