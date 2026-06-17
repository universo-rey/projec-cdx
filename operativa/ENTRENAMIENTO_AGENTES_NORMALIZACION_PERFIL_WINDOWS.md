# Entrenamiento Agentes - Normalizacion Perfil Windows

- Antes de escribir, leer el contexto local minimo y verificar el delta exacto.
- Si la ruta toca perfil, OneDrive o compatibilidad, inspeccionar primero y no inferir.
- No cambiar nada si falta confirmacion de origen, destino o efecto.

## Verificar siempre

- Distinguir `perfil local` de `OneDrive` y de cualquier espejo o redireccion.
- Confirmar carpeta real con ruta absoluta, no solo con el nombre visible.
- Revisar si el contenido vive en `Users\...`, `OneDrive\...` o una combinacion de ambos.

## Junctions de compatibilidad

- Tratar junctions y links como compatibilidad, no como verdad documental.
- Resolver el destino real antes de copiar, comparar o normalizar.
- No asumir que una junction indica ubicacion primaria o superficie editable.

## No asumir

- `@GMT` no es ruta activa de trabajo; suele ser snapshot o vista historica.
- `OneDrive` no garantiza que el archivo este local, estable o sincronizado.
- Un nombre de carpeta familiar no prueba que el origen sea el esperado.

## Stop conditions

- Si hay ambiguedad entre local, OneDrive o snapshot, parar.
- Si la ruta resuelve a mas de una superficie, parar.
- Si la accion puede duplicar, mover o desalinear perfiles, parar.

## Señales de exito

- La ruta real quedo identificada.
- El origen quedo clasificado como local, OneDrive o compatibilidad.
- No se tocó nada ambiguo.

## Rehidratacion y readback

- Rehidratar la superficie antes de cada ejecucion nueva.
- Cerrar cada wave con un readback corto y una senal atomica.
- La senal atomica debe decir: que cambio, que quedo listo y cual es el siguiente delta.
- Si cambia ruta, target o compatibilidad, no seguir sin readback.

## Explosion en el resultado

- El cierre tiene que dejar un resultado visible, no una nota tibia.
- Priorizar salidas claras, navegables y accionables.
- Si el cambio no se ve ni se entiende de inmediato, falta un delta o falta readback.
