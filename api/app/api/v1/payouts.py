from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from fastapi.responses import HTMLResponse
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.core.config import get_settings
from app.models.gig import Gig, GigStatus
from app.models.admin import Dispute, ProProfile, UserAccount
from app.models.payouts import (
    EarningsHold,
    EarningsSourceType,
    PayoutAccountStatus,
    PayoutMethod,
    PayoutRequest,
    PayoutRequestStatus,
    PlatformFeePolicy,
)
from app.schemas.media import CurrentUser
from app.schemas.payouts import (
    TaxProfileUpdateRequest,
    TaxProfileView,
    InvoiceSummaryView,
    GigInvoiceListResponse,
    GigInvoiceView,
    AdminPayoutQueueResponse,
    AdminPayoutQueueRow,
    ConnectOnboardingLinkResponse,
    ConnectStatusResponse,
    AdminFinanceProDetailResponse,
    AdminFinanceProItem,
    AdminFinanceProsResponse,
    AdminPayoutMarkPaidRequest,
    AdminPayoutRejectRequest,
    EarningsBalanceView,
    EarningsHoldCreateRequest,
    EarningsHoldView,
    EarningsLedgerResponse,
    EarningsLedgerItemView,
    PlatformFeePolicyUpdateRequest,
    PlatformFeePolicyView,
    PayoutAccountUpsertRequest,
    PayoutAccountView,
    PayoutListResponse,
    PayoutRequestCreateRequest,
    PayoutRequestView,
)
from app.models.payouts import TaxProfile, VatStatus
from app.services.connect_return import PAGE_HEADERS, REFRESH_PAGE, RETURN_PAGE
from app.services.invoices import build_invoice, summarise_invoices
from app.services.tax import DEFAULT_COUNTRY, ensure_uk_tax_rule, tax_profile_for, tax_rule_for
from app.services.audit import add_admin_audit_log
from app.services.stripe_connect import (
    connect_status,
    create_onboarding_link,
    ensure_connect_account,
    status_from_account,
)
from app.services.authz import get_user_roles
from app.models.admin import UserRoleType
from app.services.payouts import (
    approve_payout_request,
    create_earnings_hold,
    create_payout_request,
    ensure_default_platform_fee_policy,
    execute_payout_request,
    get_or_create_payout_account,
    list_finance_pros,
    list_payout_requests_admin,
    list_pro_earnings_entries,
    list_pro_payout_requests,
    mark_payout_paid_manual,
    payout_balance_view,
    reject_payout_request,
    release_earnings_hold,
    upsert_payout_account,
)

settings = get_settings()
router = APIRouter(tags=["payouts"])


