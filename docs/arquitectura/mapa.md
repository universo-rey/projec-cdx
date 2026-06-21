---
id: docs-arquitectura-mapa
titulo: Mapa arquitectonico documental
fecha: 2026-06-21
estado: fase-1
origen: docs/MAPA.md
etiquetas: [arquitectura, documentacion, navegacion]
responsable: PROJEC CDX
owner: CEO
version: 0.1.0-docs
---

# Mapa Arquitectonico Documental

Este mapa cose la documentacion visible de `PROJEC CDX` sin duplicar el control plane operativo.

## Entrada

- [Indice de documentacion](../index.md)
- [README de docs](../README.md)
- [Mapa maestro del repo](../../MAPA_MAESTRO.md)

## Capas

| Capa | Funcion | Entrada |
|---|---|---|
| Arquitectura | Mapas, decisiones y estructura documental | [index](index.md) |
| Gobernanza | Nomenclatura, versionado y calidad | [gobernanza](../gobernanza/index.md) |
| Operativa | Cronologia, actas, planes y readbacks | [operativa](../operativa/index.md) |
| Referencia | Material largo y glosario | [referencia](../referencia/index.md) |
| Herramientas | CLI, pipelines y validaciones | [herramientas](../herramientas/index.md) |
| Datos | Matrices, manifiestos y artefactos indexables | [datos](../datos/index.md) |
| Superpowers | Planes existentes ya versionados | [superpowers](../superpowers/README.md) |

## Regla de frontera

- `docs/` ordena la documentacion canonica del proyecto.
- `operativa/`, `hitos/`, `outputs/` e `inventarios/` conservan evidencia viva.
- `docs/referencia/` guarda detalle largo y glosario.
- No se duplican binarios ni matrices pesadas dentro de `docs/`; se referencian.
