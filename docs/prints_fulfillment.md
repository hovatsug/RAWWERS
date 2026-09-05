# Prints + Physical Fulfillment v1

RAWWERS Foundation #38 adds EU-first physical fulfillment tied to delivered gigs: prints, frames, and albums with partner-managed production.

## Catalog Model

Core entities:

- `print_partner`: lab/fulfillment provider (`manual` or `api` mode)
- `print_product`: partner SKU + options + production specs + cost/markup/retail
- `shipping_address`: user shipping profile (sensitive fields in `encrypted_fields`)

Pricing model:

- `retail_price_eur = base_cost_eur * (1 + markup_percent / 100)`
- Order totals:
  - subtotal: sum line totals
  - shipping: flat v1 fee
  - total: subtotal + shipping

## Order and Fulfillment Flow

1. Client browses `/v1/prints/catalog`.
2. Client creates order from delivered gig gallery (`/v1/gigs/{gig_id}/prints/orders`).
3. Stripe PaymentIntent created via `/v1/prints/orders/{order_id}/pay`.
4. Stripe webhook success marks order `paid` and queues `print_export_job`.
5. Outbox dispatch consumes `print.export.run` and generates export manifest (`output_files`).
6. Order transitions to `in_production`.
7. Admin updates tracking/status to `shipped`/`delivered`.

## Export Specs and DPI Policy

v1 export pipeline is deterministic and manifest-first:

- Source preference: `MediaDerivative(full_res)` then `MediaObject(original)`
- Each output file record contains:
  - source key
  - export key
  - selected options snapshot
  - production specs (`dpi`, `color_profile`, `bleed`)
- Default policy:
  - DPI: 300
  - color profile: sRGB

v1 does not mutate pixel data in worker; it prepares production-ready bundle metadata and keys for partner handoff.

## Access Control and Privacy

Order creation requires:

- request user is gig client
- gig status is delivered (`final_delivered`/`completed`)
- `download_finals` entitlement exists
- selected media belong to gig proof gallery and are ready for full-res export

Shipping data:

- stored in `shipping_address.encrypted_fields`
- postal code stored as hash (`postal_code_hash`)

## Manual vs API Partner Integration

### Manual (v1 default)

- Admin retrieves export bundle metadata and submits to partner portal manually.
- Admin updates partner reference and tracking via admin endpoints.

### API (placeholder)

- Partner mode supports future direct API submission with signed file URLs.
- `print_partner.mode=api` + `api_base_url` + `api_key_ref` reserved for next slice.

## Ops Runbook

- Monitor order states in `/v1/admin/prints/orders`.
- On `paid`, confirm export job reaches `done`.
- Move order to `in_production` (automatic after export done).
- Set tracking when handed to carrier.
- Mark delivered on proof of delivery.

Events and analytics:

- `prints.catalog_viewed`
- `prints.order_created`
- `prints.paid`
- `prints.export_done`
- `prints.shipped`
- `prints.delivered`

## Refund/Dispute Policy Hook

When Stripe refund event arrives:

- if order is `pending_payment` or `paid`: transition to `refunded`
- if order is `in_production`/`shipped`/`delivered`: keep status and log `admin_review_required`

This aligns with dispute-first handling for physically progressed orders.
