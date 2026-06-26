---
artifact_id: operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_20260622.md
etiquetas:
- cabina
- sdu
- version
- v0-6-0-candidate
- local-only
relacionados:
- operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_SCOPE_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_COMMIT_MATRIX_20260622.csv
- operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_EXCLUSIONS_20260622.csv
- operativa/archive/legacy-root/20260622/READBACK_VERSION_v0.6.0_CANDIDATE_20260622.md
descripcion: Paquete candidato local para version v0.6.0 posterior a v0.3.0 formal.
fecha_evento: '2026-06-22'
---

# VERSION v0.6.0 CANDIDATE 20260622

## Estado

`VERSION_v0.6.0_CANDIDATE_READY`

## Base

- Branch: `codex/multirepo-alignment-16`
- HEAD de entrada: `973a172b`
- Ultima version formal taggeada: `v0.3.0`
- Tags formales observados: `v0.1.0`, `v0.1.1`, `v0.3.0`
- Commits incluidos desde `v0.3.0`: `53`

## Dictamen

El repo ya contiene material suficiente para preparar un candidato `v0.6.0`, pero no para declarar `v0.6.0` final sin decision posterior de tag. El estado correcto de este delta es candidato local versionado, sin tag, sin push y sin PR.

## Alcance incluido

1. `0.4.x` - wave de patch remoto preparada local-only.
2. `0.5.0` - patch remoto controlado bridge auth fail-closed, no-live.
3. `0.5.1` - patch remoto controlado bridge loopback/MCP gating, no-live.
4. Reparacion metadata overlay.
5. Cierre local drift `NO_DRIFT`.
6. Reparacion PATH/runtime canonico documentada en control plane local.
7. Auditoria total stack y cierre de warnings.
8. Plan rector de gobierno total.
9. Activacion IDE control-plane.
10. Inventario W0 del sistema nervioso IDE.

## Alcance excluido

- Writes live no ejecutados.
- MCP execution.
- Dataverse write.
- Microsoft write.
- SharePoint write.
- Power Platform mutation.
- OpenAI live.
- Codex Cloud execution.
- Push remoto.
- PR remoto.
- Mutacion de DB/cache `.codex`.
- Limpieza destructiva.
- Repos hijos con dirty propio no cerrados por este delta.

## Artefactos del candidato

- `operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_20260622.md`
- `operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_SCOPE_MATRIX_20260622.csv`
- `operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_COMMIT_MATRIX_20260622.csv`
- `operativa/archive/legacy-root/20260622/VERSION_v0.6.0_CANDIDATE_EXCLUSIONS_20260622.csv`
- `operativa/archive/legacy-root/20260622/READBACK_VERSION_v0.6.0_CANDIDATE_20260622.md`

## Decision de version

El tag recomendado posterior es:

`v0.6.0-rc1`

`v0.6.0` final queda diferido hasta que el owner confirme promocion final y, si corresponde, clasifique W1 de repos hijos.

## Resultado

`VERSION_v0.6.0_CANDIDATE_READY`
