from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.payouts import (
    EarningsEntryStatus,
    EarningsHoldReason,
    EarningsSourceType,
    PayoutAccountStatus,
    PayoutMethod,
    PayoutRequestStatus,
)


class EarningsBalanceView(BaseModel):
    pending_eur: Decimal
    available_eur: Decimal
    held_eur: Decimal
    reserved_eur: Decimal
    withdrawable_eur: Decimal


class EarningsLedgerItemView(BaseModel):
    id: uuid.UUID
    source_type: EarningsSourceType
    source_id: uuid.UUID
    gross_eur: Decimal
    platform_fee_eur: Decimal
    net_eur: Decimal
    status: EarningsEntryStatus
    available_at: datetime
    reversed_at: datetime | None = None
    metadata: dict = Field(default_factory=dict, alias="meta")
    created_at: datetime


class EarningsLedgerResponse(BaseModel):
    items: list[EarningsLedgerItemView] = Field(default_factory=list)


class PayoutAccountUpsertRequest(BaseModel):
    payout_method: PayoutMethod
    stripe_connect_account_id: str | None = None
    bank_details_encrypted: dict | None = None
    status: PayoutAccountStatus = PayoutAccountStatus.pending_verification


class PayoutAccountView(BaseModel):
    pro_user_id: uuid.UUID
    payout_method: PayoutMethod
    stripe_connect_account_id: str | None = None
    bank_details_encrypted: dict | None = None
    status: PayoutAccountStatus
    updated_at: datetime


class PayoutRequestCreateRequest(BaseModel):
    amount_eur: Decimal


class PayoutRequestView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    amount_eur: Decimal
    status: PayoutRequestStatus
    requested_at: datetime
    approved_by_admin_id: uuid.UUID | None = None
    approved_at: datetime | None = None
    paid_at: datetime | None = None
    failure_reason: str | None = None
    reference: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class PayoutListResponse(BaseModel):
    items: list[PayoutRequestView] = Field(default_factory=list)


