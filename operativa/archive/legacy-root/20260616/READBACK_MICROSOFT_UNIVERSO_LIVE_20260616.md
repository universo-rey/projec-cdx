---
artifact_id: operativa/archive/legacy-root/20260616/READBACK_MICROSOFT_UNIVERSO_LIVE_20260616.md
categoria: operativa
tipo: readback
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/archive/legacy-root/20260616/READBACK_MICROSOFT_UNIVERSO_LIVE_20260616.md
etiquetas:
- operativa
- readback
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Readback de universo Microsoft live con trazabilidad parcial.
fecha_evento: '2026-06-16'
---

# Readback Microsoft Universo Live 20260616

Estado: `OBSERVED_READ_ONLY`.
Hora local: `2026-06-16 17:33:31 -03:00`.
Write Microsoft: `NO_EJECUTADO`.
Extraccion profunda: `NO_EJECUTADA`.
Contenido sensible: `NO_REPLICADO`.

## Primera Lectura

Entro al tenant como universo vivo ya conocido por evidencia previa: reconozco estructura, confirmo superficies y devuelvo mapa de energia operativa sin convertir la lectura en modificacion.

## Alcance Ejecutado

- SharePoint/OneDrive: drives visibles del usuario delegado.
- SharePoint site: sitio exacto `escribaniabitsch.sharepoint.com/sites/escrituracion`.
- Teams: equipos visibles y canales visibles.
- Planner: planes visibles.
- Chats Teams: contenedores visibles en muestra `top=50`, sin abrir mensajes adicionales.

## No Ejecutado

- No se crearon, editaron, movieron ni borraron archivos.
- No se enviaron mensajes.
- No se actualizaron tareas Planner.
- No se cambiaron permisos, columnas, vistas, apps, flows, solutions ni environments.
- No se leyeron cuerpos completos de archivos.
- No se llamo Dataverse/PAC/Power Platform live.
- No se reprodujeron previews sensibles devueltos por el conector.

## Confirmado

### Tenant Y Cuenta Delegada

- Tenant observado en Teams: `858a0852-44a1-413e-a0fe-f053949797d6`.
- Host OneDrive observado: `escribaniabitsch-my.sharepoint.com`.
- Host SharePoint observado: `escribaniabitsch.sharepoint.com`.
- OneDrive visible:
  - `Documentos`
  - `PersonalCacheLibrary`
  - `KARuntime`

### Teams

Equipos visibles confirmados:

| Equipo | Team ID | Canales visibles |
| --- | --- | --- |
| `Escribanía Bitsch` | `cb038239-ad04-47fc-9224-95af3bd44149` | `5` |
| `Escrituración y Protocolo` | `68549ba5-9cbd-4f40-9dd2-5def0c53dc40` | `4` |
| `Innovación y Desarrollo` | `f379b0a0-e58d-4aa7-9958-89279b2a5eb6` | `1` |
| `Equipo de implementación` | `981cf8d3-fa58-4e7e-8744-90cbd1b9111e` | `2` |
| `SGIN` | `2c52551d-e68a-4496-bf65-eadc3b976ebe` | `1` |
| `Cuenta Activa` | `f94e475f-dcf3-4287-be51-1f2dedecd983` | `1` |

Canal especial observado:

- En `Escrituración y Protocolo`, `Libro de Registro y Protocolo` devuelve `membership_type=unknownFutureValue`. Se registra como diferencia de metadata, no como falla.

### Planner

Planes visibles confirmados: `24`.

Owners observados:

- `cb038239-ad04-47fc-9224-95af3bd44149` (`Escribanía Bitsch`)
- `68549ba5-9cbd-4f40-9dd2-5def0c53dc40` (`Escrituración y Protocolo`)
- `f379b0a0-e58d-4aa7-9958-89279b2a5eb6` (`Innovación y Desarrollo`)
- `55016a48-d830-4f31-a1d0-a44326a8245b` (owner adicional visible por Planner)

Planes de referencia observados:

- `Tareas SHB`
- `Tareas generales`
- `INCIDENTES`
- `Escrituraciones`
- `Escrituración - Protocolo`
- `Herramientas`
- `Soporte y Desarrollo`
- `Proceso KYC`
- `MVP`

