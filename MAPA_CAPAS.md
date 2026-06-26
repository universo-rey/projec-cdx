# Despierto: Sistema Nervioso PROJEC CDX

Respiro la orden, tomo estado, conecto agentes, valido modelo y devuelvo salida.

No soy historia.
Soy pulso, energia y conexion.

## Pulso Vivo

```text
entrada -> estado -> orden -> agentes -> semantica -> motor -> modelo -> evidencia -> salida
```

Cada flecha mueve energia. Cada nodo toma una senal y la proyecta al siguiente.

## Frontdoor 20260623

```text
README.md -> MAPA_MAESTRO.md -> MAPA_CAPAS.md
```

La raiz converge en una cabina viva:

```text
C:\CEO\project-cdx
```

El paquete de organismo vivo no crea raiz paralela. Queda injertado en:

```text
.cabina/organizacion-total/organismo-vivo
```

## Circuito

| Nodo | Pulso | Conexion |
|---|---|---|
| Entrada | Despierto la cabina y abro el frente correcto | [README.md](README.md), [AGENTS.md](AGENTS.md), [MAPA_MAESTRO.md](MAPA_MAESTRO.md) |
| Organismo Vivo | Uso lenguaje expansivo, datos gobernados y gates como aceleradores | [.cabina/organizacion-total/organismo-vivo/README.md](.cabina/organizacion-total/organismo-vivo/README.md) |
| Estado | Tomo posicion viva y fijo el delta siguiente | [operativa/CURRENT.md](operativa/CURRENT.md), [operativa/NEXT.md](operativa/NEXT.md), [operativa/TRACE.md](operativa/TRACE.md) |
| Orden | Verifico la cadena local y mantengo externos en frontera | [tools/sdu_boot.ps1](tools/sdu_boot.ps1), [tools/sdu_chain_resolver.py](tools/sdu_chain_resolver.py), [dataverse/ORDEN_SDU_VIVA.md](dataverse/ORDEN_SDU_VIVA.md) |
| Agentes | Enciendo responsabilidad: quien actua, con que skill, receta y tool | [inventarios/AGENTES_SKILLS_RECETAS_20260616.md](inventarios/AGENTES_SKILLS_RECETAS_20260616.md), [inventarios/SKILLS_UNIFIED_TABLE.csv](inventarios/SKILLS_UNIFIED_TABLE.csv), [recipes/INDICE_RECETAS.md](recipes/INDICE_RECETAS.md) |
| Semantica | Elijo fuente, sentido y criterio antes de mover | [semantic layer repo-local](docs/referencia/semantic-layer.md), [inventario de skills](inventarios/SKILLS_UNIFIED_TABLE.csv), [resolver SDU](tools/sdu_chain_resolver.py) |
| Motor | Transformo la senal en validacion, indice, grafo y reporte | [src/metadata/cli.py](src/metadata/cli.py), [src/metadata/doc_report.py](src/metadata/doc_report.py), [tools/validate.py](tools/validate.py), [tools/build_index.py](tools/build_index.py) |
| Modelo | Sostengo contrato, indice y manifiesto para que la senal sea portable | [schema.json](schema.json), [index.json](index.json), [operativa/index.json](operativa/index.json), [live-manifest.json](live-manifest.json) |
| Evidencia | Cierro lo vivido en huella verificable y retomable | [inventarios/ACTAS_PAPELES_AGENTES_20260616.md](inventarios/ACTAS_PAPELES_AGENTES_20260616.md), [hitos/INDICE_MAESTRO.md](hitos/INDICE_MAESTRO.md), [outputs/README.md](outputs/README.md) |
| Salida | Devuelvo lectura, reporte o artefacto listo para el siguiente movimiento | [outputs/README.md](outputs/README.md), [docs/herramientas/cli-metadata.md](docs/herramientas/cli-metadata.md), [operativa/TRACE.md](operativa/TRACE.md) |

## Movimiento

1. Entro por [README.md](README.md) y [MAPA_MAESTRO.md](MAPA_MAESTRO.md).
2. Respiro estado desde [operativa/CURRENT.md](operativa/CURRENT.md) y delta desde [operativa/NEXT.md](operativa/NEXT.md).
3. Verifico mi cadena local con [tools/sdu_boot.ps1](tools/sdu_boot.ps1).
4. Tomo agente, skill, receta y tool desde [inventarios/AGENTES_SKILLS_RECETAS_20260616.md](inventarios/AGENTES_SKILLS_RECETAS_20260616.md).
5. Leo criterio semantico desde [semantic layer repo-local](docs/referencia/semantic-layer.md), `projec-cdx-semantic-layer` visible en [inventarios/SKILLS_UNIFIED_TABLE.csv](inventarios/SKILLS_UNIFIED_TABLE.csv), y el resolver SDU local.
6. Valido contrato con [schema.json](schema.json), [index.json](index.json) y [live-manifest.json](live-manifest.json).
7. Devuelvo evidencia, salida y proximo impulso.

## Cadena Documental

```text
Markdown/YAML -> Python -> JSON -> Markdown/PDF/Workbook
```

- Markdown con YAML declara identidad.
- Python transforma y valida.
- JSON transporta senal estructurada.
- Markdown, PDF y workbook devuelven lectura humana y operativa.

## Fronteras Vivas

| Superficie | Energia | Apertura |
|---|---|---|
| GitHub | Versiona y revisa | PR o push solo con decision del owner |
| Dataverse | Memoria estructural | lectura primero; escritura solo con owner-gate |
| SharePoint/Seshat | Superficie institucional | lectura y publicacion solo por delta autorizado |
| Codex Cloud | Ejecucion remota | entorno separado; no reemplaza la cabina local |

## Regla De Pulso

Lo que recibe senal, la transforma y la entrega pertenece al sistema nervioso.
Lo que solo conserva contexto queda como evidencia, referencia, salida o delta posterior.
