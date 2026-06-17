# Versionado Documental Local 20260617

## Estado

PAQUETE_1_PREPARADO

## Objetivo

Cerrar el versionado local por paquetes, sin staging masivo y sin mezclar superficies.

## Paquete 1

- Alcance: `hitos/` + `operativa/`
- Tipo: documentos locales de canon, evidencia, readbacks, indices, manifests y JSON/CSV sanitizados.
- Extensiones incluidas: `.md`, `.csv`, `.json`, `.yaml`, `.yml`.
- Excluido por diseno: `.reg`, `.txt`, cache y binarios.
- Motivo: esos archivos pueden ser backups/logs tecnicos y no canon documental limpio.

## Precheck

- Rama: `codex/dataverse-corte-ejecutora-v1`.
- Remote: `origin https://github.com/universo-rey/projec-cdx.git`.
- Staging previo: vacio.
- Barrido de contenido: sin valores secretos detectados; solo menciones defensivas a secretos/tokens.
- JSON del paquete: parseable.
- YAML del paquete: no vacio.

## Siguiente Paquete

`inventarios/`

## Regla

No usar `git add .`. Cada paquete debe stagearse por lista explicita y validarse antes de commit.
