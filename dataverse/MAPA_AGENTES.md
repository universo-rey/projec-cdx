# Mapa De Agentes Dataverse

Inventario corto del carril de agentes resuelto con evidencia local y lectura viva en `SGIN_CANON_DEV_20260418`.

## Surfaces Confirmadas

- `applicationusers`
- `applicationuserroleset`
- `roles`
- `solutioncomponents`

## Componentes Resueltos

| Component Id | Component Type | Resolucion |
| --- | --- | --- |
| `2dcc528e-6a76-4bf1-a262-5ba8a60d16ac` | `10092` | `ApplicationUser` = `Microsoft Copilot Studio` |
| `a00413e7-7735-f111-88b4-002248e01c0a` | `10093` | `ApplicationUserRole` = `Microsoft Copilot Studio` + `System Customizer` |
| `9d0413e7-7735-f111-88b4-002248e01c0a` | `10093` | `ApplicationUserRole` = `Microsoft Copilot Studio` + `CCI admin` |
| `a50413e7-7735-f111-88b4-002248e01c0a` | `10093` | `ApplicationUserRole` = `Microsoft Copilot Studio` + `Environment Maker` |

## Lectura Operativa

- Los 4 ids del readback ya no quedan como `UNRESOLVED_OTHER`.
- En la solucion `PowerVirtualAgentsProd`, el primer id es el usuario de aplicacion y los otros tres son sus filas de rol asociadas.
- El paquete sigue siendo de lectura y mapa; no introduce live writes.

## Criterio

Si reaparece un nuevo id sin nombre, primero tipificar `componenttype`, luego bajar a la entidad concreta y solo despues registrar el nombre funcional.
