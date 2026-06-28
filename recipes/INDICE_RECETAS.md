# Indice De Recetas

## Al Frente

- [cierre-wave-documental.md](C:/CEO/project-cdx/recipes/cierre-wave-documental.md)
- [dataverse-rehidratacion.md](C:/CEO/project-cdx/recipes/dataverse-rehidratacion.md)
- [limpieza-pc-local-segura.md](C:/CEO/project-cdx/recipes/limpieza-pc-local-segura.md)
- [normalizacion-perfil-windows.md](C:/CEO/project-cdx/recipes/normalizacion-perfil-windows.md)
- [agentes-atomicos-algoritmicos-en-waves.md](C:/CEO/project-cdx/recipes/agentes-atomicos-algoritmicos-en-waves.md)
- [microsoft-live-read-preliminar.md](C:/CEO/project-cdx/recipes/microsoft-live-read-preliminar.md)
- [sdu-dataverse-metadata-wave.md](C:/CEO/project-cdx/recipes/sdu-dataverse-metadata-wave.md)
- [promocion-huella-tenant-dataverse.md](C:/CEO/project-cdx/recipes/promocion-huella-tenant-dataverse.md)
- [promocion-seshat-home-sharepoint.md](C:/CEO/project-cdx/recipes/promocion-seshat-home-sharepoint.md)
- [planner-anomaly-investigation.md](C:/CEO/project-cdx/recipes/planner-anomaly-investigation.md)
- [planner-hybrid-readback-stabilization.md](C:/CEO/project-cdx/recipes/planner-hybrid-readback-stabilization.md)
- [planner-sharepoint-sdu-preprod-expediente.md](C:/CEO/project-cdx/recipes/planner-sharepoint-sdu-preprod-expediente.md)
- [documentos-canon-atomico](C:/Users/enzo1/.codex/skills/documentos-canon-atomico/SKILL.md)