class AdminFinanceProItem(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    city: str | None = None
    country: str | None = None
    pending_eur: Decimal
    available_eur: Decimal
    held_eur: Decimal
    reserved_eur: Decimal
    withdrawable_eur: Decimal


class AdminFinanceProsResponse(BaseModel):
    items: list[AdminFinanceProItem] = Field(default_factory=list)


class EarningsHoldCreateRequest(BaseModel):
    pro_user_id: uuid.UUID
    reason: EarningsHoldReason
    amount_eur: Decimal | None = None
    source_type: str | None = None
    source_id: uuid.UUID | None = None


class EarningsHoldView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    reason: EarningsHoldReason
    amount_eur: Decimal | None = None
    source_type: str | None = None
    source_id: uuid.UUID | None = None
    created_by_admin_id: uuid.UUID | None = None
    created_at: datetime
    released_at: datetime | None = None


class PlatformFeePolicyView(BaseModel):
    id: uuid.UUID
    fee_percent_gigs: int
    fee_percent_extras: int
    fee_percent_studioverse: int
    settlement_delay_days: int
    dispute_hold_days: int
    updated_at: datetime


class PlatformFeePolicyUpdateRequest(BaseModel):
    fee_percent_gigs: int
    fee_percent_extras: int
    fee_percent_studioverse: int
    settlement_delay_days: int
    dispute_hold_days: int


class AdminPayoutRejectRequest(BaseModel):
    reason: str | None = None


class AdminPayoutMarkPaidRequest(BaseModel):
    reference: dict = Field(default_factory=dict)


class AdminFinanceProDetailResponse(BaseModel):
    pro_user_id: uuid.UUID
    balance: EarningsBalanceView
    payout_account: PayoutAccountView
    holds: list[EarningsHoldView] = Field(default_factory=list)
    recent_disputes: list[dict] = Field(default_factory=list)
    recent_payouts: list[PayoutRequestView] = Field(default_factory=list)


class ConnectOnboardingLinkResponse(BaseModel):
    """A single-use hosted-onboarding URL.

    Not cached anywhere: Stripe account links expire within minutes and
    are consumed on first use, so a stored one is a broken one.
    """

    url: str
    stripe_account_id: str


class ConnectStatusResponse(BaseModel):
    stripe_account_id: str | None = None
    account_status: str
    charges_enabled: bool = False
    payouts_enabled: bool = False
    details_submitted: bool = False
    # What Stripe is still waiting for. The difference between telling a
    # photographer "pending" and telling them what to go and do.
    currently_due: list[str] = Field(default_factory=list)
    past_due: list[str] = Field(default_factory=list)
    disabled_reason: str | None = None


class AdminPayoutQueueRow(BaseModel):
    """A payout request with everything needed to decide on it.

    The plain list endpoint returns ids and an amount, which is not enough
    to approve safely: whether the destination account can actually receive
    money, and what the photographer's ledger says, both matter *before*
    approval rather than after.
    """

    payout_request_id: uuid.UUID
    pro_user_id: uuid.UUID
    display_name: str | None = None
    email: str | None = None
    amount_eur: Decimal
    status: PayoutRequestStatus
    requested_at: datetime

    payout_method: str
    payout_account_status: str
    # Manual bank transfer is a legitimate route and currently the only one
    # that works end to end, so it is not treated as a blocker. Only an
    # unusable Connect account is.
    approval_blocked: bool
    blocked_reason: str | None = None

    available_eur: Decimal
    pending_eur: Decimal
    withdrawable_eur: Decimal
    # A request for more than the photographer can currently withdraw means
    # something moved between requesting and reviewing.
    exceeds_withdrawable: bool
    lifetime_payouts: int


class AdminPayoutQueueResponse(BaseModel):
    items: list[AdminPayoutQueueRow] = Field(default_factory=list)


class GigInvoiceView(BaseModel):
    """One completed gig, line by line.

    Every figure is computed server-side from the gig's own record. The app
    renders these and adds nothing up itself - the same rule the pricing curve
    follows, and for the same reason: two places doing the same arithmetic is
    how they end up disagreeing.
    """

    gig_id: uuid.UUID
    issued_at: datetime
    currency: str

    #: What the client paid in total.
    client_total: Decimal

    platform_retained: Decimal
    pro_raww: Decimal
    client_raww: Decimal
    pro_cash: Decimal

    retained_percent: int
    pro_raww_percent: int
    client_credit_percent: int

    #: Null when no selection was submitted. Not zero - a completed gig with
    #: no recorded count has an unknown count, and rendering zero on it would
    #: be the invoice claiming nothing was delivered.
    photos_delivered: int | None = None

    #: False when this gig predates the stamped rates, so the split above was
    #: reconstructed from the current policy rather than read from the record.
    rates_were_stamped: bool = True

    # --- Tax -------------------------------------------------------------
    #: not_answered, not_registered or registered, as recorded when this
    #: booking was made. Never inferred from whether a number is present.
    vat_status: str = "not_answered"
    #: All null unless the photographer was registered at the time. Null
    #: rather than zero, so a renderer cannot print a breakdown of a tax that
    #: was never charged.
    vat_rate_percent: int | None = None
    vat_number: str | None = None
    vat_net_amount: Decimal | None = None
    vat_amount: Decimal | None = None

    #: RAWWERS' own VAT treatment of its commission. Always null, by design:
    #: it depends on where the company incorporates, which is undecided. The
    #: field exists so an invoice can render "pending" rather than say nothing
    #: at all, and so a test can assert a number never appears here.
    platform_commission_vat: None = None


class GigInvoiceListResponse(BaseModel):
    items: list[GigInvoiceView] = Field(default_factory=list)


class InvoiceSummaryView(BaseModel):
    """Totals across every completed, invoiced gig."""

    bookings: int
    gross: Decimal
    #: The platform's whole take, which is what a photographer means by fees
    #: paid - not only the share the platform keeps.
    platform_fees: Decimal
    pro_raww: Decimal
    #: What this photographer has chosen to hand back to their clients.
    client_raww: Decimal
    pro_cash: Decimal
    #: Null with no bookings. A photographer with no completed work has no
    #: average, and 0.00 would state one.
    average_gross: Decimal | None = None
    #: How many of these totals came from reconstructed rather than recorded
    #: rates, so a summary built mostly from reconstructions can say so.
    reconstructed: int = 0


class TaxProfileView(BaseModel):
    """What a photographer has told us about their own tax position."""

    vat_status: str
    vat_number: str | None = None
    country: str | None = None

    # Reference for the form, from the country's rule row. The threshold is
    # shown so a photographer can judge for themselves; the platform sees only
    # their RAWWERS bookings and cannot tell whether they have crossed it.
    tax_name: str | None = None
    standard_rate_percent: int | None = None
    registration_threshold: Decimal | None = None
    threshold_currency: str | None = None
    vat_number_format: str | None = None


class TaxProfileUpdateRequest(BaseModel):
    vat_status: str
    vat_number: str | None = None
    country: str | None = None
