# Security audit list

Items for the security audit before GATE 2 (see `UNGATED_COMMITS.md`). Each one is logged here when found and fixed in the audit batch, not before.

| # | Logged | Item | Where | Suggested fix | Status |
|---|---|---|---|---|---|
| 1 | 2026-11-09 | Verify and reset codes sit in plain text in the outbox payload, and their sends get no `email_message` row (only a log line). Anyone who can read `outbox_event` can read a live reset code. | `services/auth_service.py` (`email.verify.send`, `email.reset.send`), `tasks/outbox_tasks.py` | Store a hash (or nothing) in the payload and pass the code only to the send, or purge the payload once delivered; record each send as an `email_message` row. | open |
