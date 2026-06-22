# SDU MAX BASELINE LIVE ROLLBACK POSTCHECK 20260622

Estado: `LOCAL_ONLY`

Resultado rector: `SDU_MAX_BASELINE_LIVE_READY_LOCKED_NO_EXTERNAL_EXECUTION`

## Regla general

Si no existe rollback claro, la superficie no puede pasar a live write.

Cada apertura futura exige:

- target
- owner
- rollback
- postcheck
- evidencia
- stop condition

## Local PowerShell

Rollback:

- revertir cambios de perfil solo si existieron y hay backup.
- restaurar variables de sesion si fueron alteradas.
- no modificar `MachinePolicy`, `UserPolicy`, `CurrentUser` ni `LocalMachine` sin orden explicita.

Postcheck:

- `tools/sdu_boot.ps1 -Mode all -Agent All -NoExternal -DryRun -Json` devuelve `PASS`.
- `tools/sdu_chain_resolver.py --no-external --dry-run --json` devuelve `PASS`.

## Git

Rollback:

- revert commit local solo si el operador lo ordena.
- no usar `git reset --hard` por defecto.
- no reescribir historia.
- no tocar remoto por inferencia.

Postcheck:

- `git status --short` limpio o justificado.
- HEAD esperado registrado.
- baseline `d62dd31b`, post-baseline `0bd495fc` y overlay `f9e06b76` siguen como ancestros.

## GitHub

Rollback:

- cerrar PR revertible si existiera en apertura futura.
- revert commit por PR si aplicara.
- no borrar ramas sin decision humana.

Postcheck:

- workflow status visible.
- branch protection no alterada.
- no push directo no autorizado.

## Codex Cloud

Rollback:

- cancelar tarea externa futura si fue creada por gate.
- desvincular project binding si fue creado por gate.
- conservar evidencia local del intento.

Postcheck:

- no tareas activas no autorizadas.
- no mutacion de repo externo no autorizada.
- cache tratada solo como acelerador regenerable.

## OpenAI

Rollback:

- cancelar batch si fue creado por gate.
- eliminar o archivar recurso solo si el gate lo autoriza.
- registrar recurso, owner y estado final.

Postcheck:

- no recursos huerfanos.
- no secretos persistidos.
- presupuesto y owner registrados si se habilita live.

## Microsoft / Graph / SharePoint

Rollback:

- revertir elemento, documento, version, lista o permiso si fue mutado por gate.
- conservar ID/path/version antes y despues.
- no ejecutar login interactivo por inferencia.

Postcheck:

- confirmar item/version/path.
- confirmar tenant correcto.
- confirmar que no hay writes no autorizados.

## Dataverse / Power Platform

Rollback:

- solution backup antes de import/update.
- revisar unmanaged layer si existe mutacion.
- revertir flow state si aplica.
- conservar environment target.

Postcheck:

- validator especifico obligatorio.
- environment target correcto.
- no tenant mismatch.
- no solution import/export sin evidencia.

## Local bridge / MCP / Watchdog

Rollback:

- detener proceso por PID registrado si fue iniciado por gate.
- liberar puerto.
- invalidar token dev si existio.

Postcheck:

- puerto cerrado o esperado.
- no proceso huerfano.
- no placeholder ejecutable.

## Decision final

`LIVE_WRITE_REQUIRES_ROLLBACK_POSTCHECK_EVIDENCE`
