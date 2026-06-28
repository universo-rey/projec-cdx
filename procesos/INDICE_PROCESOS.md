# Indice De Procesos

## Al Frente

- [cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/procesos/cierre-wave-documental.md)
- [dataverse-rehidratacion.md](C:/Users/enzo1/PROJEC%20CDX/procesos/dataverse-rehidratacion.md)
- [normalizacion-perfil-windows.md](C:/Users/enzo1/PROJEC%20CDX/procesos/normalizacion-perfil-windows.md)
- [agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md)
- [microsoft-live-read-preliminar.md](C:/Users/enzo1/PROJEC%20CDX/procesos/microsoft-live-read-preliminar.md)
- [sdu-dataverse-metadata-wave.md](C:/Users/enzo1/PROJEC%20CDX/procesos/sdu-dataverse-metadata-wave.md)
- [promocion-huella-tenant-dataverse.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promocion-huella-tenant-dataverse.md)
- [promocion-seshat-home-sharepoint.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promocion-seshat-home-sharepoint.md)
- [planner-sharepoint-sdu-preprod-expediente.md](C:/Users/enzo1/PROJEC%20CDX/procesos/planner-sharepoint-sdu-preprod-expediente.md)
- [documentos-canon-atomico](C:/Users/enzo1/.codex/skills/documentos-canon-atomico/SKILL.md)

