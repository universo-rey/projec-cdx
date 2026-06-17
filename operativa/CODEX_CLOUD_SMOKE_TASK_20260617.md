# Codex Cloud Smoke Task 20260617

## Estado

READY_FOR_CODEX_CLOUD_UI

## Target

- Repo: `universo-rey/projec-cdx`
- Branch: `codex/dataverse-corte-ejecutora-v1`
- Environment: `PROJEC CDX`
- Image: `universal`

## Prompt Para Codex Cloud

```text
Ejecuta un smoke gobernado de PROJEC CDX en Codex Cloud.

Objetivo:
- Confirmar que el entorno clona la rama codex/dataverse-corte-ejecutora-v1.
- Confirmar que el setup corre sin usar rutas Windows.
- Confirmar que el paquete Python instala.
- Ejecutar: python -m projec_cdx_cloud --smoke
- Reportar exactamente:
  - branch observada
  - context_ok
  - context_drift
  - agents_sdk_installed
  - agents_sdk_version
  - gate
  - mode
  - sdu_sdk_agents_defined

Reglas:
- No imprimir secretos.
- No ejecutar flows.
- No escribir en Microsoft, SharePoint ni Dataverse.
- No hacer push, PR ni cambios de archivos.
- Si OPENAI_API_KEY existe, solo reportar presencia booleana; no imprimir valor.
- Si falla, devolver causa, archivo implicado, comando fallido y delta minimo sugerido.

Cierre esperado:
- PASS si context_ok=True y sdu_sdk_agents_defined=6.
- OBSERVED si instala pero hay context_drift.
- FAIL si no instala, no encuentra rama, o el comando smoke no corre.
```

## Postcheck Esperado

```text
status: prepared
context_ok: True
context_drift: []
branch: codex/dataverse-corte-ejecutora-v1
agents_sdk_installed: True
gate: metadata-only
mode: cloud
sdu_sdk_agents_defined: 6
```

## Rollback

No requiere rollback si se respeta el prompt: es read-only/smoke.

## Evidencia Local Previa

- Commit remoto: `67e248e`
- Rama remota: `origin/codex/dataverse-corte-ejecutora-v1`
- Smoke local: `context_ok=True`
