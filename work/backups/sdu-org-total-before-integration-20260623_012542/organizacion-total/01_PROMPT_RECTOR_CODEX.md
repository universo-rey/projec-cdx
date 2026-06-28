# PROMPT RECTOR — SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1

ACTIVAR RUNNER: SDU_ORGANIZACION_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1

MODO:
- G1_LOCAL_REVERSIBLE
- DRY_RUN_DEFAULT=true
- NO_DELETE=true
- NO_OVERWRITE=true
- NO_LIVE=true
- NO_PUSH=true
- NO_PR=true
- NO_SECRET_EXPOSURE=true
- APPLY_REQUIRES_EXPLICIT_GATE=true

SUPERFICIE DE EJECUCIÓN:
- Visual Studio Code Insiders.

OBJETIVO:
Ejecutar organización total local bajo contrato SDU Federado, usando célula multiagente de al menos tres agentes con roles separados, seleccionados desde registros, matrices o artefactos ya existentes.

ANTES DE EJECUTAR:
1. Analizar registros existentes:
   - 01_GOVERNANCE_REGISTRY/AGENT_REGISTRY.yaml
   - 01_GOVERNANCE_REGISTRY/RUNTIME_REGISTRY.yaml
   - 01_GOVERNANCE_REGISTRY/CONFIGURATION_REGISTRY.yaml
   - governance matrix disponible
   - operativa/
   - .agents/
   - .codex/
   - .vscode/
   - .cabina/
   - C:\CEO\policy.json
   - C:\CEO\evidence
   - C:\CEO\project-cdx
2. Identificar agentes disponibles.
3. Seleccionar célula mínima de al menos 3 agentes.
4. Preferir célula ideal: SESHAT, THOT, ANUBIS, MAAT, HORUS.
5. Justificar selección.
6. No inventar agentes si existen equivalentes.
7. Si falta un agente, crear solo stub declarativo en AGENT_REGISTRY.patch.yaml.

CELULA MINIMA OBLIGATORIA:
- Router/Orquestador.
- Clasificador/Taxonomista.
- Guard/Gate/Seguridad.

CELULA IDEAL:
- SESHAT: router, memoria, clasificación canónica.
- THOT: arquitectura, esquemas, variables, superficies.
- ANUBIS: gates, seguridad, rollback, límites.
- MAAT: evidencia, auditoría, cumplimiento.
- HORUS: drift, riesgo, observabilidad.

REGLAS DE UNIVERSO:
- FEDERAL_SDU: control plane, canon, runtime, agentes, evidencia saneada.
- MODO_ON: estrategia, productos, consultoría, clientes, automatización.
- ESCRIBANIA_SGIN: documentos notariales, expedientes, cumplimiento, UIF, clientes, SGIN.

REGLAS DE DATOS:
- D0/D1: operativo normal.
- D2: confidencial, requiere clasificación.
- D3/D4/D5: revisión humana obligatoria antes de movimiento real.
- D6/D7: no mover, no abrir, no loguear contenido; solo metadata/hash.

REGLAS CROSS-UNIVERSE:
- CROSS_UNIVERSE_DENY_BY_DEFAULT.
- MODO_ON ↔ ESCRIBANIA_SGIN prohibido por defecto.
- FEDERAL_SDU puede recibir metadata saneada.
- contenido sensible raw no se mueve a FEDERAL_SDU.

REGLAS VS CODE INSIDERS:
1. Detectar VS Code Insiders.
2. Validar comando: code-insiders --version.
3. Crear workspace si falta.
4. Crear tasks si falta.
5. No modificar configuración global.
6. No instalar extensiones sin gate explícito.
7. No tocar secretos ni perfiles globales.

FASES:
0. Preflight.
1. Discovery de agentes.
2. Inventario.
3. Clasificación multiagente.
4. Plan.
5. Validación.
6. Evidencia.
7. Reporte.

SALIDA FINAL:
Readback completo con agentes seleccionados, roles, fuentes usadas, archivos inventariados, dominios detectados, conflictos, revisión manual, riesgos, próximos gates, comando VS Code Insiders, comando full dry-run y confirmación de que no hubo apply real.