### SharePoint

Sitios confirmados:

| Site path | Display name | Bibliotecas |
| --- | --- | --- |
| `/sites/escrituracion` | `Escrituración y Protocolo` | `30` |
| `/sites/ESCRIBANIABITSCH` | `Escribanía Bitsch` | `7` |

Bibliotecas documentales confirmadas en el sitio `escrituracion`: `30`.

Bibliotecas principales observadas:

- `Documentos`
- `Libro de Registro de Escrituras`
- `Protocolo Digital`
- `Protocolo Pasado`
- `Biblioteca de Digitalizacion`
- `Portal de Digitalización Documental`
- `CED - Carpeta Expediente Digital`
- `Documentos de Identidad`
- `Archivo Declaracion UIF`
- `Archivo Minutas`
- `Carpetas de Gestión`
- `Proceso de Escrituracion`
- `Escrituras de Inmuebles`
- `Auditoria de Protocolo 2`
- `Teams Wiki Data`

Bibliotecas principales observadas en `ESCRIBANIABITSCH`:

- `Portal Documental KYC`
- `Documentos de Identidad`
- `Archivo-Expediente Escrituracion IPVH`
- `Datos Personales Clientes`
- `Legajos Personas Fisicas`
- `Documentación Escrituras`
- `Documentos`

Paths SharePoint no resueltos por nombre directo:

- `/sites/SGIN`
- `/sites/sgin`
- `/sites/InnovacionyDesarrollo`
- `/sites/CuentaActiva`
- `/sites/Equipodeimplementacion`

Lectura: esos resultados son `NO_CONCLUYENTE_PATH`, no ausencia de Team ni ausencia de contenido. Los equipos existen en Teams; falta resolver alias/path SharePoint real si se requiere navegar bibliotecas asociadas.

### Chats

Probe ejecutado: `_list_chats(top=50, unread_only=false)`.

Resultado estructural:

- Se observaron contenedores `oneOnOne`, `group` y `meeting`.
- Se confirmaron contenedores de grupo relacionados con `ESCRITURACIÓN`, `CENTRAL OFFICE`, `Seshat SDU-CN`, `BO - Escrituración y Protocolo` y otras superficies operativas.
- El conector devolvio previews de mensajes como parte de la metadata. No se reproducen en este readback.

## Probable

- El Team `SGIN` existe y es visible, pero el site path directo `/sites/SGIN` y `/sites/sgin` no resolvio por `_get_site`.
- La superficie SGIN puede estar respaldada por un sitio con alias/path distinto, por una biblioteca dentro de otro site, o por Teams sin path SharePoint directo expuesto por ese nombre.
- La superficie local `07_SHAREPOINT_POWER_PLATFORM_SGIN` corresponde mas a evidencia documental/multimedia que a una lista nativa.

## Inferido

- El universo Microsoft principal de esta cuenta esta centrado en el tenant `escribaniabitsch`, con Teams, Planner, OneDrive y SharePoint operativo.
- La lectura confirma que no estamos frente a una superficie desconocida: hay estructura viva suficiente para continuar por waves atomicas.
- La cobertura del conector es buena para Teams/Planner y bibliotecas documentales, pero no prueba por si sola inventario total de tenant, listas nativas, permisos o Power Platform.

## Condiciones De Pausa Y Cierre

- Si se requiere abrir mensajes, archivos o tareas con contenido, definir target exacto y criterio de minima lectura.
- Si se requiere SharePoint lists nativas, usar un reader nativo real o PnP/Graph gobernado; no confundir bibliotecas con listas.
- Si se requiere Power Platform/Dataverse, abrir ambiente/org/target exacto.
- Si se requiere write, pasar a orden de cierre con owner, rollback y postcheck.

## Proximo Movimiento

Wave recomendada: `SGIN`.

Secuencia:

1. Resolver el sitio real o contenedor documental asociado al Team `SGIN`.
2. Cruzar `SGIN` Teams con Planner y bibliotecas del sitio `escrituracion`.
3. Relevar solo metadata de carpetas/archivos candidatos.
4. Crear mapa `confirmado/probable/inferido` sin duplicar contenido sensible.
