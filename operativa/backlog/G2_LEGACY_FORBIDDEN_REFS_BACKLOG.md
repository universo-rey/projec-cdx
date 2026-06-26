# G2 Legacy Forbidden References Backlog

Estado:
LEGACY_DEBT_REGISTERED_NON_BLOCKING

Origen:
Broad active-surface scan detecto 93 referencias legacy fuera del delta G2.
El scan ampliado de esta pasada, incluyendo rutas CEO como hardcode canonico, detecta 124 referencias heredadas.

Criterio:
No bloquean G2 porque:
- no pertenecen a superficie modificada por G2
- G2 changed surface scan dio 0 forbidden references
- runtime isolation es true
- tests G2 PASS
- git diff --check PASS

Regla:
Estas referencias deberan tratarse en una fase posterior:
G2B_LEGACY_REFERENCE_SANITIZATION
o
G3_CANON_SURFACE_HARDENING

No corregir masivamente en G2.

Resumen de deuda observada:
- tools/codex-control-total.ps1
- tools/update_codex_config_workbook.py
- tools/ceo-execution-reconciliation-g1.ps1
- tools/normalize_codex_surfaces.ps1
- tools/README.md
- tools/test_codex_powershell_layout.ps1
- tools/codex-environment-setup.ps1
- tools/validate_proj_cdx_sync.ps1
- tools/validate_proj_cdx_operational_chain.ps1
- tools/MAPA.md
- tools/build_skills_unified_table.ps1
- tools/codex-cloud-bootstrap.ps1

Decision:
G2_EVENT_BUS_PERSISTENT_ENABLEMENT queda evaluado por alcance delta-scoped.
La deuda legacy queda registrada como backlog no bloqueante.
