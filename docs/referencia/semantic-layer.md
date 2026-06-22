---
artifact_id: docs/referencia/semantic-layer.md
categoria: playbooks
tipo: mapa
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/referencia/semantic-layer.md
etiquetas:
  - docs
  - referencia
  - semantic-layer
  - sistema-nervioso
relacionados:
  - MAPA_CAPAS.md
  - tools/sdu_chain_resolver.py
  - inventarios/SKILLS_UNIFIED_TABLE.csv
descripcion: Capa semantica repo-local para que el sistema nervioso elija fuente, sentido y criterio sin depender de memoria externa.
---
# Semantic Layer Repo-Local

Soy la capa que elige fuente, sentido y criterio antes de mover.

No reemplazo la skill instalada.
La vuelvo operable dentro del repo.

## Pulso

```text
pregunta -> fuente -> criterio -> agente -> motor -> evidencia -> salida
```

## Precedencia

| Orden | Fuente | Uso |
|---|---|---|
| 1 | [MAPA_CAPAS.md](../../MAPA_CAPAS.md) | Pulso del sistema nervioso. |
| 2 | [operativa/CURRENT.md](../../operativa/CURRENT.md) y [operativa/NEXT.md](../../operativa/NEXT.md) | Estado vivo y delta siguiente. |
| 3 | [inventarios/AGENTES_SKILLS_RECETAS_20260616.md](../../inventarios/AGENTES_SKILLS_RECETAS_20260616.md) | Agente, skill, receta y tool. |
| 4 | [inventarios/SKILLS_UNIFIED_TABLE.csv](../../inventarios/SKILLS_UNIFIED_TABLE.csv) | Catalogo visible de skills y plugins. |
| 5 | [dataverse/README.md](../../dataverse/README.md), [dataverse/MAPA.md](../../dataverse/MAPA.md), [dataverse/GATE.md](../../dataverse/GATE.md) | Memoria estructural y frontera live. |
| 6 | [workbooks/README.md](../../workbooks/README.md) | Lectura de decision cuando el delta pide workbook. |

## Regla De Fuente

- Si la fuente esta en el repo, leo el repo primero.
- Si la fuente vive en `.codex`, la uso como capacidad instalada, no como verdad primaria.
- Si la fuente vive en Dataverse, SharePoint, GitHub o Codex Cloud, entro por lectura y owner-gate.
- Si dos fuentes discrepan, manda la mas cercana al nodo activo del sistema nervioso.

## Drift Vivo

Conteos observados para orientar, no para bloquear:

| Superficie | Conteo vivo |
|---|---:|
| `.codex/skills` | 83 |
| `.agents/skills` | 31 |
| `tools/` | 36 |
| `recipes/` | 17 |

## Gotchas

- Missing legacy CSV no significa ausencia de capacidad.
- `C:\Users\enzo1\PROJEC CDX` es workspace fisico real, no legacy.
- `C:\CEO\project-cdx` es entrada canonica local, no otro repo.
- Codex Cloud cache acelera; no gobierna memoria.

## Cierre

Cuando el sistema nervioso pregunta por criterio, respondo desde el repo:

```text
MAPA_CAPAS -> CURRENT/NEXT -> AGENTES/SKILLS/RECETAS -> MODELO -> EVIDENCIA
```
