# Registro De Bloqueos Dataverse

Dataverse sirve mejor como registro de bloqueos, decisiones y escaladas humanas que como inventario general.

## Regla Practica

- Si el item es solo informacion, va al repo o al workbook.
- Si el item puede bloquear una wave, un PR o una escritura live, va a Dataverse.
- Si se resuelve solo con repos, README, workbook o validacion local, queda fuera de Dataverse.

## Modelo Minimo

### blocker_case

- `blocker_case`: que bloquea
- `superficie_afectada`
- `severidad`
- `estado`
- `owner`
- `fecha`

### human_decision

- `decision_requerida`
- `aprobador`
- `resultado`
- `fecha`

### evidence_required

- `que_falta_para_avanzar`
- `donde_esta_la_evidencia`
- `read_only_o_live`

### resolution_action

- `accion_minima`
- `rollback`
- `postcheck`

## Ejemplos De Uso

- permisos faltantes
- IDs o claves ambiguas
- validaciones que fallan
- gates humanos pendientes
- evidencia incompleta
- errores de alcance o superficie
- acciones live que requieren aprobacion
- rollback y postcheck pendientes

## Cierre

La frontera se cierra cuando la decision humana y la accion minima quedan registradas con evidencia suficiente para reanudar sin inferencia.
