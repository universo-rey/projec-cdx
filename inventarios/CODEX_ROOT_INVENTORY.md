# CODEX Root Inventory

Date: 2026-06-16

## Confirmed Heavy Root

- `C:\Users\enzo1\Documents\Cumplimiento` -> `19.53 GB`
- Git root: `C:\Users\enzo1\Documents\Cumplimiento`
- Status: live workspace, dirty, untracked `AUDITORIA_CODEX_LOCAL/`, `.vscode/`, `finalize_codex_local_audit.ps1`, `run_codex_local_audit.ps1`

## Breakdown

- `C:\Users\enzo1\Documents\Cumplimiento\AUDITORIA_CODEX_LOCAL` -> `16.76 GB`
- `C:\Users\enzo1\Documents\Cumplimiento\.git` -> `2.77 GB`

## Top-Level Documents Scan

Largest entries under `C:\Users\enzo1\Documents`:

1. `Cumplimiento` -> `19.53 GB`
1. `CodexLocal` -> `14.53 GB`
1. `ESCRIBANIA BITSCH` -> `6.03 GB`
1. `GitHub` -> `4.34 GB`
1. `Maquina de Trabajo` -> `3.27 GB`
1. `PowerShell` -> `1.14 GB`
1. `WindowsPowerShell` -> `1.10 GB`
1. `Documentos Personales` -> `1.04 GB`

## Top-Level GitHub Scan

Largest entries under `C:\Users\enzo1\Documents\GitHub`:

1. `Sgin__wt_dictamen_n3_skills` -> `2.57 GB`
1. `Auditar` -> `1.22 GB`
1. `cabina-universal-d` -> `0.51 GB`

## Classification

- `Cumplimiento`: canonical code root candidate, confirmed by Git and size
- `AUDITORIA_CODEX_LOCAL`: dominant working payload inside the root
- `.git`: canonical repository metadata, keep intact
- remaining top-level documents: document or evidence surfaces, not yet promoted

## Maintenance Rule Draft

- Measure before moving.
- Never promote a guessed root.
- Keep mirrors, caches, and evidence separate from canonical code.
- Preserve rollback path before any relocation.
