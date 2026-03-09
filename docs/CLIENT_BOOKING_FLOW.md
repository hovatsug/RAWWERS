# CLIENT Booking Flow

## Primary sequence
1. Discover/search a pro.
2. Create booking request:
- `POST /v1/client/bookings/request`
3. Add preferred windows:
- `POST /v1/client/bookings/{booking_request_id}/time-windows`
4. Open booking by id:
- `GET /v1/client/bookings/{booking_id}`
5. Pay booking (if required):
- `POST /v1/client/bookings/{booking_id}/pay`

## Supporting actions
- Fetch request status: `GET /v1/booking-requests/{request_id}`
- Cancel request: `POST /v1/booking-requests/{request_id}/cancel`

## Fallback note
Provided catalog does not include a booking list endpoint; client should store recent `booking_id`s locally and hydrate each booking via `GET /v1/client/bookings/{booking_id}`.
