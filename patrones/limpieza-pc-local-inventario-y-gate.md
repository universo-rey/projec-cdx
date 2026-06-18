# Limpieza PC Local Inventario Y Gate

## Uso

Aplicar antes de tocar temporales, auxiliares o cualquier elemento que pueda parecer "ruido" pero pertenezca a la base de Windows.

## Regla

Primero inventariar, luego clasificar. Separar base Windows de ruido auxiliar por nombre exacto, ruta exacta y efecto observable.

## Hacer

- Confirmar que el alcance es local y que no hay carril live.
- Revisar procesos, servicios, startup, PATH y superficie de busqueda.
- Marcar como `BASE_WINDOWS` todo lo que toque `C:\Windows`, Defender, Windows Update, credenciales, `.git`, `node_modules` o trabajo abierto.
- Marcar como `AUXILIAR_APROBADO` solo lo que ya tenga nombre o ruta exacta aprobada.
- Marcar como `AMBIGUO` cualquier item que no se pueda justificar sin inferencia.

## Salida

Inventario corto con gate claro, items no tocables y lista reducida de candidatos reales.

## Stop Condition

`target_ambiguous`, `base_windows_at_risk`, `live_surface_detected`
