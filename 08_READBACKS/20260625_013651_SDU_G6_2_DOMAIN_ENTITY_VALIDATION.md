# SDU G6.2 Domain Entity Validation For DocumentLocation

Mode: READ_ONLY
Dictamen: CASE_2: SOLO_ADX_PORTALCOMMENT_DISPONIBLE
Environment: HUBDesarrollo
Dataverse URL: https://org084965d9.crm.dynamics.com
Timestamp: 2026-06-25T01:36:51

## Alcance

Determinar que entidad real de negocio puede usarse como `regardingobjectid` del flujo automatico G6 para crear `sharepointdocumentlocation`.

No se ejecutaron Dataverse writes, SharePoint writes, flows, scheduler, push ni PR.

## Resultado Ejecutivo

No se encontro una entidad real de expediente/escritura/protocolo/notarial/tramite que sea target valido de `sharepointdocumentlocation.regardingobjectid` o que aparezca como entidad de dominio documental habilitada.

El modelo `cr3c_*` existe, tiene filas y representa metadata SharePoint, pero no esta habilitado para Document Management y no aparece como target valido de `regardingobjectid`.

La unica ancla disponible con fila real, target valido y prueba end-to-end existente es `adx_portalcomment`.

## Lookup Targets De DocumentLocation

Targets validos observados para `sharepointdocumentlocation.regardingobjectid`:

- `account`
- `adx_portalcomment`
- `kbarticle`
- `knowledgearticle`
- `lead`
- `msdyn_knowledgearticletemplate`
- `msdyn_playbookactivity`
- `mspp_website`
- `opportunity`
- `product`
- `quote`
- `salesliterature`

## Entidades cr3c Detectadas

Las entidades pedidas literalmente no existen con esos logical names:

- `cr3c_spsite`: no existe
- `cr3c_spcontainer`: no existe
- `cr3c_spfield`: no existe
- `cr3c_spcontenttype`: no existe

Equivalentes reales detectados:

| LogicalName | EntitySetName | PrimaryNameAttribute | ObjectTypeCode | Rows top 3 | DocumentManagementEnabled | IsRegardingTarget |
| --- | --- | --- | --- | ---: | --- | --- |
| `cr3c_camposp` | `cr3c_camposps` | `cr3c_cr3c_fielddisplayname` | 11334 | 3 | false | false |
| `cr3c_contenedorsp` | `cr3c_contenedorsps` | `cr3c_cr3c_containername` | 11449 | 3 | false | false |
| `cr3c_cr3c_containercontenttype` | `cr3c_cr3c_containercontenttypes` | `cr3c_cr3c_name` | 11337 | 3 | false | false |
| `cr3c_cr3c_govissue` | `cr3c_cr3c_govissues` | `cr3c_cr3c_issuetitle` | 11327 | 3 | false | false |
| `cr3c_cr3c_spchoiceoption` | `cr3c_cr3c_spchoiceoptions` | `cr3c_cr3c_choiceoptionname` | 11379 | 3 | false | false |
| `cr3c_cr3c_spcontainer` | `cr3c_cr3c_spcontainers` | `cr3c_cr3c_containername` | 11427 | 3 | false | false |
| `cr3c_cr3c_spfield` | `cr3c_cr3c_spfields` | `cr3c_cr3c_fielddisplayname` | 11446 | 3 | false | false |
| `cr3c_cr3c_spsite` | `cr3c_cr3c_spsites` | `cr3c_cr3c_sitename` | 11326 | 3 | false | false |
| `cr3c_tipodecontenidosp` | `cr3c_tipodecontenidosps` | `cr3c_cr3c_contenttypename` | 11338 | 3 | false | false |

Conclusion `cr3c_*`: metadata operativa visible, pero no candidata directa para `DocumentLocation` como `regardingobjectid`.

## Entidades Con Document Management Habilitado

Se observaron 13 entidades con `IsDocumentManagementEnabled=true`:

| LogicalName | EntitySetName | IsRegardingTarget | Rows top 3 |
| --- | --- | --- | ---: |
| `account` | `accounts` | true | 0 |
| `adx_portalcomment` | `adx_portalcomments` | true | 1 |
| `category` | `categories` | false | 0 |
| `kbarticle` | `kbarticles` | true | 0 |
| `knowledgearticle` | `knowledgearticles` | true | 0 |
| `lead` | `leads` | true | 0 |
| `msdyn_knowledgearticletemplate` | `msdyn_knowledgearticletemplates` | true | 0 |
| `msdyn_playbookactivity` | `msdyn_playbookactivities` | true | 0 |
| `mspp_website` | `mspp_websites` | true | 0 |
| `opportunity` | `opportunities` | true | 0 |
| `product` | `products` | true | 0 |
| `quote` | `quotes` | true | 0 |
| `salesliterature` | `salesliteratures` | true | 0 |

`category` soporta document management, pero no es target valido del lookup `regardingobjectid`; no debe usarse para el POST de `sharepointdocumentlocation`.

## Read-Only Row Checks

GET `$top=3` ejecutado sin imprimir valores de filas:

- `adx_portalcomments`: OK, 1 fila.
- `accounts`: OK, 0 filas.
- `categories`: OK, 0 filas.
- 9 entidades `cr3c_*`: OK, 3 filas cada una.

## Decision

```text
CASE_2: SOLO_ADX_PORTALCOMMENT_DISPONIBLE
```

Motivo:

- No hay entidad real de expediente validada.
- `cr3c_*` no es target valido de `regardingobjectid`.
- `cr3c_*` no tiene document management habilitado.
- Las entidades estandar validas no representan expediente real y no tienen filas operativas utiles salvo `adx_portalcomment`.
- `adx_portalcomment` ya fue probado con DocumentLocation funcional en G5.

## Stop Condition

`DOMAIN_ENTITY_NOT_AVAILABLE_FOR_DOCUMENTLOCATION`

## Proximo Delta G6.2

Opciones gobernadas:

1. Mantener `adx_portalcomment` como ancla tecnica para el primer flow G6, con backreference al expediente fuera del `DocumentLocation`.
2. Habilitar o crear una entidad real de expediente para document management bajo gate separado.
3. Revalidar metadata despues de cualquier cambio de solucion antes de permitir el flow.

Hasta que una de esas opciones tenga owner gate, rollback, postcheck y evidencia, no crear flow ni nuevos DocumentLocations automaticos.