| id | receta | cuando usar | deja | proceso | patron |
| --- | --- | --- | --- | --- | --- |
| R-001 | Canon documental | Un hilo, readback, hito o carpeta necesita volverse canon navegable y reusable | Conocimiento estable, referenciable y retomable sin reconstruccion completa | [procesos/canon-documental.md](C:/CEO/project-cdx/procesos/canon-documental.md) | [patrones/canon-documental.md](C:/CEO/project-cdx/patrones/canon-documental.md) |
| R-002 | Cierre wave documental | Un delta documental ya tiene evidencia local y necesita quedar navegable | Cierre durable con menos repeticion manual | [procesos/cierre-wave-documental.md](C:/CEO/project-cdx/procesos/cierre-wave-documental.md) | P-003 / P-006 |
| R-003 | Procedencia layout on-demand | Una superficie tecnica no debe confundirse con habilitacion live | Procedencia aislada y lectura visible compacta | [procesos/procedencia-layout-on-demand.md](C:/CEO/project-cdx/procesos/procedencia-layout-on-demand.md) | P-012 |
| R-004 | Complementos on-demand | Hay que abrir o listar complementos sin inventar disponibilidad | Indice rapido de complementos, con acceso claro | [procesos/complementos-on-demand.md](C:/CEO/project-cdx/procesos/complementos-on-demand.md) | - |
| R-005 | Agentes atomicos algoritmicos en waves | El trabajo se puede partir en lanes pequenas con retorno exacto | Delegacion por waves con fan-in claro | [procesos/agentes-atomicos-algoritmicos-en-waves.md](C:/CEO/project-cdx/procesos/agentes-atomicos-algoritmicos-en-waves.md) | P-001 / P-011 |
| R-006 | Limpieza PC local segura | Hay ruido local de Windows que conviene recortar sin romper la workstation | Limpieza con inventario, gate, evidencia y rollback | [procesos/limpieza-pc-local-segura.md](C:/CEO/project-cdx/procesos/limpieza-pc-local-segura.md) | P-007 |
| R-007 | Configuracion entorno Codex UI | Hay que alinear la UI de Codex con la raiz local y el carril correcto | Entorno listo, runner usable y gate mantenido | - | - |
| R-008 | Dataverse rehidratacion | Un hilo largo necesita volver al carril Dataverse sin perder la base | Contexto recuperado, carril reducido y siguiente delta visible | [procesos/dataverse-rehidratacion.md](C:/CEO/project-cdx/procesos/dataverse-rehidratacion.md) | P-015 |
| R-009 | Normalizacion perfil Windows | El perfil local y OneDrive quedaron desalineados o rotos | Perfil normalizado, compatibilidad preservada y rutas conocidas coherentes | [procesos/normalizacion-perfil-windows.md](C:/CEO/project-cdx/procesos/normalizacion-perfil-windows.md) | P-016 |
| R-010 | Canon documental atomico | Los atlas documentales visibles necesitan una sola taxonomia | Atlas raiz, cronologia atomica, repo atlas y canon reusable visibles | [procesos/documentos-canon-atomico.md](C:/CEO/project-cdx/procesos/documentos-canon-atomico.md) | P-022 |
| R-011 | Microsoft live read preliminar | Una wave necesita revisar Microsoft en vivo sin escribir ni ampliar alcance | Plan read-only, tools permitidas/en espera de cierre, agentes alineados y condiciones de pausa | [procesos/microsoft-live-read-preliminar.md](C:/CEO/project-cdx/procesos/microsoft-live-read-preliminar.md) | - |
| R-012 | SDU Dataverse metadata wave | Una wave necesita hidratar Dataverse con metadata atomica sin ejecutar writes | Hito metadata-only, matriz de hidratacion, skill, validador y proximo delta | [procesos/sdu-dataverse-metadata-wave.md](C:/CEO/project-cdx/procesos/sdu-dataverse-metadata-wave.md) | [patrones/sdu-dataverse-metadata-wave.md](C:/CEO/project-cdx/patrones/sdu-dataverse-metadata-wave.md) |
| R-013 | Promocion huella tenant Dataverse | El owner aprueba una huella canonica que debe despertar tenant, Dataverse y agentes | Puntero live metadata-only, evidencia, hito y deltas sin bloqueo autonomo | [procesos/promocion-huella-tenant-dataverse.md](C:/CEO/project-cdx/procesos/promocion-huella-tenant-dataverse.md) | [patrones/huella-atomica-owner-approved.md](C:/CEO/project-cdx/patrones/huella-atomica-owner-approved.md) |
| R-014 | Promocion Seshat Home SharePoint | El canon de Seshat debe quedar visible en SeshatHubRegistroN.8/Home.aspx | Archivo canonico publicado, Dataverse hidratado y delta tecnico de binding | [procesos/promocion-seshat-home-sharepoint.md](C:/CEO/project-cdx/procesos/promocion-seshat-home-sharepoint.md) | [patrones/seshat-home-canonico.md](C:/CEO/project-cdx/patrones/seshat-home-canonico.md) |
| R-015 | Planner anomaly investigation | Una anomalía cruza Planner, watchdog, VSI/extensiones y runtime | Mesa paralela G50/G8-ready con cuatro threads, skills declaradas y fan-in | - | - |
| R-016 | Planner hybrid readback stabilization | Planner task y Teams history ya son confiables, pero Details/raw Graph siguen parciales | Snapshot task-level enriquecido, reglas anti falso missing y comentarios inferidos por Teams | - | - |
| R-017 | Planner SharePoint SDU preprod expediente | Planner, SharePoint y SDU quedan listos para produccion notarial con matrices CDF/TGE | Receta preprod con identidad, expediente, carpeta y snapshot | [procesos/planner-sharepoint-sdu-preprod-expediente.md](C:/CEO/project-cdx/procesos/planner-sharepoint-sdu-preprod-expediente.md) | P-012 / P-013 |

## Regla

- La receta se usa para orientar y absorber el delta.
- Si hace falta secuencia ejecutable, el paso siguiente vive en `procesos/`.
- Si cambia una receta o su cruce con skills, actualizar `inventarios/SKILLS_UNIFIED_TABLE.*` y la matriz de cruce.
