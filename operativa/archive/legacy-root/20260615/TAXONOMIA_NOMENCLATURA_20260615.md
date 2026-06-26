# Taxonomia Y Nomenclatura Operativa

Fecha: `2026-06-15`

## Regla Para Nuevos Artefactos

```text
<TIPO>_<ALCANCE>_<FRENTE>[_<SUBFRENTE>][_POR_<GRANO>]_<YYYYMMDD>[_vN].<ext>
```

## Niveles

| nivel | uso | ejemplos |
| --- | --- | --- |
| `L0` | proyecto | `PROJEC_CDX` |
| `L1` | wave o carril | `WAVE_REVISION_TOTAL`, `CONSOLIDACION`, `CARRIL04` |
| `L2` | frente | `REPOS_GITHUB`, `ORGANIZACION`, `TGE`, `TCU`, `HITOS`, `OUTPUTS` |
| `L3` | subfrente | `AGENTES`, `CDF_STAFF`, `SDU_CN`, `REMOTE`, `SDK`, `RUNTIME_PARALLEL` |
| `L4` | grano | `POR_REPO`, `POR_ARCHIVO`, `POR_SUBCARPETA`, `POR_SKILL`, `POR_RECIPE` |
| `L5` | cierre | `ACTA`, `READBACK`, `REGISTRO`, `EVIDENCIA`, `MANIFEST` |

## Prefijos Gobernados

- `INDICE_`: mapa corto o inventario estructurado.
- `ACTA_`: decision o corte operativo.
- `READBACK_`: cierre verificable.
- `REGISTRO_`: cronologia larga.
- `PLAN_`: trabajo propuesto o pendiente.
- `WORKBOOK_`: Excel principal entregable.
- `INSPECT_`: inspeccion tecnica.
- `MANIFEST_`: manifiesto de paquete.
- `EVIDENCIA_`: respaldo trazable.
- `MAPA_`: navegacion de carpeta o paquete.
- `README.md`: entrada humana corta.

## Alias Estables

- `TGE`: `torre-gemela-escribania`
- `TCU`: `tcu-agentic-runtime-control`
- `PROJEC_CDX`: `C:/Users/enzo1/PROJEC CDX`
- `05AO`: paquete historico TCU/TGE
- `outputs/`: evidencia generada
- `hitos/YYYYMMDD-frente-vN`: paquete versionado historico

## Taxonomia De Agentes

| clase | estado | lectura |
| --- | --- | --- |
| `SDK-SDU` | `ACTIVO` | Agentes definidos en el SDK y gobernados por la taxonomia local del proyecto. |
| `Dataverse real` | `CONFIRMADO_SEPARADO` | Entidades, colas, flujos y filas materializadas en `HUBDesarrollo`. |
| `Homonimo local` | `CONFIRMADO` | Mismo nombre que otro agente o rol, pero distinta superficie o runtime. |
| `Puente documental` | `ACTIVO` | Mapeo entre nombres locales, runtime SDK y superficies Dataverse. |

### Agentes SDK-SDU Activos

Estos seis nombres quedan activos como `SDK-SDU` en la taxonomia local:

- `seshat-normativa`
- `thot-tecnico`
- `anubis-gate`
- `maat-cumplimiento`
- `horus-riesgo`
- `narrador-normativo`

### Regla De Separacion

- Que un nombre exista en la taxonomia local no prueba que exista como agente Dataverse.
- Que un agente exista en Dataverse no prueba que sea el mismo runtime del SDK local.
- Si hay homonimia, se etiqueta como `homonimo local` hasta confirmar equivalencia.
- Si la equivalencia no se confirma, no se promociona a `Dataverse real`.

## Regla De Gobierno

- Los nombres historicos se conservan.
- Los nombres nuevos siguen esta taxonomia.
- No se renombra sin alias, verificacion de enlaces y rollback.
- Cada nivel o subnivel debe tener entrada corta, mapa o razon `NO_APLICA`.
- Las filas de cadena operativa usan la nomenclatura fina de [NOMENCLATURA_CADENA_OPERATIVA_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/20260615/NOMENCLATURA_CADENA_OPERATIVA_20260615.md).

## Stop Conditions

- `alias_missing_before_rename`
- `sublevel_without_entry_or_no_aplica`
- `index_without_acta_or_readback`
- `operational_chain_row_without_required_field`
- `canon_promoted_from_outputs_without_source`
- `live_surface_without_gate_owner_rollback_postcheck`
