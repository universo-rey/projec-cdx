# Prompt Nuevo Hilo

Usar este bloque para abrir un hilo nuevo sin perder contexto operativo.

```text
Trabajar en C:/CEO/project-cdx.

Primero leer:
1. C:/CEO/project-cdx/README.md
2. C:/CEO/project-cdx/MAPA_MAESTRO.md
3. C:/CEO/project-cdx/operativa/START_HERE.md
4. C:/CEO/project-cdx/operativa/CONTROL.md
5. C:/CEO/project-cdx/operativa/CURRENT.md
6. C:/CEO/project-cdx/operativa/NEXT.md
7. C:/CEO/project-cdx/operativa/BLOCKERS.md

Reglas:
- Operar por activacion gobernada: condicion habilitante, accion posible, evidencia requerida y oportunidad detectada.
- No leer secretos.
- No tocar auth.json ni cap_sid.
- No editar global-state ni SQLite sin orden explicita.
- No ejecutar live Dataverse, Power Platform, Power Automate, Microsoft, Git remoto o red sin target, owner, rollback, postcheck y evidencia.
- Si el frente toca Dataverse, leer C:/CEO/project-cdx/dataverse/GATE.md antes de cualquier accion.
- Mantener respuestas cortas y operativas.

Primer paso:
1. Ejecutar el preflight local de C:/CEO/project-cdx/playbooks/00-preflight-gobernado.md si aplica al delta.
2. Reportar semaforo.
3. Ejecutar el primer movimiento local/reversible/validable o escalar solo el riesgo real.
```
