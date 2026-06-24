# Prompt Cierre Wave

Bloque corto para reanudar una wave de cierre sin abrir todo el mapa.

Usarlo junto con `operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md` cuando haga falta abrir una superficie concreta.

```text
Continuar desde:
C:/Users/enzo1/PROJEC CDX/operativa/archive/legacy-root/undated/START_HERE.md
C:/Users/enzo1/PROJEC CDX/operativa/archive/legacy-root/20260615/READBACK_CIERRE_20260615.md
C:/Users/enzo1/PROJEC CDX/operativa/TRACE.md

Estado:
- PROJEC CDX ya está versionado, navegable y GREEN_OPERABLE.
- .codex y .agents ya tienen cadena corta y referencia visible.
- Auditar ya fue clasificado y cerrado en esta ronda.
- No tocar secretos, auth.json, cap_sid, global-state ni SQLite sin orden explícita.
- No hacer live write por inferencia.

Regla de trabajo:
- Arrancar con el delta nuevo solamente.
- Si hay cambios, validar solo ese delta.
- Mantener todo por capas: entrada corta, mapa corto, mapa maestro, evidencia, cierre.

Primer paso:
1. Leer START_HERE, TRACE y READBACK.
2. Identificar el delta nuevo real.
3. Ejecutar el siguiente movimiento único sin abrir frentes paralelos innecesarios.
```
