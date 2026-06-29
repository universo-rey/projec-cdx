---
name: cabina-document-plugin-adapter
description: Use when Documents, Spreadsheets, Presentations, or PDF plugin work in D:\ needs local artifact handling, regulated-data boundary, render QA, or export evidence.
---

# Cabina Document Plugin Adapter

## Core Rule

Document plugins are local artifact capabilities unless a governed order opens
Microsoft live, broad regulated data, or external publication. Preserve source
boundaries and validate outputs proportionally.

## Trigger Boundary

Use when work mentions Word, DOCX, spreadsheet, CSV, Google Sheets-ready
workbook, PowerPoint, PPTX, PDF, render QA, formulas, decks, reports, or
document evidence.

## Allowed Actions

- create or edit local document artifacts
- inspect selected files with bounded data scope
- render or export local artifacts
- record source files, output files, validator, and limitations

## Blocked Actions

- broad regulated data processing without order
- Microsoft live writes without exact order
- secrets
- OpenAI API live
- production
- unsourced report claims

## Validator

Use `C:\CEO\project-cdx\.agents\codex\tools`,
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_agent_layer.ps1`, and
`C:\CEO\project-cdx\.agents\codex\tools\local_validate_skill_metadata.ps1`.

## Legacy Validator Surface

- legacy_path: true
- required: false
- status: deprecated
- path: `D:\.agents\codex\tools\`
- canonical_runtime: `C:\CEO\project-cdx\.agents\codex\tools\`
## Evidence

Selected source files, output path, render/check result, data boundary,
validator output, and readback.

## Stop Conditions

- `document_skill_lane_missing`
- `regulated_data_boundary_unclear`
- `secret_detected`
- `microsoft_live_requested_without_governed_order`


