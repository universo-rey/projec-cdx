# Versioning Policy - SDU Organizacion Total G1 V3

## Alcance

Esta politica canoniza localmente el runner `.cabina/organizacion-total` como baseline candidate V3 bajo modo `G1_LOCAL_REVERSIBLE`.

## Se versiona

- Documentacion operativa del runner: `00_README_OPERATIVO.md`, `01_PROMPT_RECTOR_CODEX.md` y `RUNNER_KNOWLEDGE.md`.
- Politica y manifiesto de baseline: `VERSIONING_POLICY.md` y `BASELINE_CANDIDATE_G1_V3_MANIFEST.json`.
- Configuracion declarativa: `config/sdu-org-policy.json`, reglas V2/V3, mapa de roles y schemas.
- Scripts fuente del runner bajo `scripts/` y `scripts/lib/`.
- Documentacion de contrato bajo `docs/`.
- Templates declarativos bajo `templates/`.
- Workspace local del runner bajo `.vscode/`, limitado a `tasks.json` y `sdu-organizacion-total.code-workspace`.
- Evidencia saneada en Markdown aprobada para explicar decision, comparativas y frontera.

## No se versiona

- `out/*.csv`.
- `out/*.json`, salvo manifiestos explicitos aprobados fuera de `out`.
- `logs/`.
- Inventarios crudos.
- Registros crudos de riesgo, revision manual, move-plan, classification e inventory.
- Salidas masivas o evidencia con rutas/sensibilidad sin saneamiento.
- Cambios fuera de `.cabina/organizacion-total`, salvo `.gitignore` cuando sea actualizado intencionalmente para esta politica.

## Evidencia local conservada

La evidencia cruda permanece local en `out/` y `logs/` para trazabilidad operativa, pero no entra al commit por defecto. Esto evita versionar rutas, volumen operativo, clasificaciones intermedias o material sensible accidental.

## Evidencia saneada candidata

Puede versionarse evidencia Markdown que no incluya contenido sensible raw y que declare solo metricas, decisiones, frontera y rutas relativas del runner:

- `out/FINAL_READBACK_SDU_ORG_TOTAL_G1_V3.md`.
- `out/BASELINE_DECISION_G1_V3.md`.
- `out/G1_V2_V3_COMPARATIVE_REPORT.md`.
- `out/G1_V3_V31_SIM_COMPARATIVE_REPORT.md`.
- `out/FINAL_READBACK_SDU_ORG_TOTAL_G1_MULTIPLE_TRIAGE.md`.
- `out/FOREIGN_CHANGES_PREEXISTING_READBACK.md`.

## Reproduccion dry-run

Desde `C:\CEO\project-cdx` o el root Git efectivo:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\.cabina\organizacion-total\scripts\Invoke-SDUOrgFullDryRunV3.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\.cabina\organizacion-total\scripts\Invoke-SDUOrgValidate.ps1
```

La reproduccion no habilita apply real. Cualquier ejecucion real requiere gate humano posterior con target, owner, rollback, postcheck y evidencia.

## Frontera

- delete=false
- overwrite=false
- apply_real=false
- live=false
- push=false
- pr=false
- secretos=false
