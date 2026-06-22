---
artifact_id: operativa/READBACK_CABINA_IDE_CONTROL_PLANE_20260622.md
categoria: operativa
tipo: readback
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/READBACK_CABINA_IDE_CONTROL_PLANE_20260622.md
etiquetas:
- cabina
- ide-control-plane
- vscode-insiders
- readback
- local-only
relacionados:
- operativa/CABINA_IDE_CONTROL_PLANE_20260622.md
- operativa/CABINA_IDE_CONTROL_PLANE_LANES_20260622.csv
- operativa/CABINA_IDE_RUNNER_COMMAND_INDEX_20260622.csv
descripcion: Readback que registra VS Code Insiders como cabina de mando local del sistema nervioso PROJEC CDX.
fecha_evento: '2026-06-22'
---

# READBACK CABINA IDE CONTROL PLANE 20260622

## Estado

`CABINA_IDE_CONTROL_PLANE_READY`

## Lectura

VS Code Insiders deja de tratarse como editor pasivo y queda registrado como control-plane local para el sistema nervioso existente. El workspace rector sigue siendo `C:\CEO\project-cdx`; el alias fisico `C:\Users\enzo1\PROJEC CDX` no se convierte en segundo workspace activo.

## Evidencia

- VS Code Insiders `1.126.0-insider`.
- Extensiones totales observadas: `126`.
- Extensiones agente/OpenAI/Codex/Copilot: `36`.
- Extensiones Microsoft/Azure/M365/Power Platform: `49`.
- Extensiones Python/Data/Docs: `20`.
- Extensiones GitHub/CodeQL/GitLens: `7`.
- Manual Codex local confirma que IDE extension usa Codex CLI y configuracion compartida.

## Artefactos creados

- `operativa/CABINA_IDE_CONTROL_PLANE_20260622.md`
- `operativa/CABINA_IDE_CONTROL_PLANE_LANES_20260622.csv`
- `operativa/CABINA_IDE_RUNNER_COMMAND_INDEX_20260622.csv`
- `operativa/READBACK_CABINA_IDE_CONTROL_PLANE_20260622.md`

## No ejecutado

- No se movieron carpetas.
- No se modifico `.codex`.
- No se mutaron DBs.
- No se limpio cache.
- No se ejecuto MCP.
- No se abrio live.
- No se hizo push.
- No se abrio PR.
- No se leyeron ni imprimieron secretos.

## Resultado

`CABINA_IDE_CONTROL_PLANE_READY`
