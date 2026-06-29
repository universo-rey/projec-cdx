---
name: cabina-sharepoint-plugin-adapter
description: Use when SharePoint plugin work in D:\ needs site, library, list, document, metadata, or evidence handling under Microsoft live gates.
---

# Cabina SharePoint Plugin Adapter

## Core Rule

SharePoint is governed live infrastructure. Every live read or write needs
exact site, library/list/item, identity, data limit, rollback, postcheck,
evidence, validator, and stop condition.

## Trigger Boundary

Use when work mentions SharePoint sites, lists, libraries, files, metadata,
evidence publication, site discovery, or Microsoft 365 document surfaces.

## Allowed Actions

- prepare SharePoint read or write order packets
- classify site/library/list targets before connector use
- draft local evidence or metadata plans
- execute connector reads or writes only when the governed order is complete

## Blocked Actions

- tenant-wide sweeps without order
- permission changes
- content type or InternalName changes without exact gate
- secrets
- OpenAI API live
- production
- Microsoft live writes without exact order

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools\local_validate_order_packets.ps1`,
`C:\CEO\project-cdx\.agents\codex\tools`, and
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Site URL, target object, identity, data limit, rollback, postcheck, validator
output, and readback.

## Stop Conditions

- `microsoft_live_requested_without_governed_order`
- `order_packet_missing_required_fields`
- `regulated_data_boundary_unclear`
- `secret_detected`


