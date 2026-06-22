---
artifact_id: docs/gobernanza/nomenclatura.md
categoria: playbooks
tipo: plan
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/gobernanza/nomenclatura.md
etiquetas:
  - docs
  - nomenclatura
  - gobernanza
relacionados: []
descripcion: Convenciones de nombres para documentos, ramas y artefactos.
---
# Nomenclatura

## Principios

- Un nombre debe declarar funcion, superficie y estado.
- Los alias accidentales se registran como historicos o se reemplazan por canon vivo.
- Mantener `legacy` solo como contexto historico, no como puerta operativa.
- Preferir rutas relativas dentro del repo cuando el documento sea portable.
- La lectura documental canonica esta habilitada: mapas, actas, readbacks, indices,
  planes, skills y recetas son fuente de orientacion operativa.
- Usar la formula `leer canon / preservar secretos / escribir live solo con
  owner-gate`: los documentos orientan, las credenciales se protegen y las
  superficies externas se mutan con owner, rollback, postcheck y evidencia.
- Los estados `HOLD`, `STOP` y `GATE` son mecanismos de coordinacion; no deben
  redactarse como limites permanentes ni reemplazar un delta accionable.

## Prefijos utiles

| Prefijo | Uso |
|---|---|
| `docs-` | Documentacion canonica |
| `operativa-` | Evidencia o proceso vivo |
| `sdu-` | Sistema Declarativo Universal |
| `metadata-` | Esquemas, indices y manifiestos |
| `chore/`, `docs/`, `fix/`, `feature/` | Tipos de cambios Git |

## Terminos normalizados

- `fine-tuning`: ajuste fino de herramientas.
- `runtime`: ejecucion viva.
- `bootstrap`: instalacion o rehidratacion inicial.
- `repair`: reparacion de sistema.
- `lectura-canonica`: lectura permitida de documentos, indices, mapas, actas,
  readbacks, skills, recetas y configuracion no sensible.
- `secreto`: credencial, token, clave, `.env.local` o material equivalente que
  queda fuera de la lectura operativa ordinaria y solo circula por canal seguro.
- `live-write`: escritura sobre Git remoto, Microsoft, Dataverse, SharePoint,
  Codex Cloud u otra superficie externa.
- `owner-gate`: autorizacion humana concreta para pasar de lectura/preparacion a
  escritura o publicacion.
- `delta`: unidad minima de cambio verificable con frontera, rollback,
  postcheck y evidencia.
- `senal-no-vigente`: duplicacion, alias accidental, palabra heredada o
  artefacto que ya no mejora navegacion, ejecucion, evidencia ni decision.
