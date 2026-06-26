# VSI startup commands

## Canon command

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File .agents\codex\tools\local_start_vsi_cabina.ps1
```

This is the human startup command for the local VSI workbench. It starts or
reuses the loopback dashboard on `http://127.0.0.1:8795`, verifies VS Code
Insiders, fixes the Agile Agent Canvas user catalogue path to the repo-local
`.agents\skills`, opens the Agile Agent Canvas surface, and reads the dashboard
API before closing.

Before changing the VS Code Insiders user setting, the command verifies that a
reused loopback bridge reports this repo root through `/api/dashboard`. If the
port belongs to another checkout or stale bridge, it fails with
`vsi_startup_bridge_repo_mismatch`.

## Validation command without opening VSI

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File .agents\codex\tools\local_start_vsi_cabina.ps1 -NoOpenVsi
```

Use this form when only local evidence is needed. It performs the same bridge,
settings, extension, dashboard and anti-regression checks without opening the
Insiders window.

## No downgrade rule

Startup must preserve implemented work as implemented. Tasks up to
`vsi.agent.task.039` must remain `EXECUTED_*`; the startup command fails with
`vsi_startup_state_regression_detected` if any completed task returns to
prepared, pending, gated, blocked or queued state.

New live frontiers may still require exact target, owner, identity, rollback
and postcheck before external writes. That does not downgrade already executed
local, dry-run or governed smoke lanes.

## Expected evidence

- dashboard URL: `http://127.0.0.1:8795`
- bridge launch: direct `node.exe src/server.mjs`, no nested `powershell.exe -Command`
- bridge repo check:
  `repo_root=C:\Users\enzo1\Documents\GitHub\cabina-universal-d`
- VS Code Insiders CLI:
  `C:\Users\enzo1\AppData\Local\Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd`
- Agile Agent Canvas extension: `msayedshokry.agileagentcanvas`
- user catalogue path:
  `C:\Users\enzo1\Documents\GitHub\cabina-universal-d\.agents\skills`
- queue check: `queued_agent_tasks=0`
- state check: `no_completed_task_downgrade=true`
