---
artifact_id: operativa/archive/legacy-root/undated/START_HERE.md
categoria: operativa
tipo: indice
estado: aprobado
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/archive/legacy-root/undated/START_HERE.md
etiquetas:
- operativa
- indice
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Punto de entrada operativo para hilos nuevos.
---

# Start Here

Entrada obligatoria para cualquier hilo nuevo abierto sobre `PROJEC CDX`.

## Orden

1. Leer `README.md`.
2. Leer `MAPA_MAESTRO.md`.
3. Leer `operativa/CONTROL.md`.
4. Leer `operativa/CURRENT.md`.
5. Leer `operativa/NEXT.md`.
6. Leer `operativa/archive/legacy-root/undated/BLOCKERS.md`.
7. Leer `dataverse/GATE.md` si el frente menciona Dataverse, Power Platform, Power Automate, Microsoft live o ambiente.
8. Si el frente es una wave de cierre, leer `operativa/archive/legacy-root/undated/START_HERE_CIERRE_WAVE.md`.
9. Ejecutar `playbooks/00-preflight-gobernado.md`.

## Regla De Trabajo

- Un delta activo por vez.
- Todo cambio debe tener salida verificable.
- Todo cierre durable debe actualizar `operativa/CURRENT.md` y `operativa/TRACE.md`.
- Si hay hito durable, versionar en `hitos/`.

## No Hacer Sin Orden Explicita

- Leer secretos.
- Tocar `auth.json` o `cap_sid`.
- Editar global-state o SQLite.
- Escribir en Dataverse, Power Platform, Microsoft live, Git remoto o superficies externas.
- Mover, borrar o compactar carpetas fuera del delta aprobado.

## Cierre Minimo

- Semaforo.
- Evidencia local.
- Proximo movimiento unico.
