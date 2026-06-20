# Next

Movimiento unico:
`vigilar_superficie_nueva_o_conflicto_de_cobertura`

## Etapa Actual
- `COBERTURA_PLANES_REVISADA_Y_DATAVERSE_ALINEADA`.

## Proximo Delta
- Reabrir solo si aparece una entrada visible sin plan, o si dos planes reclaman la misma superficie.
- Si no aparece hueco nuevo, no inventar un frente adicional.
- Si Dataverse vuelve a cambiar, entrar por el plan de familia visible y no por la segunda pasada como puerta principal.
- Perfiles/variables y Data Analytics ya no quedan pendientes de integracion al mapa.
- El recorte posterior es `validator_points_to_legacy_missing_csv`, sin mapa nuevo.

## Semaforo
- `VERDE_GOBERNADO`: cobertura vigente y cierre operativo listo.
- `AMARILLO_CONTROLADO`: solo si surge una superficie huerfana o una colision de cobertura.
- `ROJO_GOVERNED`: dobles autoridades, legacy ambiguo o intento de abrir trabajo nuevo sin plan.

## Stop Condition
- No mover nada mas mientras la cobertura actual siga completa y legible.
- Cerrar cuando el indice de planes y el readback queden alineados.
- Cerrar tambien cuando la familia Dataverse quede representada por un solo camino visible.
