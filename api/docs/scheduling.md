# Scheduling + Availability v1

## Data Model
- `pro_availability_rule`: weekly recurring local-time blocks per weekday and timezone.
- `pro_availability_exception`: UTC blackout windows.
- `pro_scheduling_policy`: slot length, buffers, advance notice, max/day.
- `booking_time_request`: client-submitted acceptable windows.
- `confirmed_slot`: canonical UTC slot per gig.
- `cancellation_policy_snapshot`: per-gig cancellation policy at confirmation time.

## Slot Generation
1. Load weekly rules and scheduling policy.
2. Expand local rule blocks into slot-length increments.
3. Convert candidate slots to UTC.
4. Filter out:
- advance-notice violations
- availability exceptions
- buffered overlaps with confirmed slots

## Conflict Prevention
- App-level transactional validation checks buffered overlaps before insert.
- Database-level enforcement:
- unique slot key on `(pro_user_id, start_at_utc, end_at_utc)`
- Postgres exclusion constraint on `tstzrange(start_at_utc, end_at_utc)` with `pro_user_id`.

## Reminders
- On confirmation, schedule followup jobs at:
- `slot_start - 24h`
- `slot_start - 2h`
- Followup jobs are delivered by existing followup processor and notification pipeline.

## UI Suggestions
- Show availability in client timezone but submit UTC.
- Allow client to submit 1..8 windows.
- Require pro to confirm a slot inside the latest submitted window set.
- On conflict response, refresh slots and re-pick.
