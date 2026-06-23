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

## Comandos canonicos

- `ceo-runtime-save`: crear snapshot reproducible.
- `ceo-runtime-list`: listar snapshots disponibles.
- `ceo-runtime-restore`: restaurar o simular restauracion desde snapshot.
- `ceo-runtime-sentinel`: generar reporte de watchdog runtime.

## Frontera

- No live sin gate.
- No restore con cambios locales.
- No overwrite sin confirmacion.
- No secretos en snapshots.
