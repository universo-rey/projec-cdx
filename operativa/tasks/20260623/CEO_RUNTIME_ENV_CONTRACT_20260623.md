---
artifact_id: operativa/tasks/20260623/CEO_RUNTIME_ENV_CONTRACT_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/CEO_RUNTIME_ENV_CONTRACT_20260623.md
etiquetas:
  - runtime
  - environment
  - governance
  - local-only
relacionados:
  - operativa/tasks/20260623/CEO_RUNTIME_GOVERNANCE_MATRIX_20260623.csv
  - operativa/archive/legacy-root/20260622/RUNTIME_CLI_MATRIX_20260622.csv
  - operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json
  - VERSION_STATE.json
descripcion: Contrato local del entorno runtime CEO, entrypoint canonico, snapshot baseline y estrategia de divergencia sin live.
---

# CEO Runtime Environment Contract 20260623

## Estado

`RUNTIME_CEO_ENV_CONTRACT_PARTIAL_MACHINE_ENV_BLOCKED`

## Contrato

- Fuente durable de `CEO_ROOT`: User ENV.
- Fuente durable de `CODEX_START_ROOT`: User ENV.
- Valor canonico de ambos: `C:\CEO`.
- `Machine ENV` no debe definir `CEO_ROOT` ni `CODEX_START_ROOT`.
- Perfiles PowerShell no deben setear `CEO_ROOT` ni `CODEX_START_ROOT`.
- `.codex/config.toml` no debe duplicar `CODEX_START_ROOT`; conserva rutas especificas de runtime y herramientas.

## Estado Vivo Del Delta

- User ENV define `CEO_ROOT=C:\CEO`.
- User ENV define `CODEX_START_ROOT=C:\CEO`.
- `.codex/config.toml` ya no duplica `CODEX_START_ROOT`.
- Perfiles PowerShell no setean `CEO_ROOT` ni `CODEX_START_ROOT`.
- Machine ENV todavia define `CODEX_START_ROOT=C:\`; la remocion requiere sesion elevada.

## Entrypoint

- Comando canonico: `ceo-runtime-status`.
- PATH canonico: `C:\CEO\tools\bin`.
- Wrapper canonico: `C:\CEO\tools\bin\ceo-runtime-status.cmd`.
- Implementacion repo-local: `tools/ceo-runtime-status.ps1`.

## Snapshot

El baseline operativo se genera con `runtime_versioning.cli save` sobre `HEAD` y version `v0.6.0-rc1`. Es local-only y no publica tag, PR ni push. Si el workspace contiene evidencia local del contrato, el snapshot debe declararse diagnostico hasta que se commitee o se cierre el bloqueo de Machine ENV.

- Snapshot generado: `CEORUNTIME_20260623_0246`.
- Commit snapshot: `c2630a1cbf9f01ab7922b585704ff655d7898220`.
- Tipo: `runtime-env-contract`.
- Estado: `dirty=true` por evidencia local nueva sin commit.

## Bloqueo Elevado

La remocion de `Machine ENV CODEX_START_ROOT=C:\` requiere sesion elevada. Comando exacto para una consola elevada:

```powershell
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v CODEX_START_ROOT /f
```

## Divergencia

La rama `codex/runtime-versioning-snapshots` queda en estrategia `PREPARED_NO_LIVE`: medir ahead, conservar local si el owner no abre remoto, o sincronizar por PR gobernado solo con confirmacion explicita.

## Frontera

- No live.
- No PR.
- No push.
- No workflow dispatch.
- No secretos.
- No repos funcionales.

## Governance

La matriz minima vive en `operativa/tasks/20260623/CEO_RUNTIME_GOVERNANCE_MATRIX_20260623.csv`.
