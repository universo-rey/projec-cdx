# Indice De Patrones

| id | patron | uso | destino |
| --- | --- | --- | --- |
| P-001 | Delta gobernado | Convertir pedido en unidad reversible | `playbooks/`, `operativa/` |
| P-002 | Mapa visible corto | Evitar raices largas y archivos huerfanos | `README.md`, `MAPA_MAESTRO.md` |
| P-003 | Fuente-proceso-salida-hito-cierre | Cerrar sin depender de conversacion | [trazabilidad-5-campos.md](C:/Users/enzo1/PROJEC%20CDX/patrones/trazabilidad-5-campos.md) |
| P-004 | Gate antes de live | Separar local, metadata-only y live | `dataverse/GATE.md` |
| P-005 | Workbook al frente | Volver seguimiento documental en tablero | `workbooks/`, `outputs/` |
| P-006 | Hito versionado | Congelar cierres durables | `hitos/YYYYMMDD-nombre-vN/` |
| P-007 | Retencion gobernada | No limpiar evidencia a ciegas | `operativa/RETENCION.md`, `outputs/RETENCION.md` |
| P-008 | Validador antes de cierre | No declarar verde sin postcheck | `tools/validate_proj_cdx_workbench.ps1` |
| P-009 | Agente revisor read-only | Encontrar huecos sin mezclar escrituras | `operativa/READBACK_*` |
| P-010 | Amarillo guardrail | Distinguir riesgo gobernado de bloqueo real | `operativa/CONTROL_TOTAL_*.md` |
| P-011 | Workbench atomico accionable | Mantener entradas breves y energeticas | [workbench-atomico.md](C:/Users/enzo1/PROJEC%20CDX/patrones/workbench-atomico.md) |
| P-012 | No confundir estados | Evitar inferir live o ejecucion desde evidencia parcial | [no-confundir-estados.md](C:/Users/enzo1/PROJEC%20CDX/patrones/no-confundir-estados.md) |
| P-013 | Sincronizacion tiempo real | Alinear fuentes, corridas y cierres inmediatamente | [sincronizacion-tiempo-real.md](C:/Users/enzo1/PROJEC%20CDX/patrones/sincronizacion-tiempo-real.md) |

## Regla

El indice solo resume. El detalle vive en `PATRONES_OPERATIVOS.md`.
