---
artifact_id: VERSION_POLICY.md
categoria: procesos
tipo: plan
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: VERSION_POLICY.md
etiquetas:
  - versionado
  - snapshots
  - runtime
  - rollback
  - g7
relacionados:
  - operativa/ACTA_RUNTIME_VERSIONING_SNAPSHOTS_20260622.md
descripcion: Politica de versionado continuo, snapshots y restauracion gobernada de runtime.
---

# Version Policy

## Estado

`VERSIONADO_CONTINUO_ACTIVE`

## Semantica

- `vX.Y.Z`: version estable publicada.
- `vX.Y.Z-rcN`: release candidate gobernado.
- `vX.Y.Z-hotfixN`: correccion acotada sobre una version publicada.

## Incrementos

- `X`: cambio estructural grande.
- `Y`: evolucion funcional.
- `Z`: ajuste menor compatible.
- `rcN`: candidato previo a cierre estable.
- `hotfixN`: correccion de emergencia con rollback y postcheck.

## Reglas de gobierno

- Ningun commit relevante queda sin version destino o delta asociado.
- Todo merge se evalua contra una version destino.
- Todo tag apunta al commit final publicado, no a un candidato intermedio.
- Todo release requiere checks verdes y evidencia de frontera.
- Todo restore requiere workspace limpio y confirmacion explicita.
- Todo merge a `main` requiere snapshot previo valido.
- Todo release requiere snapshot asociado al commit objetivo.
- Todo cambio de configuracion runtime requiere snapshot previo o acta de excepcion.
- Todo ciclo G7 requiere snapshot previo, reporte de divergencias e indicadores.

## Version de paquete Python

- La version institucional usa tags Git con prefijo `v`, por ejemplo `v0.6.0-rc1`.
- La version Python en `pyproject.toml` usa formato PEP 440 equivalente, sin `v` y sin guion de pre-release: `0.6.0rc1`.
- Para un release candidate, `vX.Y.Z-rcN` corresponde a paquete `X.Y.ZrcN`.
- Si el repo publica paquete, `pyproject.toml` debe alinearse al tag institucional objetivo antes de release.
- Si el repo no publica paquete, cualquier divergencia debe quedar explicitamente documentada en acta de version.

## Eventos de versionado continuo

- Merge a `main`: incrementa `PATCH`.
- Cambio estructural en agentes, gates o runtime: incrementa `MINOR`.
- Cambio de modelo o arquitectura: incrementa `MAJOR`.
- Rama `codex/*`: queda asociada a un candidato `rc`.

## Estado dinamico

- `VERSION_STATE.json`: estado gobernado de version, branch, commit, reglas y ultimo snapshot.
- `operativa/snapshots/SNAPSHOT_INDEX.json`: indice versionado de snapshots reproducibles.
- `operativa/HISTORY_RUNTIME_EVOLUTION.md`: timeline narrativo de eventos runtime.
- `operativa/HISTORY_CONTINUOUS_EVOLUTION.md`: timeline de auditorias G7, divergencias y reconciliaciones.
- `operativa/sentinel/DRIFT_LOG.json`: log local de alertas, ignorado por Git hasta decision explicita.

## Comandos canonicos

- `ceo-runtime-save`: crear snapshot reproducible.
- `ceo-runtime-list`: listar snapshots disponibles.
- `ceo-runtime-restore`: restaurar o simular restauracion desde snapshot.
- `ceo-runtime-sentinel`: generar reporte de watchdog runtime.
- `ceo-runtime-status`: mostrar estado ejecutivo del runtime.
- `ceo-runtime-index`: regenerar indice de snapshots.
- `ceo-runtime-state`: regenerar estado dinamico de version.
- `ceo-runtime-continuous`: ejecutar ciclo G7 de mejora continua.
- `ceo runtime <comando>`: alias instalable para la familia runtime.

## G7 mejora continua

- Cada evento gobernado puede ejecutar `ceo-runtime-continuous`.
- El ciclo G7 crea snapshot previo, clasifica divergencias, calcula indicadores y deja evidencia.
- Si hay divergencias, prevalece el estado mas cercano al actual con gates completos y evidencia.
- G7 no autoriza live, writes externos, merge, tag ni release por si mismo.

## Frontera

- No live sin gate.
- No restore con cambios locales.
- No overwrite sin confirmacion.
- No secretos en snapshots.
