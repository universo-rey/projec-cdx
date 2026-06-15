# Procedencia Layout On Demand

Receta reusable para procesos que solo deben abrirse por demanda y no por costumbre.

## Cuándo Usarla

Cuando un delta toca una de estas superficies:

- configuracion interna o perfil tecnico;
- anclas de acceso;
- notas visibles que deben quedar compactas;
- cualquier referencia que no debe confundirse con habilitacion live.

Ejemplos tipicos:

- `tge.config.toml` como procedencia/layout TGE.
- `dataverse/ANCLA_CIERRE_WAVE.md` como ancla de acceso on-demand.
- notas raiz que deben bajar ruido sin abrir superficies de escritura.

## Derivación

1. Identificar el delta real y su frecuencia de repeticion.
2. Clasificar la superficie como visible, referencia, on-demand o live.
3. Mover la procedencia tecnica a la capa de referencia si no debe quedar al frente.
4. Mantener la raiz visible compacta y sin lenguaje ambiguo de habilitacion.
5. Abrir accesos solo desde `operativa/ANCLAS_ON_DEMAND.md`.
6. Escribir la regla explicita: `procedencia/layout only`.
7. Actualizar los indices visibles y la matriz de capa si cambia una receta o un proceso.
8. Validar con el validador local.

## Salida

Superficie coherente, reusable y separada entre procedencia tecnica, acceso on-demand y lectura visible.

## Stop Condition

- Falta evidencia.
- Falta validador.
- Se intenta convertir procedencia en permiso live.
- Se toca secreto o estado sensible por inferencia.
