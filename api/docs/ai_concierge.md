# AI Concierge v1

## Prompt Design
- AI identifies itself as an assistant.
- Uses only pro profile, package, availability, and policy context.
- Collects lead details: date, location, niche/style, budget.
- Recommends package and guides user to booking request flow.

## Structured Outputs
- Each generation is summarized into:
- `intent`
- `extracted` lead fields
- `recommendations`
- `actions`
- Stored in `ai_interaction_log.output_summary`.

## Safety Constraints
- Redaction on audit logs for emails/phones/cards.
- Disallowed sensitive collection flagged in `safety_flags`.
- AI auto-replies only when thread status is `open`.
- Pro messages switch thread to `pro_active`, disabling auto AI.

## Rollout Flags
- `ai_chat_enabled_global`
- `ai_chat_enabled_city`
- `ai_chat_enabled_pro`
- `ai_chat_kill_switch`

## Cost Controls
- Outbox-based generation via topic `ai.reply.generate`.
- Token accounting stored in `ai_interaction_log`.
- Thread/message rate limits:
- `chat_messages`
- `thread_creations`
