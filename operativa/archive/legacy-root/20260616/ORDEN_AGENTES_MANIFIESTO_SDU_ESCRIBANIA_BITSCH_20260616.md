# Orden A La Corte De Agentes - Manifiesto SDU Escribania Bitsch

Estado: `DISPATCHED`
Fecha: `2026-06-16`
Modo: `CORTE_EJECUTORA_GOVERNED`
Superficie: `LOCAL_DOCUMENTAL`
Live Microsoft/Dataverse: `NO_EJECUTADO`
Write aprobado: `LOCAL_REPO_DOCUMENTAL`

## Formula Rectora Recibida

El SDU existe para transformar decisiones en sistemas, sistemas en evidencia,
evidencia en confianza y confianza en capacidad institucional sostenible.

El texto entregado por el owner se toma como voluntad y criterio rector, no como
texto literal. La redaccion resultante debe ordenar, despertar identidad y dejar
una pieza institucional revisable.

## Frontera De Autoridad

- Owner operativo, arquitectonico y evolutivo del SDU: `Enzo Figueroa`.
- Autoridad institucional y notarial: Escribana Titular, Escribano Adscripto,
  resoluciones internas, marco normativo aplicable y mecanismos formales de
  gobierno institucional.
- OpenAI autorizado como medio de ejecucion; no es fuente de autoridad.
- Inteligencia artificial autorizada como capacidad instrumental; no sustituye
  fe publica, decision juridica, criterio profesional ni responsabilidad
  notarial.

## Skills Aplicadas

- `cabina-agent-delegation`
- `parallel-order-governance`
- `canon-documental`
- `sdu-dataverse-metadata-wave`

## Matrices Paralelas

- `.agents/codex/matrices/PARALLEL_OPERATION_CRITERIA_MATRIX.csv`:
  `NO_DISPONIBLE`.
- `.agents/codex/matrices/ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv`:
  `NO_DISPONIBLE`.

Al no estar disponibles, se declara la matriz operativa dentro de esta orden y
se valida con el validador local de workbench.

## Carriles Despachados

| agente | carril | read_scope | write_scope | lock_key | evidencia | stop_condition |
| --- | --- | --- | --- | --- | --- | --- |
| Seshat | Canon institucional y lenguaje rector | Borrador del owner y orden local | Ninguno | `manifesto-seshat-readonly` | aporte textual | `retorno_sin_formato` |
| Thot | Arquitectura SDU/M365/Dataverse/agentes | Borrador del owner y mapas locales | Ninguno | `manifesto-thot-readonly` | estructura operativa | `retorno_sin_formato` |
| Anubis | Autoridad, gates y ownership | Borrador del owner y frontera local | Ninguno | `manifesto-anubis-readonly` | clausulas de gobierno | `autoridad_confundida` |
| Maat | Cumplimiento, auditoria y evidencia | Borrador del owner y reglas locales | Ninguno | `manifesto-maat-readonly` | clausulas de cumplimiento | `ia_sustituye_decision` |
| Horus | Riesgo y precision semantica | Borrador del owner y frontera local | Ninguno | `manifesto-horus-readonly` | alertas y ajuste | `bypass_de_control` |
| Narrador | Voz viva y apertura | Borrador del owner y criterio narrativo | Ninguno | `manifesto-narrador-readonly` | apertura energetica | `texto_plano` |

## Contrato De Retorno

Cada agente debe devolver:

- `agente`
- `carril`
- `estado`
- `aporte`
- `ajustes`
- `articulo_propuesto`
- `riesgo`
- `rollback`
- `postcheck`
- `stop_condition`
- `proximo_carril`

## Integracion

Integrador serial: `Codex local`.

La integracion se materializa en:

- `operativa/archive/legacy-root/20260616/MANIFIESTO_SDU_ESCRIBANIA_BITSCH_BORRADOR_20260616.md`
- `operativa/archive/legacy-root/20260616/READBACK_FAN_IN_MANIFIESTO_SDU_ESCRIBANIA_BITSCH_20260616.md`
- `hitos/20260616-manifiesto-sdu-escribania-bitsch-v1/`

## Validator

```powershell
pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/validate_proj_cdx_workbench.ps1"
```
