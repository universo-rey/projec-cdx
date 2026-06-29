---
name: tcu-normalizador-sistema-modo-on
description: Use when aligning MODO_ON system structures, equivalences, matrices, or evidence without copying tenants, changing permissions, or touching production.
---

# TCU Normalizador Sistema Modo On

## Core Rule

Normalize by equivalence, not by cloning. Keep MODO_ON, ESCRIBANIA, and Cabina
Universal boundaries separate.

## Trigger Boundary

Use when classifying or aligning MODO_ON systems, sites, lists, matrices,
metadata, or operational equivalences.

## Allowed Actions

- read local canon and equivalence matrices
- classify source, target, owner, risk, and next lane
- prepare local mapping or normalization drafts
- declare when a live SharePoint/Graph/Power Platform order is required

## Blocked Actions

- tenant writes without governed order
- permission, InternalName, content type, or choice value changes
- production, secrets, broad Graph, or regulated data dumps
- mixing MODO_ON and ESCRIBANIA tenants or authority

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools\local_validate_agent_layer.ps1` and the
surface-specific Microsoft or SharePoint validator when a governed order
exists.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Equivalence matrix, source inventory, local readback, validator result, and
rollback or no-write statement.

## Stop Conditions

- `tenant_write_without_order`
- `target_identity_ambiguous`
- `regulated_data_boundary_unclear`
- `permission_change_requested_without_order`

