# Canon Semantico Wave Atomica Metadata 20260616

Estado: `metadata_only`.
Frontera: `tenant_scoped`.
Tenant: `Escribania Bitsch`.

## Estados Canonicos

- `metadata_only`: lectura, preparacion o matriz sin write.
- `tenant_scoped`: frontera unica del tenant Escribania Bitsch.
- `observed_read_only`: observado por lectura, no ejecutado.
- `superficie_observada`: contenedor o metadata visible.
- `fuera_de_alcance_actual`: fuera de tenant, payload, documento, secreto, permiso o write.
- `candidate_count_required`: no hay apply sin candidate count exacto.
- `ready_for_target`: preparado para resolver target, no para ejecutar.
- `pausa_gobernada`: falta cierre o target, no es bloqueo semantico.

## Reemplazos

| Evitar | Usar |
| --- | --- |
| `wave viva live` | `wave tenant_scoped` |
| `bloqueado por alcance` | `pausado por frontera de alcance` |
| `Dataverse confirmado para ejecutar` | `Dataverse observado como metadata_only` |
| `todo Microsoft` | `tenant Escribania Bitsch` |
| `ambientes relacionados` | `ambientes explicitamente vinculados al tenant` |
| `fuera del tenant queda bloqueado` | `fuera del tenant queda fuera_de_alcance_actual` |
| `sin live write ni live read` repetido | `metadata_only` |
| `activar Power Platform` | `preparar lectura metadata_only Power Platform` |

## Separaciones

- `SGIN` es site documental confirmado, no todo Microsoft.
- `SPGovernanceModel` apunta a `/sites/soporte`, no a SGIN.
- `SDU runtime` puede ser compartido, pero no prueba ownership SGIN.
- `Dataverse hydration` es paquete preparado, no apply.
- `candidate_count_many` exige desambiguacion, nunca apply.

## Voz

Usar primera persona instrumental en actas de identidad:

`Despierto leyendo, no ejecutando; nombro frontera, fijo evidencia y dejo la mano quieta hasta gate explicito.`
