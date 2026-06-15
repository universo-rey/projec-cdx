# Dataverse Gobernado

## Entrada

Pedido que menciona Dataverse, Power Platform, Power Automate, Microsoft live, ambiente u org.

## Pasos

1. Leer `dataverse/GATE.md`.
2. Clasificar el estado.
3. Si hay live, exigir ambiente, org, target, owner, rollback, postcheck y evidencia.
4. Si falta algo, detener.
5. Registrar salida sin inferencia.

## Salida

Estado Dataverse explicito.

## Stop Condition

`wrong_environment_or_default`, `target_identity_ambiguous`, `live_surface_without_order`
