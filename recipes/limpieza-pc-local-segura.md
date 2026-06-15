# Limpieza PC Local Segura

Receta reusable para reducir ruido en una PC Windows local sin tocar la base del sistema ni superficies live.

## Cuando Usarla

Usar esta receta cuando el delta pida:

- diagnosticar lentitud, duplicacion o ruido de arranque;
- limpiar temporales locales autorizados;
- cerrar o desactivar auxiliares aprobados por nombre exacto;
- recortar la superficie de busqueda local;
- cerrar con evidencia, rollback y un unico siguiente gate.

## Derivacion

1. Confirmar que el delta es local y no live.
2. Levantar inventario de procesos, servicios, startup, PATH y busqueda.
3. Clasificar cada item como `NO_TOCAR`, `REQUIERE_DECISION`, `BAJO_RIESGO` o `BLOQUEADO`.
4. Limpiar solo temporales y caches autorizados dentro de rutas aprobadas.
5. Desactivar solo auxiliares aprobados por nombre exacto.
6. Reducir ruido de busqueda si la politica lo pide, sin tocar shell base ni servicios criticos.
7. Guardar evidencia, rollback y el unico proximo gate.
8. Registrar la salida en la traza y en la superficie Dataverse local.

## Guardrails

- No tocar `C:\Windows`, Defender, Windows Update ni servicios base por inferencia.
- No borrar repos, `.git`, `node_modules`, credenciales ni tokens.
- No cerrar procesos con trabajo abierto.
- No convertir este flujo en una escritura live sin orden explicita.

## Salida

PC mas gobernable, con ruido recortado y evidencia reusable.

## Stop Condition

- Falta gate.
- Falta evidencia.
- El target es ambiguo.
- El item apunta a infraestructura base.
- El cambio requiere live write o secreto.
