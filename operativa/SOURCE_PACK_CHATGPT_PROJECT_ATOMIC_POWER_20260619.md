# SOURCE_PACK_CHATGPT_PROJECT_ATOMIC_POWER_20260619

## Estado

SOURCE_PACK_READY

## Proposito

Pack local compacto para alimentar `ATOMIC POWER PROJECT CDX` en ChatGPT Project.
No configura UI, no conecta apps y no reemplaza las fuentes originales.

## Como leer

Orden minimo:

1. `README.md` - entrada visible del workspace.
2. `MAPA_MAESTRO.md` - navegacion rectora.
3. `operativa/CURRENT.md` - estado vivo.
4. `operativa/NEXT.md` - proximo delta.
5. `docs/superpowers/plans/README.md` - indice visible de planes.
6. `docs/superpowers/plans/MAPA.md` - ruta de lectura de planes.
7. `dataverse/README.md` - familia Dataverse y autoridad visible.
8. `dataverse/MAPA.md` - jerarquia Dataverse.
9. `dataverse/GATE.md` - gate local de Dataverse.
10. `agents/README.md`, `skills/README.md`, `chains/README.md` - roles, capacidades y secuencia.
11. `operativa/CODEX_CLOUD_CONTRACT_20260615.md` - ancla de cache y memoria.

## Frontera Local

- Hub de gobierno: `C:\CEO`
- Entrada canonica: `C:\CEO\project-cdx`
- Workspace fisico real: `C:\Users\enzo1\PROJEC CDX`
- Legacy/deprecated: `workbench`

## Estado Vivo

- Estado vigente: `WORKBOOK_SURFACES_WORKSPACE_REFRESHED`
- Workbook activo: `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx`
- Hojas vivas recientes: `Workspace Actual`, `Superficies Locales`, `Ramas Organizadas`
- Evidencia actual: `operativa/READBACK_DATAVERSE_WORKBOOK_BINDING_20260618.md`, `operativa/READBACK_WORKBOOK_SUPERFICIES_WORKSPACE_20260618.md`, `operativa/READBACK_BRANCH_ORGANIZATION_20260618.md`
- Regla viva: si ya existe evidencia vigente, no rehidratar ni reempaquetar

## Planes Rectores

- `docs/superpowers/plans/2026-06-19-plan-rector-cobertura-total.md`
- `docs/superpowers/plans/2026-06-19-normalizacion-cabina-local.md`
- `docs/superpowers/plans/2026-06-19-atomic-power-project-local-runtime.md`
- `docs/superpowers/plans/2026-06-19-dataverse-familia-cobertura.md`

## Dataverse

- Dataverse es una familia gobernada, no una raiz de gobierno.
- Estado de lectura: read-only hasta gate explicito.
- La puerta visible de familia es `docs/superpowers/plans/2026-06-19-dataverse-familia-cobertura.md`.
- `GATE.md` fija: ambiente exacto, target exacto, owner, rollback, postcheck y evidencia.
- No ejecutar imports, writes, env fetch, patch, activation ni flow run desde esta fuente.

## Agentes, Skills y Chains

- `agents/README.md` define los roles visibles: Seshat, Thot, Anubis, Maat y Horus.
- `skills/README.md` define capacidades reutilizables y su promocion a artefactos estables.
- `chains/README.md` define la secuencia visible: entrada, plan rector, plan de dominio, readback y cierre.

## Cache Y Memoria

`Codex Cloud cache` es un acelerador regenerable, no memoria canonica.
La verdad versionada vive en el repo; la memoria larga estructural vive en Dataverse; el contexto vivo conversacional vive en ChatGPT Project; los readbacks cierran decisiones observadas.

Regla tomada de `operativa/CODEX_CLOUD_CONTRACT_20260615.md`:
- nada unico, sensible, canonico o irreversible depende de cache
- si importa, se versiona en repo, se estructura en Dataverse o se cierra en readback

## Vigencia

Fecha del pack: `2026-06-19`

Si cambia cualquier fuente rectora, regenerar este pack en vez de arrastrar texto viejo.

## Stop Condition

Parar si falta alguna fuente requerida, si aparece contradiccion entre `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX`, o si se intenta convertir este pack en configuracion estatica o en write surface.
