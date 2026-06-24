# BOUNDARY CANON CONFLICT 20260622

## Estado
SDU_BOUNDARY_CANON_CONFLICTS_CLASSIFIED

## Archivo creado
- `operativa/archive/legacy-root/20260622/BOUNDARY_CANON_CONFLICT_MATRIX_20260622.csv`

## Regla efectiva
Cuando una senal pide apertura externa y otra senal conserva frontera, gana la frontera mas estricta hasta owner gate explicito.

## Decision por superficie
- Local: allowed para leer, analizar, testear, refactorizar metadata e indexar.
- GitHub: blocked without gate.
- OpenAI: blocked without gate.
- Microsoft/SharePoint: blocked without gate.
- Dataverse/Power Platform: blocked without gate.
- Codex Cloud: blocked without gate.

## Resultado
No hay contradiccion operativa activa. Hay secuencia gobernada: primero evidencia local, luego gates externos con target, owner, rollback, postcheck y evidencia.