@router.get("/pro/earnings/balance", response_model=EarningsBalanceView)
def get_my_earnings_balance(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EarningsBalanceView:
    _ensure_pro_user(db, user.user_id)
    return EarningsBalanceView(**payout_balance_view(db, pro_user_id=user.user_id))


def _invoice_view(invoice) -> GigInvoiceView:
    return GigInvoiceView(
        gig_id=invoice.gig_id,
        issued_at=invoice.issued_at,
        currency=invoice.currency,
        client_total=invoice.client_total,
        platform_retained=invoice.platform_retained,
        pro_raww=invoice.pro_raww,
        client_raww=invoice.client_raww,
        pro_cash=invoice.pro_cash,
        retained_percent=invoice.retained_percent,
        pro_raww_percent=invoice.pro_raww_percent,
        client_credit_percent=invoice.client_credit_percent,
        photos_delivered=invoice.photos_delivered,
        rates_were_stamped=invoice.rates_were_stamped,
        vat_status=invoice.vat.status.value,
        vat_rate_percent=invoice.vat.rate_percent,
        vat_number=invoice.vat.vat_number,
        vat_net_amount=invoice.vat.net_amount,
        vat_amount=invoice.vat.vat_amount,
    )


@router.get("/pro/tax-profile", response_model=TaxProfileView)
def get_my_tax_profile(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> TaxProfileView:
    _ensure_pro_user(db, user.user_id)
    ensure_uk_tax_rule(db)
    profile = tax_profile_for(db, user.user_id)
    country = (profile.country if profile else None) or DEFAULT_COUNTRY
    rule = tax_rule_for(db, country)
    db.commit()
    return TaxProfileView(
        # not_answered, never not_registered. Being unregistered is something
        # a photographer tells us, not something assumed on their behalf.
        vat_status=(profile.vat_status.value if profile else VatStatus.not_answered.value),
        vat_number=profile.vat_number if profile else None,
        country=country,
        tax_name=rule.tax_name if rule else None,
        standard_rate_percent=rule.standard_rate_percent if rule else None,
        registration_threshold=rule.registration_threshold if rule else None,
        threshold_currency=rule.threshold_currency if rule else None,
        vat_number_format=rule.vat_number_format if rule else None,
    )


@router.put("/pro/tax-profile", response_model=TaxProfileView)
def update_my_tax_profile(
    body: TaxProfileUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> TaxProfileView:
    _ensure_pro_user(db, user.user_id)
    try:
        status = VatStatus(body.vat_status)
    except ValueError:
        raise APIError(
            code="validation_error",
            message="VAT status must be one of: not_answered, not_registered, registered",
            status_code=422,
        ) from None

    number = (body.vat_number or "").strip() or None
    if status == VatStatus.registered and not number:
        raise APIError(
            code="validation_error",
            message="A VAT number is required when registered",
            status_code=422,
        )

    profile = tax_profile_for(db, user.user_id)
    if profile is None:
        profile = TaxProfile(pro_user_id=user.user_id)
        db.add(profile)
    profile.vat_status = status
    # Cleared when they are not registered, so a stale number cannot reappear
    # on an invoice if they register again later.
    profile.vat_number = number if status == VatStatus.registered else None
    if body.country:
        profile.country = body.country.upper()[:2]
    db.commit()
    return get_my_tax_profile(user=user, db=db)


@router.get("/pro/earnings/summary", response_model=InvoiceSummaryView)
def get_my_earnings_summary(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> InvoiceSummaryView:
    """Totals across every completed gig, from the same figures each invoice
    shows rather than a separate aggregate that could disagree with them."""
    _ensure_pro_user(db, user.user_id)
    summary = summarise_invoices(db, user.user_id)
    return InvoiceSummaryView(
        bookings=summary.bookings,
        gross=summary.gross,
        platform_fees=summary.platform_fees,
        pro_raww=summary.pro_raww,
        client_raww=summary.client_raww,
        pro_cash=summary.pro_cash,
        average_gross=summary.average_gross,
        reconstructed=summary.reconstructed,
    )


@router.get("/pro/earnings/invoices", response_model=GigInvoiceListResponse)
def list_my_invoices(
    limit: int = Query(default=100, ge=1, le=500),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigInvoiceListResponse:
    """Every completed gig this photographer has been paid for, itemised."""
    _ensure_pro_user(db, user.user_id)
    gigs = db.execute(
        select(Gig)
        .where(Gig.pro_user_id == user.user_id, Gig.status == GigStatus.completed)
        .order_by(Gig.scheduled_end.desc().nullslast(), Gig.created_at.desc())
        .limit(limit)
    ).scalars().all()
    return GigInvoiceListResponse(items=[_invoice_view(build_invoice(db, gig)) for gig in gigs])


@router.get("/pro/earnings/invoices/{gig_id}", response_model=GigInvoiceView)
def get_my_invoice(
    gig_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigInvoiceView:
    _ensure_pro_user(db, user.user_id)
    gig = db.get(Gig, gig_id)
    # Not found rather than forbidden for somebody else's gig: whether a gig
    # id exists is not something to confirm to a stranger.
    if gig is None or gig.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Invoice not found", status_code=404)
    return _invoice_view(build_invoice(db, gig))


@router.get("/pro/earnings/ledger", response_model=EarningsLedgerResponse)
def get_my_earnings_ledger(
    source_type: EarningsSourceType | None = None,
    from_at: datetime | None = Query(default=None, alias="from"),
    to_at: datetime | None = Query(default=None, alias="to"),
    limit: int = Query(default=100, ge=1, le=500),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EarningsLedgerResponse:
    _ensure_pro_user(db, user.user_id)
    rows = list_pro_earnings_entries(
        db,
        pro_user_id=user.user_id,
        source_type=source_type,
        from_at=from_at,
        to_at=to_at,
        limit=limit,
    )
    return EarningsLedgerResponse(items=[EarningsLedgerItemView.model_validate(row, from_attributes=True) for row in rows])


@router.get("/pro/payouts", response_model=PayoutListResponse)
def get_my_payouts(
    limit: int = Query(default=100, ge=1, le=500),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutListResponse:
    _ensure_pro_user(db, user.user_id)
    rows = list_pro_payout_requests(db, pro_user_id=user.user_id, limit=limit)
    return PayoutListResponse(items=[PayoutRequestView.model_validate(row, from_attributes=True) for row in rows])


@router.post("/pro/payouts/request", response_model=PayoutRequestView)
def request_my_payout(
    body: PayoutRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    _ensure_pro_user(db, user.user_id)
    row = create_payout_request(db, pro_user_id=user.user_id, amount_eur=body.amount_eur)
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.get("/pro/payouts/account", response_model=PayoutAccountView)
def get_my_payout_account(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutAccountView:
    _ensure_pro_user(db, user.user_id)
    row = get_or_create_payout_account(db, pro_user_id=user.user_id)
    db.commit()
    db.refresh(row)
    return PayoutAccountView.model_validate(row, from_attributes=True)


@router.put("/pro/payouts/account", response_model=PayoutAccountView)
def put_my_payout_account(
    body: PayoutAccountUpsertRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutAccountView:
    _ensure_pro_user(db, user.user_id)
    row = upsert_payout_account(
        db,
        pro_user_id=user.user_id,
        payout_method=body.payout_method,
        stripe_connect_account_id=body.stripe_connect_account_id,
        bank_details_encrypted=body.bank_details_encrypted,
        status=body.status,
    )
    db.commit()
    db.refresh(row)
    return PayoutAccountView.model_validate(row, from_attributes=True)


@router.post("/pro/payouts/connect/account", response_model=PayoutAccountView)
def create_my_connect_account(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutAccountView:
    """Create the photographer's Stripe Express account, or return theirs.

    Idempotent: an account id we already hold is returned untouched. A
    second account would strand whatever onboarding they had completed
    against the first.
    """
    _ensure_pro_user(db, user.user_id)
    account_row = db.get(UserAccount, user.user_id)
    profile = db.get(ProProfile, user.user_id)
    row = ensure_connect_account(
        db,
        pro_user_id=user.user_id,
        email=account_row.email if account_row else None,
        country=profile.country if profile else None,
    )
    db.commit()
    db.refresh(row)
    return PayoutAccountView.model_validate(row, from_attributes=True)


@router.post("/pro/payouts/connect/onboarding-link", response_model=ConnectOnboardingLinkResponse)
def create_my_connect_onboarding_link(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ConnectOnboardingLinkResponse:
    """A fresh hosted-onboarding link, minted per request.

    Never cached and never reused: Stripe account links expire within
    minutes and are single use. The client asks again rather than storing
    one, and Stripe's refresh_url points back at this endpoint so a stale
    link becomes another attempt rather than a dead end.
    """
    _ensure_pro_user(db, user.user_id)
    account_row = db.get(UserAccount, user.user_id)
    profile = db.get(ProProfile, user.user_id)
    row = ensure_connect_account(
        db,
        pro_user_id=user.user_id,
        email=account_row.email if account_row else None,
        country=profile.country if profile else None,
    )
    db.commit()

    url = create_onboarding_link(
        stripe_account_id=row.stripe_connect_account_id,
        return_url=settings.connect_return_url,
        refresh_url=settings.connect_refresh_url,
    )
    return ConnectOnboardingLinkResponse(url=url, stripe_account_id=row.stripe_connect_account_id)


@router.get("/payouts/connect/return", response_class=HTMLResponse, include_in_schema=False)
def connect_return_page() -> HTMLResponse:
    """Where Stripe sends a photographer who finished (or left) onboarding.

    No login: Stripe redirects a browser, which carries no token. Static:
    the request is never read, so nothing in the address reaches the page.
    The app re-reads the account's status from the server when it opens.
    """
    return HTMLResponse(RETURN_PAGE, headers=PAGE_HEADERS)


@router.get("/payouts/connect/refresh", response_class=HTMLResponse, include_in_schema=False)
def connect_refresh_page() -> HTMLResponse:
    """Where Stripe sends a photographer whose onboarding link expired.

    A new link needs the photographer's login, which this browser does not
    have, so the page sends them back to the app to ask for one there.
    """
    return HTMLResponse(REFRESH_PAGE, headers=PAGE_HEADERS)


@router.get("/pro/payouts/connect/status", response_model=ConnectStatusResponse)
def get_my_connect_status(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ConnectStatusResponse:
    """What Stripe thinks right now, and what it is still waiting for.

    Read live rather than trusting our stored status: the account.updated
    webhook is what normally moves it, and if that silently fails to
    arrive a photographer would sit at "pending" forever with no way to
    find out why. This gives them - and us - a second source.
    """
    _ensure_pro_user(db, user.user_id)
    row = get_or_create_payout_account(db, pro_user_id=user.user_id)
    db.commit()

    if not row.stripe_connect_account_id:
        return ConnectStatusResponse(account_status=row.status.value)

    live = connect_status(stripe_account_id=row.stripe_connect_account_id)
    derived = status_from_account(live)
    # Reconciled here as well as by webhook, so a dropped event self-heals
    # the next time the photographer opens the screen.
    if row.status != derived:
        row.status = derived
        row.updated_at = datetime.now(timezone.utc)
        db.commit()

    return ConnectStatusResponse(
        stripe_account_id=live["stripe_account_id"],
        account_status=derived.value,
        charges_enabled=live["charges_enabled"],
        payouts_enabled=live["payouts_enabled"],
        details_submitted=live["details_submitted"],
        currently_due=live["currently_due"],
        past_due=live["past_due"],
        disabled_reason=live["disabled_reason"],
    )


@router.get("/admin/finance/pros", response_model=AdminFinanceProsResponse)
def list_finance_pros_admin(
    city: str | None = None,
    min_available: Decimal | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminFinanceProsResponse:
    rows = list_finance_pros(db, city=city, min_available=min_available, limit=limit)
    return AdminFinanceProsResponse(items=[AdminFinanceProItem(**item) for item in rows])


@router.get("/admin/finance/pros/{pro_user_id}", response_model=AdminFinanceProDetailResponse)
def get_finance_pro_detail_admin(
    pro_user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminFinanceProDetailResponse:
    balance = EarningsBalanceView(**payout_balance_view(db, pro_user_id=pro_user_id))
    account = PayoutAccountView.model_validate(get_or_create_payout_account(db, pro_user_id=pro_user_id), from_attributes=True)
    holds = db.execute(
        select(EarningsHold).where(EarningsHold.pro_user_id == pro_user_id).order_by(EarningsHold.created_at.desc()).limit(50)
    ).scalars().all()
    disputes = db.execute(
        select(Dispute).where(Dispute.against_user_id == pro_user_id).order_by(Dispute.created_at.desc()).limit(20)
    ).scalars().all()
    payouts = list_pro_payout_requests(db, pro_user_id=pro_user_id, limit=20)
    return AdminFinanceProDetailResponse(
        pro_user_id=pro_user_id,
        balance=balance,
        payout_account=account,
        holds=[EarningsHoldView.model_validate(item, from_attributes=True) for item in holds],
        recent_disputes=[
            {"id": str(item.id), "status": item.status.value, "category": item.category.value, "opened_at": item.opened_at.isoformat()}
            for item in disputes
        ],
        recent_payouts=[PayoutRequestView.model_validate(item, from_attributes=True) for item in payouts],
    )


@router.get("/admin/payouts/queue", response_model=AdminPayoutQueueResponse)
def admin_payout_queue(
    status: PayoutRequestStatus | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPayoutQueueResponse:
    """Payout requests awaiting a decision, with the context to make it.

    Defaults to the ones that need action rather than every request ever
    made - the queue should be work, not history.
    """
    stmt = select(PayoutRequest).order_by(PayoutRequest.created_at.asc())
    if status:
        stmt = stmt.where(PayoutRequest.status == status)
    else:
        stmt = stmt.where(
            PayoutRequest.status.in_([PayoutRequestStatus.requested, PayoutRequestStatus.approved,
                                      PayoutRequestStatus.processing])
        )
    rows = db.execute(stmt.limit(200)).scalars().all()

    items: list[AdminPayoutQueueRow] = []
    for row in rows:
        account = get_or_create_payout_account(db, pro_user_id=row.pro_user_id)
        profile = db.get(ProProfile, row.pro_user_id)
        user = db.get(UserAccount, row.pro_user_id)
        balance = payout_balance_view(db, pro_user_id=row.pro_user_id)
        lifetime = db.execute(
            select(func.count()).select_from(PayoutRequest).where(
                PayoutRequest.pro_user_id == row.pro_user_id,
                PayoutRequest.status == PayoutRequestStatus.paid,
            )
        ).scalar_one()

        # Only an unusable Connect account blocks approval. bank_manual is
        # a real route that works end to end today, and blocking it would
        # stop the only path that currently functions.
        blocked = (
            account.payout_method == PayoutMethod.stripe_connect
            and account.status != PayoutAccountStatus.active
        )
        reason = (
            f"Stripe Connect account is {account.status.value}, so a transfer would fail."
            if blocked
            else None
        )

        items.append(
            AdminPayoutQueueRow(
                payout_request_id=row.id,
                pro_user_id=row.pro_user_id,
                display_name=profile.display_name if profile else None,
                email=user.email if user else None,
                amount_eur=row.amount_eur,
                status=row.status,
                requested_at=row.created_at,
                payout_method=account.payout_method.value,
                payout_account_status=account.status.value,
                approval_blocked=blocked,
                blocked_reason=reason,
                available_eur=balance["available_eur"],
                pending_eur=balance["pending_eur"],
                withdrawable_eur=balance["withdrawable_eur"],
                exceeds_withdrawable=row.amount_eur > balance["withdrawable_eur"]
                and row.status == PayoutRequestStatus.requested,
                lifetime_payouts=int(lifetime),
            )
        )
    db.commit()
    return AdminPayoutQueueResponse(items=items)


@router.get("/admin/payouts", response_model=PayoutListResponse)
def list_payouts_admin(
    status: PayoutRequestStatus | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutListResponse:
    rows = list_payout_requests_admin(db, status=status, limit=limit)
    return PayoutListResponse(items=[PayoutRequestView.model_validate(row, from_attributes=True) for row in rows])


@router.post("/admin/payouts/{payout_request_id}/approve", response_model=PayoutRequestView)
def approve_payout_admin(
    payout_request_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = approve_payout_request(db, payout_request_id=payout_request_id, admin_user_id=actor.user_id)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_approved",
        metadata={"pro_user_id": str(row.pro_user_id), "amount_eur": str(row.amount_eur)},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/payouts/{payout_request_id}/reject", response_model=PayoutRequestView)
def reject_payout_admin(
    payout_request_id: uuid.UUID,
    body: AdminPayoutRejectRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = reject_payout_request(db, payout_request_id=payout_request_id, admin_user_id=actor.user_id, reason=body.reason)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_rejected",
        reason=body.reason,
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/payouts/{payout_request_id}/mark-paid", response_model=PayoutRequestView)
def mark_paid_payout_admin(
    payout_request_id: uuid.UUID,
    body: AdminPayoutMarkPaidRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = mark_payout_paid_manual(
        db,
        payout_request_id=payout_request_id,
        admin_user_id=actor.user_id,
        reference=body.reference,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_mark_paid",
        metadata={"reference": body.reference},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/holds/create", response_model=EarningsHoldView)
def create_hold_admin(
    body: EarningsHoldCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> EarningsHoldView:
    row = create_earnings_hold(
        db,
        pro_user_id=body.pro_user_id,
        reason=body.reason,
        amount_eur=body.amount_eur,
        source_type=body.source_type,
        source_id=body.source_id,
        created_by_admin_id=actor.user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="earnings_hold",
        target_id=str(row.id),
        action="earnings_hold_created",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return EarningsHoldView.model_validate(row, from_attributes=True)


@router.post("/admin/holds/{hold_id}/release", response_model=EarningsHoldView)
def release_hold_admin(
    hold_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> EarningsHoldView:
    row = db.get(EarningsHold, hold_id)
    if not row:
        raise APIError(code="not_found", message="Hold not found", status_code=404)
    release_earnings_hold(db, row)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="earnings_hold",
        target_id=str(row.id),
        action="earnings_hold_released",
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return EarningsHoldView.model_validate(row, from_attributes=True)


@router.get("/admin/finance/fee-policy", response_model=PlatformFeePolicyView)
def get_fee_policy_admin(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PlatformFeePolicyView:
    row = ensure_default_platform_fee_policy(db)
    return PlatformFeePolicyView.model_validate(row, from_attributes=True)


@router.put("/admin/finance/fee-policy", response_model=PlatformFeePolicyView)
def put_fee_policy_admin(
    body: PlatformFeePolicyUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PlatformFeePolicyView:
    row = ensure_default_platform_fee_policy(db)
    row.fee_percent_gigs = body.fee_percent_gigs
    row.fee_percent_extras = body.fee_percent_extras
    row.fee_percent_studioverse = body.fee_percent_studioverse
    row.settlement_delay_days = body.settlement_delay_days
    row.dispute_hold_days = body.dispute_hold_days
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="platform_fee_policy",
        target_id=str(row.id),
        action="platform_fee_policy_updated",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return PlatformFeePolicyView.model_validate(row, from_attributes=True)


def _ensure_pro_user(db: Session, user_id: uuid.UUID) -> None:
    roles = get_user_roles(db, user_id)
    if UserRoleType.pro not in roles:
        raise APIError(code="forbidden", message="Pro role required", status_code=403)
