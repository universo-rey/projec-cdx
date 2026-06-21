# Security Policy

## Supported Version

This repository is in the `0.1.x` baseline phase. Security fixes are handled on `main`
and released through tagged versions when a release exists.

## Reporting A Vulnerability

Do not open public issues for secrets, tokens, credential leaks or exploitable behavior.

Report security concerns privately to the repository owner:

- Owner: `SeshatSgin`
- Preferred channel: private GitHub communication or direct owner channel already used by the project.

Include:

- Affected file, command or workflow.
- Reproduction steps if safe.
- Expected impact.
- Whether a secret, token or live external surface is involved.

## Handling Rules

- Do not print secrets in logs, issues, PRs or readbacks.
- Do not read `.env.local` unless the owner explicitly authorizes it.
- Do not run live writes against Microsoft, Dataverse, SharePoint, GitHub or OpenAI without an explicit owner gate.
- Prefer read-only reproduction and minimal patches.

## Response Target

- Triage: best effort within 7 days.
- Critical exposure: immediate owner gate and credential rotation path.
- Fixes: via protected PR with required checks.
