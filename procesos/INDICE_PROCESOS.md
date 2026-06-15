# Indice De Procesos

| id | proceso | entrada | salida |
| --- | --- | --- | --- |
| PR-001 | Abrir hilo con contexto | Pedido nuevo | Semaforo y unico proximo movimiento |
| PR-002 | Ejecutar delta gobernado | Objetivo acotado | [delta-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/delta-gobernado.md) |
| PR-003 | Cerrar ronda durable | Delta completado | [hito-versionado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/hito-versionado.md) |
| PR-004 | Dataverse sin inferencia | Pedido Dataverse/Microsoft | [dataverse-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/dataverse-gobernado.md) |
| PR-005 | Regenerar workbook de control | Cambio en operativa | XLSX, renders, inspect y manifest |
| PR-006 | Compactar sin perder evidencia | Pedido de limpieza | Retencion con rollback |
| PR-007 | Revisar con agente read-only | Riesgo de hueco fino | Hallazgos o PASS |
| PR-008 | Control total rapido | Cierre o handoff | `GREEN`, `YELLOW` o `RED` interpretado |
| PR-009 | Control operativo | Reanudacion o pedido nuevo | [control-operativo.md](C:/Users/enzo1/PROJEC%20CDX/procesos/control-operativo.md) |
| PR-010 | Preflight gobernado | Antes de tocar superficies | [preflight-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/preflight-gobernado.md) |
| PR-011 | Postcheck local | Delta ejecutado | [postcheck-local.md](C:/Users/enzo1/PROJEC%20CDX/procesos/postcheck-local.md) |
| PR-012 | Manifest minimo | Salida durable | [manifest-minimo.md](C:/Users/enzo1/PROJEC%20CDX/procesos/manifest-minimo.md) |
| PR-013 | Retencion gobernada | Limpieza o compactacion | [retencion-gobernada.md](C:/Users/enzo1/PROJEC%20CDX/procesos/retencion-gobernada.md) |
| PR-014 | Promover aprendizaje | Patron estable | [promover-aprendizaje.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promover-aprendizaje.md) |
| PR-015 | Sincronizacion tiempo real | Fuente viva, corrida y hito alineados | [sincronizacion-tiempo-real.md](C:/Users/enzo1/PROJEC%20CDX/procesos/sincronizacion-tiempo-real.md) |
| PR-016 | Cierre wave documental | Delta documental, archivo o hito a absorber | [cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/procesos/cierre-wave-documental.md) |
| PR-017 | Procedencia layout on-demand | Configuracion interna, ancla o nota visible compacta | [procedencia-layout-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/procedencia-layout-on-demand.md) |
| PR-018 | Complementos on-demand | Complemento, plugin o MCP directo pedido por demanda | [complementos-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/complementos-on-demand.md) |
| PR-019 | Agentes atomicos algoritmicos en waves | Delegacion por waves con lanes disjuntas | [agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md) |
| PR-020 | Limpieza PC local segura | Limpieza y recorte de ruido local | [limpieza-pc-local-segura.md](C:/Users/enzo1/PROJEC%20CDX/procesos/limpieza-pc-local-segura.md) |

## Regla

Si un proceso se repite tres veces, evaluar si debe pasar a playbook propio.
