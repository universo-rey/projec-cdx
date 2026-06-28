---
artifact_id: operativa/READBACK_CODEX_CLOUD_SDK_LAUNCH_20260617.md
categoria: operativa
tipo: readback
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/READBACK_CODEX_CLOUD_SDK_LAUNCH_20260617.md
etiquetas:
- operativa
- readback
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Readback del lanzamiento SDK de Codex Cloud con trazabilidad parcial.
fecha_evento: '2026-06-17'
---

# Readback Codex Cloud SDK Launch 20260617

Estado: `SDK_LOCAL_LAUNCH_OBSERVED_CLOUD_UI_FRONTIER`
Fecha local: `2026-06-17`
Control tower: `PROJEC CDX`

## Fuente

El owner pidio resolver el delta pendiente:

`delta_launch_prompt_in_codex_cloud_ui_or_codex_sdk_local_thread`

Se eligio el carril `codex_sdk_local_thread` porque el bridge local ya estaba preparado, el entorno tenia `OPENAI_API_KEY` presente como booleano y el Agents SDK estaba instalado.

## Comando Ejecutado

```powershell
python -m projec_cdx_cloud --agentic-cloud-bridge --prompt "Ejecuta el delta launch_prompt_in_codex_cloud_ui_or_codex_sdk_local_thread desde el carril SDK local. Llama inspect_cloud_bridge, no inventes API de Codex Cloud, no escribas en Microsoft/SharePoint/Dataverse/Power Automate, no imprimas secretos. Devuelve PASS/OBSERVED/FAIL, evidencia, sistemas tocados/no tocados y proximo delta unico." --json
```

## Resultado Del Agente SDK

- `status`: `ok`
- `model`: `gpt-5.4-mini`
- `final_output`: `OBSERVED`
- `inspect_cloud_bridge`: `PASS`
- `gate`: `metadata-only`
- `next_delta observado por el bridge`: `launch_prompt_in_codex_cloud_ui_or_codex_sdk_local_thread`

El agente confirmo que el bridge pasa, pero que no hay API de creacion/ejecucion de Codex Cloud expuesta en este carril. Por eso el cierre correcto no es `FAIL`: es `OBSERVED` con frontera externa de UI confirmada.

## Postcheck

- Rama local: `codex/dataverse-corte-ejecutora-v1`
- HEAD remoto observado: `93dd19aa503ac7135552a8f28be2ef80b5e29f6d`
- `python -m projec_cdx_cloud --smoke --json`: `context_ok=True`
- `context_drift=[]`
- `agents_sdk_installed=True`
- `agents_sdk_version=0.17.0`
- `sdu_sdk_agents_defined=6`
- `python -m projec_cdx_cloud --cloud-bridge --json`: `PASS`
- `CODEX_CLOUD_GATE=metadata-only`
- `CODEX_CLOUD_MODE=cloud`

## Sistemas Tocados

- OpenAI API mediante Agents SDK.
- Runtime local de Python.
- Filesystem local para lectura de artefactos.
- Git local.
- Lectura de rama remota en `origin`.

## Sistemas No Tocados

- No se creo task por API de Codex Cloud.
- No se ejecuto Microsoft live write.
- No se escribio en SharePoint.
- No se escribio en Dataverse.
- No se ejecuto Power Automate.
- No se imprimieron secretos.
- No se tocaron permisos.
- No se toco produccion.

## Resolucion Del Delta

El delta queda resuelto por el carril `codex_sdk_local_thread`.

La parte `codex_cloud_ui` queda separada como frontera externa opcional, no como bloqueo:

`delta_capture_codex_cloud_ui_smoke_result_if_owner_runs_external_task`

Ese delta solo aplica si el owner ejecuta el prompt en la UI Cloud y trae el resultado para capturarlo.

## Rollback

No hay rollback live porque no hubo writes externos. Si se invalida la evidencia, revertir este readback, la matriz asociada y el hito `20260617-codex-cloud-sdk-launch-v1`.
