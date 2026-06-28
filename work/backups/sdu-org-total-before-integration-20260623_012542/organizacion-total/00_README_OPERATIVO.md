# SDU Organización Total Multiagente — VS Code Insiders — G1 Local

**Paquete:** `SDU_ORG_TOTAL_MULTIAGENTE_VSCODE_INSIDERS_G1_20260623`  
**Estado:** listo para ser copiado a `C:\CEO\project-cdx\.cabina\organizacion-total\` o usado como paquete rector de implementación.  
**Modo:** `G1_LOCAL_REVERSIBLE`  
**Regla:** `DRY_RUN_DEFAULT=true`  

## Propósito

Este paquete materializa un runner de organización total local bajo contrato SDU federado, con célula multiagente y ejecución controlada desde Visual Studio Code Insiders.

No es un script único. Es una célula operativa:

- **SESHAT** — router, memoria y clasificación canónica.
- **THOT** — arquitectura técnica, configuración, superficies y reglas.
- **ANUBIS** — gates, seguridad, sensibilidad, rollback y bloqueos.
- **MAAT** — evidencia, auditoría, manifiestos y trazabilidad.
- **HORUS** — drift, duplicados, ruido, riesgos y observabilidad.

## Garantías del paquete

- No borra archivos.
- No sobrescribe destinos.
- No mueve archivos en fase dry-run.
- No abre live.
- No hace push.
- No abre PR.
- No lee ni registra secretos reales.
- No registra contenido sensible raw.
- Clasifica por universo, sensibilidad, función y evidencia.
- Todo lo dudoso cae en `98_REVISION_MANUAL`.

## Flujo de ejecución

Desde `C:\CEO\project-cdx`:

```powershell
# Copiar este paquete dentro de .cabina\organizacion-total o ejecutar desde su ruta.
code-insiders .vscode\sdu-organizacion-total.code-workspace
```

Desde VS Code Insiders, ejecutar la tarea:

```text
SDU: Full DryRun
```

O por consola:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Invoke-SDUOrgFullDryRun.ps1
```

## Salidas esperadas

```text
out/selected-agents.json
out/agent-role-map.md
out/inventory.csv
out/classification.csv
out/move-plan.csv
out/risk-register.csv
out/manual-review.csv
out/evidence-manifest.json
out/org-report.md
logs/*.log
```

## Promoción posterior

La ejecución real requiere gate posterior y explícito. Este paquete solo deja plan, evidencia, riesgos y readback.
