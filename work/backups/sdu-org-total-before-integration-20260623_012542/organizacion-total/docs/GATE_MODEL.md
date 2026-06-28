# Modelo de Gate — Organización Total

## G1_LOCAL_REVERSIBLE

Permitido:
- inventario;
- clasificación;
- plan;
- evidencia;
- reportes;
- stubs declarativos;
- workspace local;
- tasks locales.

Prohibido:
- borrar;
- sobrescribir;
- mover realmente;
- publicar;
- abrir PR;
- push;
- live;
- exponer secretos;
- registrar contenido sensible raw.

## Promoción posterior

El apply real requiere un gate explícito posterior con:

- owner;
- target exacto;
- scope;
- rollback;
- candidate count;
- validator;
- evidence sink;
- stop condition;
- readback.
