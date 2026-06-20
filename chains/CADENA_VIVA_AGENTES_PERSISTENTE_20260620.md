# Cadena Viva de Agentes Persistente

Estado: ACTIVA_GOBERNADA
Owner humano: Enzo Figueroa
Superficie: PROJEC CDX / Codex Desktop / hilos laterales
Fecha de apertura: 2026-06-20

## Orden Viva

La cadena permanece encendida como carril de coordinacion. Cada agente mantiene su rol, devuelve evidencia corta y no deja trabajo flotando en conversacion.

El pulso no reemplaza autoridad humana. El pulso sostiene continuidad, pide contratos de retorno, detecta hilos desactualizados y vuelve al mapa canonico cuando una superficie queda ambigua.

## Agentes Persistentes

| Agente | Responsabilidad | Retorno esperado |
| --- | --- | --- |
| Seshat | Actas, lectura rectora, cierre documental | Acta corta, cobertura y proximo delta |
| Thot | Taxonomia, nombres, rutas, variables | Matriz de coherencia y rutas canonicas |
| Anubis | Fronteras, legado, stop conditions | Riesgo, rollback y condicion de corte |
| Maat | Validacion, dueños, no duplicidad | PASS/OBSERVED/FAIL y evidencia |
| Horus | Mapas, superficies, flechas operativas | Camino visible y superficie destino |
| Atomic | Atomizacion, encadenado, pulso vivo | Delta minimo, estado y siguiente accion |

## Mecanica Siempre Activa

1. Este hilo queda como control y coordinacion.
2. Los hilos laterales ejecutan carriles concretos.
3. Cada carril devuelve contrato: `ESTADO`, `DELTA`, `HILO`, `ACCION`, `STOP`.
4. El latido revisa si faltan retornos y pide reemision sin abrir trabajo nuevo.
5. El cierre se registra en readback o plan vigente, no solo en chat.

## Carriles Activos

| Carril | Hilo | Estado esperado |
| --- | --- | --- |
| Inventario local y superficies reales | INVENTARIO LOCAL | Retorno de Task 1 / matriz de inventario |
| Indice rector y cobertura | Identificar delta nuevo | Retorno de matriz visible / huecos |
| Source pack Atomic Power | Revisar diferencias del modelo | Reconciliacion del paquete fuente |

## Fronteras

- No se crean agentes remotos persistentes sin target, owner, kill switch, rollback y postcheck.
- No se ejecutan writes en Microsoft, Dataverse, GitHub o Codex Cloud desde este contrato.
- No se imprime ni mueve secreto alguno.
- No se abre un cuarto frente si el delta puede volver a un carril existente.

## Kill Switch

Pausar o borrar la automatizacion `Cadena viva SDU control tower`.

Rollback documental: revertir este archivo y las referencias en `chains/README.md` y `agents/README.md`.

## Postcheck

- Este archivo existe y es visible desde `chains/README.md`.
- `agents/README.md` declara a Atomic y la regla de persistencia.
- La automatizacion de latido queda activa o, si falla, el stop condition queda registrado.

## Stop Condition

`cadena_persistente_sin_postcheck` si no se puede activar o verificar el latido.

`thread_tools_unavailable` si no se pueden consultar o despertar hilos laterales.

`remote_persistence_requires_packet` si el siguiente paso pide agentes remotos permanentes sin target, owner, kill switch, rollback y postcheck.