| id | proceso | entrada | salida | receta | patron |
| --- | --- | --- | --- | --- | --- |
| PR-001 | Abrir hilo con contexto | Pedido nuevo | Semaforo y unico proximo movimiento | - | P-002 |
| PR-002 | Ejecutar delta gobernado | Objetivo acotado | [delta-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/delta-gobernado.md) | - | P-001 |
| PR-003 | Cerrar ronda durable | Delta completado | [hito-versionado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/hito-versionado.md) | [recipes/cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/recipes/cierre-wave-documental.md) | P-003 / P-006 |
| PR-004 | Dataverse sin inferencia | Pedido Dataverse/Microsoft | [dataverse-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/dataverse-gobernado.md) | - | P-004 / P-012 |
| PR-005 | Regenerar workbook de control | Cambio en operativa | XLSX, renders, inspect y manifest | - | P-005 |
| PR-006 | Compactar sin perder evidencia | Pedido de limpieza | Retencion con rollback | - | P-007 |
| PR-007 | Revisar con agente read-only | Riesgo de hueco fino | Hallazgos o PASS | - | P-009 |
| PR-008 | Control total rapido | Cierre o handoff | `GREEN`, `YELLOW` o `RED` interpretado | - | P-010 |
| PR-009 | Control operativo | Reanudacion o pedido nuevo | [control-operativo.md](C:/Users/enzo1/PROJEC%20CDX/procesos/control-operativo.md) | - | - |
| PR-010 | Preflight gobernado | Antes de tocar superficies | [preflight-gobernado.md](C:/Users/enzo1/PROJEC%20CDX/procesos/preflight-gobernado.md) | - | - |
| PR-011 | Postcheck local | Delta ejecutado | [postcheck-local.md](C:/Users/enzo1/PROJEC%20CDX/procesos/postcheck-local.md) | - | P-008 |
| PR-012 | Manifest minimo | Salida durable | [manifest-minimo.md](C:/Users/enzo1/PROJEC%20CDX/procesos/manifest-minimo.md) | - | - |
| PR-013 | Retencion gobernada | Limpieza o compactacion | [retencion-gobernada.md](C:/Users/enzo1/PROJEC%20CDX/procesos/retencion-gobernada.md) | - | P-007 |
| PR-014 | Promover aprendizaje | Patron estable | [promover-aprendizaje.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promover-aprendizaje.md) | - | - |
| PR-015 | Sincronizacion tiempo real | Fuente viva, corrida y hito alineados | [sincronizacion-tiempo-real.md](C:/Users/enzo1/PROJEC%20CDX/procesos/sincronizacion-tiempo-real.md) | - | P-013 |
| PR-016 | Cierre wave documental | Delta documental, archivo o hito a absorber | [cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/procesos/cierre-wave-documental.md) | [recipes/cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/recipes/cierre-wave-documental.md) | P-003 / P-006 |
| PR-017 | Procedencia layout on-demand | Configuracion interna, ancla o nota visible compacta | [procedencia-layout-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/procedencia-layout-on-demand.md) | [recipes/procedencia-layout-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/recipes/procedencia-layout-on-demand.md) | P-012 |
| PR-018 | Complementos on-demand | Complemento, plugin o MCP directo pedido por demanda | [complementos-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/procesos/complementos-on-demand.md) | [recipes/complementos-on-demand.md](C:/Users/enzo1/PROJEC%20CDX/recipes/complementos-on-demand.md) | - |
| PR-019 | Agentes atomicos algoritmicos en waves | Delegacion por waves con lanes disjuntas | [agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md) | [recipes/agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/recipes/agentes-atomicos-algoritmicos-en-waves.md) | P-001 / P-011 |
| PR-020 | Limpieza PC local segura | Limpieza y recorte de ruido local | [limpieza-pc-local-segura.md](C:/Users/enzo1/PROJEC%20CDX/procesos/limpieza-pc-local-segura.md) | [recipes/limpieza-pc-local-segura.md](C:/Users/enzo1/PROJEC%20CDX/recipes/limpieza-pc-local-segura.md) | P-007 |
| PR-021 | Canon documental | Convertir hilos y docs en canon navegable | [canon-documental.md](C:/Users/enzo1/PROJEC%20CDX/procesos/canon-documental.md) | [recipes/canon-documental.md](C:/Users/enzo1/PROJEC%20CDX/recipes/canon-documental.md) | P-014 |
| PR-022 | Dataverse rehidratacion | Volver a una base Dataverse verificable sin confundir contexto con live | [dataverse-rehidratacion.md](C:/Users/enzo1/PROJEC%20CDX/procesos/dataverse-rehidratacion.md) | [recipes/dataverse-rehidratacion.md](C:/Users/enzo1/PROJEC%20CDX/recipes/dataverse-rehidratacion.md) | P-015 |
| PR-023 | Canon documental atomico | Atlas documentales visibles con una sola taxonomia | [documentos-canon-atomico.md](C:/Users/enzo1/PROJEC%20CDX/procesos/documentos-canon-atomico.md) | [recipes/documentos-canon-atomico.md](C:/Users/enzo1/PROJEC%20CDX/recipes/documentos-canon-atomico.md) | P-022 |
| PR-024 | Microsoft live read preliminar | Pasada Microsoft preliminar con target exacto y no escritura | [microsoft-live-read-preliminar.md](C:/Users/enzo1/PROJEC%20CDX/procesos/microsoft-live-read-preliminar.md) | [recipes/microsoft-live-read-preliminar.md](C:/Users/enzo1/PROJEC%20CDX/recipes/microsoft-live-read-preliminar.md) | - |
| PR-025 | SDU Dataverse metadata wave | Evidencia tenant-scoped que debe volverse metadata atomica reusable | [sdu-dataverse-metadata-wave.md](C:/Users/enzo1/PROJEC%20CDX/procesos/sdu-dataverse-metadata-wave.md) | [recipes/sdu-dataverse-metadata-wave.md](C:/Users/enzo1/PROJEC%20CDX/recipes/sdu-dataverse-metadata-wave.md) | [patrones/sdu-dataverse-metadata-wave.md](C:/Users/enzo1/PROJEC%20CDX/patrones/sdu-dataverse-metadata-wave.md) |
| PR-026 | Promocion huella tenant Dataverse | Manifiesto o canon aprobado por owner debe quedar visible para tenant, Dataverse y agentes | [promocion-huella-tenant-dataverse.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promocion-huella-tenant-dataverse.md) | [recipes/promocion-huella-tenant-dataverse.md](C:/Users/enzo1/PROJEC%20CDX/recipes/promocion-huella-tenant-dataverse.md) | [patrones/huella-atomica-owner-approved.md](C:/Users/enzo1/PROJEC%20CDX/patrones/huella-atomica-owner-approved.md) |
| PR-027 | Promocion Seshat Home SharePoint | SeshatHubRegistroN.8/Home.aspx debe consumir la huella atomica como canon visible | [promocion-seshat-home-sharepoint.md](C:/Users/enzo1/PROJEC%20CDX/procesos/promocion-seshat-home-sharepoint.md) | [recipes/promocion-seshat-home-sharepoint.md](C:/Users/enzo1/PROJEC%20CDX/recipes/promocion-seshat-home-sharepoint.md) | [patrones/seshat-home-canonico.md](C:/Users/enzo1/PROJEC%20CDX/patrones/seshat-home-canonico.md) |
| PR-028 | Planner SharePoint SDU preprod expediente | Planner, SharePoint y SDU quedan listos para produccion notarial con matrices CDF/TGE | [planner-sharepoint-sdu-preprod-expediente.md](C:/Users/enzo1/PROJEC%20CDX/procesos/planner-sharepoint-sdu-preprod-expediente.md) | [recipes/planner-sharepoint-sdu-preprod-expediente.md](C:/Users/enzo1/PROJEC%20CDX/recipes/planner-sharepoint-sdu-preprod-expediente.md) | - |

## Regla

Si un proceso se repite tres veces, evaluar si debe pasar a playbook propio.
