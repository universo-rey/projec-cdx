---
name: cabina-teams-plugin-adapter
description: Use when Teams plugin work in D:\ needs channel, chat, message, notification, digest, reply, or Planner handling under Microsoft live gates.
---

# Cabina Teams Plugin Adapter

## Core Rule

Teams is a governed Microsoft live surface. Reads and writes require exact
team, channel, chat, message, identity, data limit, rollback, postcheck,
evidence, and stop condition before connector execution.

## Trigger Boundary

Use when work mentions Teams, team inventory, channels, chats, messages,
notifications, daily digest, reply drafting, or Planner tasks from Teams.

## Allowed Actions

- prepare bounded Teams read or write order packets
- draft messages or summaries from selected context
- use connector reads only after exact target and data limit are declared
- keep posting and Planner changes as separate write orders

## Blocked Actions

- broad tenant inventory without order
- raw transcript dumps
- permission changes
- secrets
- OpenAI API live
- production
- Microsoft live writes without exact order

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools`,
`C:\CEO\project-cdx\.agents\codex\tools`, and
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Target team/channel/chat, identity, read limit, action, rollback, postcheck,
connector availability, validator result, and readback.

## Stop Conditions

- `microsoft_live_requested_without_governed_order`
- `regulated_data_boundary_unclear`
- `order_packet_missing_required_fields`
- `secret_detected`


