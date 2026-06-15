# Anclas On Demand

Capa minima para abrir solo la ancla que pide el delta real.

## Regla

- No abrir anclas por costumbre.
- Si una superficie no cambia, no se carga.
- Cada proceso nuevo que merezca entrada corta agrega su referencia aqui.

## Entradas

- [Prompt Cierre Wave](C:/Users/enzo1/PROJEC%20CDX/operativa/PROMPT_CIERRE_WAVE.md)
- [Start Here Cierre Wave](C:/Users/enzo1/PROJEC%20CDX/operativa/START_HERE_CIERRE_WAVE.md)
- [Complementos On Demand](C:/Users/enzo1/PROJEC%20CDX/operativa/COMPLEMENTOS_ON_DEMAND.md)
- [Ancla Agentes Atomicos Algoritmicos](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md)
- [Ancla Energia Atomica](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLA_ENERGIA_ATOMICA.md)

## Anclas

- [Dataverse cierre wave](C:/Users/enzo1/PROJEC%20CDX/dataverse/ANCLA_CIERRE_WAVE.md) - solo si el frente toca Dataverse.
- [Receta cierre wave documental](C:/Users/enzo1/PROJEC%20CDX/recipes/cierre-wave-documental.md) - solo si hace falta la receta reutilizable.
- [Proceso cierre wave documental](C:/Users/enzo1/PROJEC%20CDX/procesos/cierre-wave-documental.md) - solo si hace falta el proceso ejecutable.
- [Receta procedencia layout on-demand](C:/Users/enzo1/PROJEC%20CDX/recipes/procedencia-layout-on-demand.md) - solo si el delta pide separar procedencia tecnica de lectura visible.
- [Proceso procedencia layout on-demand](C:/Users/enzo1/PROJEC%20CDX/procesos/procedencia-layout-on-demand.md) - solo si el delta pide ejecutar esa separacion.
- [Receta complementos on-demand](C:/Users/enzo1/PROJEC%20CDX/recipes/complementos-on-demand.md) - solo si el pedido es abrir o listar complementos.
- [Proceso complementos on-demand](C:/Users/enzo1/PROJEC%20CDX/procesos/complementos-on-demand.md) - solo si el pedido requiere ejecutar esa apertura.
- [Receta configuracion entorno Codex UI](C:/Users/enzo1/PROJEC%20CDX/recipes/configuracion-entorno-codex-ui.md) - solo si falta alinear la UI con la config local del proyecto o reabrir el carril correcto.
- [Ancla agentes atomicos algoritmicos](C:/Users/enzo1/PROJEC%20CDX/operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md) - solo si el delta se delega en agentes atómicos con retorno exacto.
- [Receta agentes atomicos algoritmicos en waves](C:/Users/enzo1/PROJEC%20CDX/recipes/agentes-atomicos-algoritmicos-en-waves.md) - solo si la delegacion se parte en waves.
- [Proceso agentes atomicos algoritmicos en waves](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md) - solo si hace falta ejecutar esa wave.
- [Receta limpieza pc local segura](C:/Users/enzo1/PROJEC%20CDX/recipes/limpieza-pc-local-segura.md) - solo si el delta pide recorte de ruido local en Windows.
- [Proceso limpieza pc local segura](C:/Users/enzo1/PROJEC%20CDX/procesos/limpieza-pc-local-segura.md) - solo si hace falta ejecutar esa limpieza con gate.
- [Cobertura atomica energetica](C:/Users/enzo1/PROJEC%20CDX/operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md) - solo si el delta necesita declarar fase e impulso visibles.

## Uso

1. Identificar el delta real.
2. Abrir solo la ancla minima necesaria.
3. Reflejar solo la superficie tocada.
4. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Extensibilidad

- Cualquier nuevo proceso durable que merezca entrada corta agrega su fila aqui.
- Si una ancla deja de ser on-demand, volver a clasificarla antes de exponerla.
