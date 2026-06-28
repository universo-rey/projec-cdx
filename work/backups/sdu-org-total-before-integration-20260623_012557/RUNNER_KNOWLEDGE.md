# RUNNER KNOWLEDGE — conocimiento operativo preciso

## 1. Principio general

No se organiza por extensión solamente. Se organiza por:

```text
universo → entorno → activo → función → sensibilidad → evidencia → gate
```

## 2. Tipos de activo reconocidos

Un archivo puede ser:

- documento institucional;
- evidencia;
- contrato;
- configuración;
- secreto referenciado;
- runtime artifact;
- expediente;
- fuente canónica;
- output técnico;
- snapshot;
- backup;
- ruido candidato;
- elemento en revisión manual.

## 3. Universos

### FEDERAL_SDU
Control plane, canon, contratos, agentes, validadores, runtime, evidencia saneada, matrices, registries.

### MODO_ON
Estrategia, productos, consultoría, clientes, metodologías, activos comerciales, innovación y sistemas internos.

### ESCRIBANIA_SGIN
Expedientes, documentos notariales, clientes, cumplimiento, UIF, KYC, RUC, protocolo, testimonio, SGIN, SharePoint/Dataverse/Power Platform institucional.

## 4. Sensibilidad

- D0: público.
- D1: interno.
- D2: confidencial.
- D3: personal restringido.
- D4: sensible legal.
- D5: jurídico/notarial/privilegiado.
- D6: secreto técnico.
- D7: crítico institucional.

## 5. Reglas sensibles

- SGIN tiene prioridad de protección.
- Todo documento notarial, cliente, expediente, KYC, UIF, escritura, protocolo, testimonio, RUC o matriz de riesgo se marca como `ESCRIBANIA_SGIN` y `D3-D5` salvo evidencia contraria.
- FEDERAL_SDU no recibe contenido sensible raw.
- MODO_ON no se mezcla con ESCRIBANIA_SGIN.
- Si un archivo parece de dos universos, pasa a `98_REVISION_MANUAL`.

## 6. Reglas de evidencia

Registrar:
- ruta;
- hash;
- tamaño;
- extensión;
- fecha;
- clasificación;
- agente votante;
- conflicto;
- riesgo;
- destino propuesto.

No registrar por defecto:
- contenido íntegro;
- DNI completos;
- secretos;
- tokens;
- prompts crudos con datos sensibles;
- respuestas crudas del modelo.

## 7. VS Code Insiders

VS Code Insiders es superficie de ejecución, no autoridad. La autoridad vive en:

- contrato;
- registros;
- evidencia;
- owner;
- gates.

## 8. Cierre

El runner no decide cierre. Propone, evidencia y deja readback.
