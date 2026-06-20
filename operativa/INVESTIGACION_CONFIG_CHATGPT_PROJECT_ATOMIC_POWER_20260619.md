# INVESTIGACION_CONFIG_CHATGPT_PROJECT_ATOMIC_POWER_20260619

## Estado
BORRADOR_OPERABLE

## Objetivo
Definir como configurar ChatGPT Project para `ATOMIC POWER PROJECT CDX` sin convertirlo en una configuracion estatica.

La decision rectora es simple: el prompt no debe cargar todo el universo. El prompt debe actuar como bootloader. La memoria viva debe venir de fuentes del proyecto, readbacks, archivos canonicos, respuestas guardadas y conectores gobernados.

## Fuentes oficiales consultadas

| Fuente | Uso para este dictamen |
| --- | --- |
| https://help.openai.com/en/articles/10169521-projects-in-chatgpt | Projects agrupa chats, archivos, instrucciones, links, fuentes guardadas y memoria de proyecto. |
| https://help.openai.com/en/articles/8590148-memory-faq | Memory tiene settings separados: saved memories y reference chat history. |
| https://help.openai.com/en/articles/8554407-gpts-in-chatgpt | Un GPT puede tener instrucciones, knowledge, capabilities, apps o actions, pero no debe confundirse con memoria viva del proyecto. |
| https://help.openai.com/en/articles/11487775-connectors-in-chatgpt | Apps/conectores pueden tener controles de acciones, RBAC, read-only o set custom de acciones. |
| https://help.openai.com/en/articles/12584461-developer-mode-and-mcp-apps-in-chatgpt | MCP apps con acciones write/modify estan en beta y requieren gobierno de workspace. |
| https://help.openai.com/en/articles/8555545-file-uploads-faq | Projects tienen limites de archivos por plan; conviene compactar en source packs. |

## Dictamen
No conviene configurar `ATOMIC POWER PROJECT CDX` como un prompt largo y cerrado.

Conviene configurarlo como:

| Capa | Funcion | Fuente de verdad |
| --- | --- | --- |
| Project instructions | Bootloader operativo, identidad, modo de respuesta y gates | Texto corto pegado en Project settings |
| Project sources | Canon vivo, mapas, readbacks, current, next y source packs | Archivos o textos cargados al proyecto |
| Project-only memory | Continuidad dentro del proyecto, sin contaminarse con memoria externa | Opcion elegida al crear el proyecto cuando este disponible |
| Saved responses | Actas, decisiones y cierres promovidos desde conversaciones | Respuestas guardadas como project source |
| Custom GPT opcional | Persona/herramienta reusable, no autoridad primaria | GPT invocado dentro del proyecto si hace falta |
| Apps/MCP opcional | Lectura o accion sobre superficies externas | Solo con gate, idealmente read-only primero |

## Configuracion recomendada en ChatGPT

1. Crear proyecto con nombre: `ATOMIC POWER PROJECT CDX`.
2. Si aparece la opcion, elegir memoria `Project-only` al crear el proyecto.
3. En `Project settings`, pegar el prompt bootloader v2.
4. Subir o pegar un source pack compacto con el canon vigente.
5. Guardar como project source cada readback, acta o decision que cambie el estado.
6. Usar GPTs solo como capa opcional, no como memoria principal.
7. Usar Apps/MCP solo bajo semaforo: read-only primero; write solo con target, owner, rollback, postcheck y evidencia.

## Source pack minimo inicial

| Archivo local | Motivo |
| --- | --- |
| `C:\Users\enzo1\PROJEC CDX\README.md` | Entrada del workspace fisico real. |
| `C:\Users\enzo1\PROJEC CDX\MAPA_MAESTRO.md` | Navegacion rectora. |
| `C:\Users\enzo1\PROJEC CDX\operativa\CURRENT.md` | Estado vivo. |
| `C:\Users\enzo1\PROJEC CDX\operativa\NEXT.md` | Proximo movimiento. |
| `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\README.md` | Plan rector de cobertura. |
| `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\MAPA.md` | Matriz visible de planes. |
| `C:\Users\enzo1\PROJEC CDX\operativa\READBACK_COBERTURA_PLANES_20260619.md` | Cierre de cobertura. |
| `C:\Users\enzo1\PROJEC CDX\dataverse\README.md` | Entrada Dataverse. |
| `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA.md` | Mapa Dataverse. |
| `C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md` | Gates Dataverse. |
| `C:\Users\enzo1\PROJEC CDX\agents\README.md` | Agentes. |
| `C:\Users\enzo1\PROJEC CDX\skills\README.md` | Skills. |
| `C:\Users\enzo1\PROJEC CDX\chains\README.md` | Chains. |
| `C:\Users\enzo1\PROJEC CDX\operativa\PROMPT_CHATGPT_PROJECT_ATOMIC_POWER_PROJEC_CDX_V2_BOOTLOADER_20260619.md` | Instruccion viva recomendada. |

## Reglas de no estatica

- El prompt dice como despertarse, no intenta contener todo.
- Las fuentes dicen que esta vigente.
- Los readbacks dicen que cambio.
- El proyecto guarda respuestas importantes como fuentes.
- La memoria de proyecto mantiene continuidad dentro del proyecto.
- Los conectores traen mundo vivo solo bajo gate.
- Si una fuente envejece, se reemplaza el source pack; no se reescribe toda la identidad.

## Riesgos

| Riesgo | Mitigacion |
| --- | --- |
| Prompt demasiado largo | Usar bootloader v2 y subir el resto como source pack. |
| Memoria mezclada con otros proyectos | Crear proyecto con project-only memory cuando este disponible. |
| GPT confundido con fuente de verdad | Usar GPT como herramienta opcional, no como autoridad. |
| Demasiados archivos | Compactar en source packs por capa. |
| Apps con writes prematuros | Configurar read-only primero y gates para writes. |
| Canon local desactualizado | Guardar readbacks y regenerar source pack despues de cierres. |

## Stop condition
No configurar writes, MCP ni acciones externas desde ChatGPT hasta tener target, owner, rollback, postcheck, evidencia y aprobacion humana expresa.

## Siguiente delta
Usar `PROMPT_CHATGPT_PROJECT_ATOMIC_POWER_PROJEC_CDX_V2_BOOTLOADER_20260619.md` como instrucciones del proyecto y preparar un source pack compacto si el limite de archivos del plan lo exige.
