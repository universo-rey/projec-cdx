---
name: tcu-harness-evals-agentes
description: Use when running local synthetic evals, dry-runs, or agent/cabina harness checks without OpenAI API live, production runtime, or sensitive data.
---

# TCU Harness Evals Agentes

## Core Rule

Default to local synthetic dry-runs. Do not call OpenAI API live, Batch API,
production runtime, or external agents unless a separate governed order exists.

## Trigger Boundary

Use for agent role validation, prompt or schema dry-runs, local cabina smokes,
and preflight harness checks.

## Allowed Actions

- run local synthetic fixtures
- produce parseable PASS, PARTIAL, or BLOCKED results
- compare cabina packages before higher-risk gates
- record evidence and next lane

## Blocked Actions

- OpenAI API live or Batch API without order
- production runtime
- secrets or regulated data
- external agent activation
- treating synthetic results as live proof

## Validator

Use `D:\.agents\codex\tools\local_run_repo_alignment_runtime.ps1` or the
surface-specific local validator.

## Evidence

Manifest, fixture description, trace summary, local result JSON, and readback.

## Stop Conditions

- `openai_api_live_requested_without_order`
- `secret_detected`
- `regulated_data_boundary_unclear`
- `runtime_evidence_missing`
