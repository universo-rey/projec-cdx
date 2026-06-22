# SDU 0.4.x Remote Patch Wave Index

## Estado base
SDU_MAX_ADVANCE_AFTER_0.3.0_CLOSED_WITH_REMOTE_PATCH_QUEUE

## Definicion
`0.4.x` es una wave de patches remotos preparada localmente. No ejecuta push, PR, workflow dispatch ni superficies live.

## Regla de ejecucion
Cada gate abre una unica superficie remota con owner, rollback, postcheck y evidencia. Si requiere live tenant, queda bloqueado por gate separado.

## Gates
1. `0.4.0` Dataverse DEV precheck patch - `universo-rey/cabina-universal-d`
2. `0.4.1` Power Automate validator patch - `universo-rey/cabina-universal-d`
3. `0.4.2` Bridge auth validator patch - `universo-rey/cabina-universal-d`
4. `0.4.3` Bridge loopback and MCP gating patch - `universo-rey/cabina-universal-d`
5. `0.4.4` Governance CI path coverage patch - `universo-rey/cabina-universal-d`
6. `0.4.5` No-PS validator wiring patch - `universo-rey/cabina-universal-d`
7. `0.4.6` MCP/Codex Cloud preflight checkout patch - `universo-rey/cabina-universal-d`
8. `0.4.7` Local synthetic harness fixture/import patch - `universo-rey/cabina-universal-d`
9. `0.4.8` Change-aware evidence refresh regen gate - `universo-rey/cabina-universal-d`
10. `0.4.9` Cabina runtime CI remote log collection - `universo-rey/cabina-universal-d`

## Frontera
No push. No PR. No workflow dispatch. No Dataverse live. No Microsoft live. No SharePoint live. No Power Platform mutation. No OpenAI live. No Codex Cloud.
