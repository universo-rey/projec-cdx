# Despierta Traza del Flujo

## Fuente Maestra
- La traza completa vive en [CRONOLOGIA_MAESTRA_20260617.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CRONOLOGIA_MAESTRA_20260617.md).

## Cadena Actual
- Fuente: `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json` + `operativa/DATAVERSE_LIVE_ROWS_CONSUMER_SELECTED_20260618.csv`.
- Proceso: regenerar el workbook global para absorber Dataverse y el mapa actualizado de workspace/superficies locales/ramas.
- Salida: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`.
- Hito fuente: `hitos/20260617-rehidratacion-dataverse-desde-paquetes-v1`.
- Cierre: `operativa/READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md`.
- Cierre ramas: `operativa/READBACK_BRANCH_ORGANIZATION_20260618.md`.
- Etapa: `HOME_USER_ROOTS_NORMALIZED`.
- Siguiente delta: `delta_cabina_universal_d_surface_map`.

## Hito Nuevo
- [20260619-reuso-recursos-sdu1-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260619-reuso-recursos-sdu1-v1/README.md).

## Aprendizajes
- SDU 1 avanza mejor cuando reusa recursos ya inventariados y evita superficies nuevas.
- La historia util se vuelve energia cuando queda comprimida en un atomo reusable y reabrible.
- Menos ruido, mas certeza: objetivo, hito, evidencia y siguiente delta.

## Semaforo
- `VERDE_LIVIANO`: seguir por reuso local.
- `AMARILLO_CONTROLADO`: ampliar solo con evidencia nueva y cambio reversible.
- `ROJO_GOVERNED`: detener en live writes, secretos o superficies nuevas.
- Tope explorado hoy: `delta_home_usuario_root_wave`.

## Frontera Maxima
- La frontera maxima actual es `workbook + hitos + trazas + mapas`.
- La portabilidad a VPS se consigue reusando este mismo canon, no duplicando historia.
- Si un cambio no mejora portabilidad, evidencia o reutilizacion, queda por debajo de la frontera.

## Ola Home
- `CodexLocal`, `Projects`, `Sandboxes` e `Intake` ya existen como entradas minimas.
- `HOME_USUARIO` ya quedo levantado con indice, mapa y revision corta.
- [20260619-home-user-roots-normalized-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260619-home-user-roots-normalized-v1/README.md).
- El home del usuario ya no apunta solo a huecos.

## Regla
- Esta traza conserva solo el carril activo minimo.
- No rehidratar ni reempaquetar otra vez salvo orden explicita del owner.
- No mover superficies locales desde este carril; primero normalizar lectura.
