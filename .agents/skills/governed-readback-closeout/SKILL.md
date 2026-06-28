---
name: governed-readback-closeout
description: Use when a readback, closeout, validator result, evidence packet, or next-lane handoff must close local D-drive work under cabina governance.
---

# Governed Readback Closeout

## Core Rule

Do not claim closure until the local evidence, validator result, touched
systems, untouched systems, risk, rollback, and next lanes are written down.

## Trigger Boundary

Use this skill for local closeout only: readbacks, evidence summaries,
validator records, PR-ready handoffs, interrupted-session summaries, and
next-lane declarations. It does not authorize live reads or writes by itself.

## Allowed Actions

- Write sanitized readbacks under the allowlisted cabina evidence paths.
- Record local validator commands and results.
- Name touched and untouched surfaces.
- Declare risk, rollback, stop condition, and next lanes.
- Summarize GitHub PR or check evidence without adding secrets or raw regulated
  data.

## Blocked Actions

- `microsoft_live`
- `openai_api_live`
- `production`
- `secrets`
- Unverified completion claims.
- Raw Teams, SharePoint, tenant, or regulated-content dumps in repo artifacts.

## Minimum Readback

Use this structure:

```markdown
# READBACK_<FRONT>_<YYYYMMDD>

## Estado
HECHO_VERIFICADO:

## Sistemas tocados

## Sistemas no tocados

## Cambios

## Validacion

## Riesgos

## Rollback

## Proximos carriles
```

## Validation Order

1. Run the most specific local validator.
2. Run `local_validate_agent_layer.ps1` when the agent layer changed.
3. Run `local_validate_skill_metadata.ps1` when repo-local skills changed.
4. Check that no GitHub, Microsoft, OpenAI live, SharePoint, Power Platform,
   tenant, production, or secret surface was touched unless explicitly ordered.

## Validator

For repo-local cabina changes, run:

```powershell
.agents\codex\tools\local_validate_operational_chain.ps1
.agents\codex\tools\local_validate_skill_metadata.ps1
```

## Stop Conditions

- Validator not run.
- Readback omits touched systems, untouched systems, risk, rollback, or next
  lanes.
- Secret-like content is present.
- External surface was touched without governed order, rollback, postcheck, and
  evidence.

## Output Contract

Every closeout must include `agente`, `orden`, `superficie`, `skill`,
`receta`, `tool`, `estado`, `evidencia`, `validador`, `riesgo`, `rollback`,
`stop_condition`, and `proximos_carriles`.
