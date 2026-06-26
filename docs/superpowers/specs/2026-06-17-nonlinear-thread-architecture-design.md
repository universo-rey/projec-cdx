# Nonlinear Thread Architecture Design 2026-06-17

## Decision

Use a `5+1 hub-and-spokes` model.

The current `PROJEC CDX` thread remains `CONTROL_TOWER`.
Five work fronts are prepared as active thread packets.
One Cloud/Dataverse front remains `PREFLIGHT_WAITING`, not active until repo deltas stabilize.

No new thread is created by this spec. Thread creation is a separate explicit action.

## Why

The work is no longer naturally linear. W1 classified `13` dirty repos across canon, runtime README-only, evidence packages, SGIN surfaces, and CDF operational evidence. A single thread would serialize unrelated reviews and overload context. Multiple threads are safe only if each one has a bounded read scope, write scope, lock, validator, rollback and fan-in contract.

## Chosen Architecture

| Front | Mode | Scope | Reason |
| --- | --- | --- | --- |
| `HILO_A_CABINA_CANON` | active-ready | `cabina-universal-d` canon/context | Highest-risk canon package. |
| `HILO_B_SDU_CANON` | active-ready | `sdu-canon` context | Shared SDU state. |
| `HILO_C_RUNTIME_README_BATCH` | active-ready | README-only runtime/base repos | Low-risk batch, can run independently. |
| `HILO_D_SESHAT_SGIN_EVIDENCE` | active-ready | `seshat-bootstrap-sdu-cn`, `Sgin`, `sgin-cumplimiento` | Identity/evidence/SGIN lane. |
| `HILO_E_CDF_SOLUCIONES` | active-ready | `cdf-soluciones` | Context plus evidence, requires own lane. |
| `HILO_F_CLOUD_DATAVERSE_READY` | preflight-waiting | Codex Cloud, tenant, Dataverse | Must wait for repo deltas or refreshed read-only gate. |

## Alternatives Considered

### 3 Threads

Simpler coordination, but it keeps canon and CDF/evidence mixed too long. It reduces concurrency but does not solve the bottleneck.

### 5+1 Threads

Recommended. It creates enough parallelism while preserving gates. Each risky surface gets its own lane, and low-risk README-only changes are batched.

### 13 Threads

Too much overhead. It would create thread sprawl and make fan-in harder than the work itself.

## Thread Rules

- The control tower owns fan-in, final staging, commits, pushes and closure.
- Spoke threads start read-only unless their packet explicitly permits a local document change.
- No spoke thread executes Microsoft, SharePoint, Dataverse, Power Automate, Codex Cloud task creation, production, permission, secret or destructive action.
- Dirty repo threads must not run `git add`, `git commit`, `git reset`, `git checkout --`, delete, move or clean.
- Each spoke returns a compact readback with evidence, recommendation, risk and next delta.
- If a spoke finds unrelated changes, it stops with `repo_diff_unclassified`.
- If a spoke needs mutation, it returns a proposal; the control tower decides.

## Interfaces

Inputs:

- `inventarios/W1_REPOS_DIRTY_TRIAGE_20260617.csv`
- `operativa/archive/legacy-root/20260617/READBACK_W1_REPOS_DIRTY_TRIAGE_20260617.md`
- `operativa/archive/legacy-root/20260617/THREAD_ARCHITECTURE_5_PLUS_1_20260617.md`
- `operativa/archive/legacy-root/20260617/THREAD_CREATION_QUEUE_5_PLUS_1_20260617.csv`
- `operativa/thread-packets-20260617/*.md`

Outputs:

- One readback per spoke thread.
- One fan-in readback in `PROJEC CDX`.
- Optional later commits only after control tower review.

## Error Handling

- `repo_diff_unclassified`: spoke stops and reports exact files.
- `lane_scope_overlap`: control tower reassigns or serializes.
- `live_surface_requested`: spoke refuses and returns order packet requirement.
- `secret_detected`: spoke stops and reports only file path/type, not secret value.
- `thread_target_unavailable`: use packet as prompt in current control tower until a thread target exists.

## Testing And Validation

Before creating threads:

- `git status --short --branch`
- `git diff --check`
- `tools/validate_proj_cdx_workbench.ps1`
- `tools/validate_proj_cdx_sync.ps1`
- `tools/validate_proj_cdx_operational_chain.ps1`

After each spoke returns:

- Verify it did not mutate forbidden surfaces.
- Verify readback shape is complete.
- Verify next delta is singular.

## Approval State

Design approved by owner: `ACEPTO TU RECOMENDACION`.

Execution gate:

- Thread packets may be created as local artifacts now.
- Actual Codex thread creation requires explicit next order: `abrir hilos` or equivalent.

## Self Review

- No placeholders.
- No live authority implied.
- Scope decomposed into six bounded fronts.
- `HILO_F` kept waiting because Cloud/Dataverse should consume stable repo outputs, not race them.
