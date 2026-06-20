# Acta Seshat - Erradicacion Bug PowerShell

Fecha: 2026-06-18
Modo: local, gobernado, sin live writes externos
Custodio documental: Seshat
Workbench: `C:/Users/enzo1/PROJEC CDX`

## Dictamen

Estado: ERRADICACION LOCAL CONFIRMADA.

El ruido de PowerShell `Cannot bind argument to parameter 'Path' because it is an empty string` quedo resuelto en la superficie viva de arranque local. La causa raiz no estaba en los repos de trabajo, sino en la cadena de perfiles PowerShell:

1. Shims de perfil `PowerShell` y `WindowsPowerShell`.
2. Arranque `C:/CEO/Start-CEO.ps1`.
3. Perfil canonico `C:/Users/enzo1/.codex/profiles/powershell/base/Microsoft.PowerShell_profile.ps1`.

No se ejecuto Dataverse write, flow run, import, patch, auth nueva ni cambios live externos.

## Cronologia del trabajo de hoy

1. Se continuo desde `C:/Users/enzo1/PROJEC CDX`.
2. Se confirmo PAC disponible en `C:/CEO/tools/pac/microsoft.powerapps.cli.2.8.1/tools/pac.exe`.
3. Se confirmo ambiente Dataverse con target exacto `https://org084965d9.crm.dynamics.com/`, ambiente `HUBDesarrollo`.
4. Se resolvio disponibilidad de Azure CLI:
   - `az` instalado.
   - PATH de usuario actualizado.
   - Version verificada: `2.87.0`.
5. Se ejecuto Dataverse live read-only:
   - `all_pairs_confirmed=true`.
   - `pair_count=5`.
   - `writes_executed=false`.
   - `flows_executed=false`.
6. Se actualizo evidencia Dataverse:
   - `operativa/DATAVERSE_REHIDRATACION_LIVE_READ_20260617.json`.
   - commit local: `23931bad chore: refresh dataverse live read evidence`.
7. Launch Desk quedo on-demand:
   - procesos detenidos.
   - puertos `3000` y `8000` libres.
8. Se detecto ruido residual de PowerShell:
   - origen visible inicial: `C:/CEO/Documents/PowerShell/profile.ps1`.
   - mensaje: `Cannot bind argument to parameter 'Path' because it is an empty string`.
9. Se inspeccionaron perfiles vivos:
   - `C:/CEO/Documents/PowerShell/profile.ps1`.
   - `C:/CEO/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`.
   - `C:/CEO/Documents/WindowsPowerShell/profile.ps1`.
   - `C:/CEO/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`.
   - copias equivalentes bajo `C:/Users/enzo1/Documents/...`.
10. Se aplico guardia idempotente a los shims:
    - ruta literal `C:/CEO/Start-CEO.ps1`.
    - variable global `__CeoStartProfileLoaded`.
    - validacion de ruta vacia antes de dot-source.
11. El primer postcheck mostro que el fallo persistia dentro de la cadena.
12. Se capturo stack real con `pwsh -NoProfile`:
    - causa raiz: `C:/Users/enzo1/.codex/profiles/powershell/base/Microsoft.PowerShell_profile.ps1`, linea del uso de `$env:WINDIR`.
13. Se corrigio el perfil base:
    - `WINDIR` ahora se valida antes de llamar `ConvertTo-CeoPath`.
    - la condicion `StartsWith($windowsTrapPath, ...)` queda gateada si `windowsTrapPath` esta vacio.
14. Postcheck final:
    - PowerShell 7 carga limpio.
    - Windows PowerShell carga limpio con `ExecutionPolicy Bypass`.
    - `az` disponible.
    - PAC disponible.
    - barrido de repos versionados sin hits ejecutables del bug.

## Cambios aplicados

Perfiles vivos corregidos:

- `C:/CEO/Documents/PowerShell/profile.ps1`
- `C:/CEO/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- `C:/CEO/Documents/WindowsPowerShell/profile.ps1`
- `C:/CEO/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`
- `C:/Users/enzo1/Documents/PowerShell/profile.ps1`
- `C:/Users/enzo1/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- `C:/Users/enzo1/Documents/WindowsPowerShell/profile.ps1`
- `C:/Users/enzo1/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`

Perfil canonico corregido:

- `C:/Users/enzo1/.codex/profiles/powershell/base/Microsoft.PowerShell_profile.ps1`

## Evidencia de verificacion

Checks ejecutados:

- PowerShell 7: `pwsh_profile_loaded_ok`, version `7.6.2`, sin ruido de perfil.
- Windows PowerShell: `windows_powershell_profile_loaded_ok`, version `5.1.26100.8687`, sin ruido de perfil bajo `ExecutionPolicy Bypass`.
- Azure CLI: `2.87.0`.
- PAC: `Microsoft PowerPlatform CLI`, version `2.8.1+ga4eb71c`.
- Barrido repos `C:/Users/enzo1/Documents/GitHub`: sin coincidencias versionadas para `CeoStartProfile`, `Start-CEO.ps1` o el mensaje exacto del bug.

## Plan de erradicacion universo

Objetivo: que ningun repo, perfil local o entrada de arranque vuelva a introducir un dot-source fragil con ruta vacia.

Fase 1 - Superficie viva local: COMPLETADA.

- Target: perfiles `C:/CEO/Documents/*PowerShell*` y `C:/Users/enzo1/Documents/*PowerShell*`.
- Accion: guardia idempotente y validacion de ruta.
- Postcheck: shell nueva sin ruido.

Fase 2 - Canon `.codex`: COMPLETADA.

- Target: `C:/Users/enzo1/.codex/profiles/powershell/base/Microsoft.PowerShell_profile.ps1`.
- Accion: validar `$env:WINDIR` antes de convertir ruta.
- Postcheck: `Start-CEO.ps1` carga sin exception.

Fase 3 - Repos `Documents/GitHub`: OBSERVADO SIN PATCH.

- Target: repos git bajo `C:/Users/enzo1/Documents/GitHub`.
- Accion: barrido de archivos versionados.
- Resultado: sin copias ejecutables del bug.
- Regla: no abrir ramas ni tocar repos sin hit real.

Fase 4 - Guardia futura: PENDIENTE SI SE DECIDE VERSIONAR.

- Crear o promover un validador local que falle si aparece:
  - dot-source de variable de ruta sin `IsNullOrWhiteSpace`.
  - uso directo de `$env:WINDIR` como parametro obligatorio sin guardia.
  - doble carga de perfiles sin guardia idempotente.

## Rollback

Rollback manual posible:

1. Restaurar los shims de perfil a la forma anterior.
2. Restaurar la linea de `$windowsTrapPath` sin guardia.
3. Reejecutar shell nueva para confirmar regreso del sintoma.

Rollback no recomendado porque el postcheck confirmo correccion y no se tocaron secretos ni servicios externos.

## Stop conditions futuras

Detener si:

- aparece secreto o token en archivos de perfil;
- se requiere tocar registro, firewall, Defender o permisos globales;
- un repo tiene cambios no clasificados en el mismo archivo a corregir;
- un perfil pertenece a otra cuenta o tenant no confirmado;
- el fix requiere ejecutar live writes externos.

## Cierre

Decision Seshat: el bug queda erradicado en la superficie viva local y documentado para no reintroducirlo. El universo repo no requiere parche masivo porque el barrido versionado no encontro copias ejecutables del patron.

Proximo movimiento unico: si se quiere cierre remoto del workbench, publicar `main` con los commits locales pendientes.
