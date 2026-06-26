# Agents SDK Live Agent Global Operability Org Chart

Status: `ACTIVE_REVIEW_ORG_CHART`

This map is scoped to PR `#101` and the versioned live evidence package for
`agent_global_operability`. It does not create persistent remote agents and it
does not authorize live writes.

```mermaid
flowchart TB
  A["rey.control_plane_orchestrator<br/>Executive orchestration"]
  B["rey.frontier_guardian<br/>Frontier and gates"]
  C["court.openai_dispatcher<br/>Runtime boundary"]
  D["court.sdu_gate<br/>Decision gate review"]
  E["court.seshat_evidence<br/>Evidence owner"]
  F["court.thot_schema<br/>Validator owner"]
  G["rey.repo_cartographer<br/>Repo scope"]
  H["rey.authority_canonist<br/>Canon alignment"]
  I["universe.escribania_tower<br/>Microsoft live surface"]
  J["universe.modo_on_tower<br/>Provider boundary"]
  K["tech.reference_librarian<br/>Reference boundary"]
  L["codex.workspace_guardian<br/>Workspace topology"]
  M["subagent.readonly_scout"]
  N["subagent.matrix_auditor"]
  O["subagent.skill_recipe_auditor"]
  P["subagent.order_packet_preparer"]
  Q["subagent.integration_reviewer"]

  A --> B
  A --> C
  A --> E
  A --> F
  A --> G
  A --> H
  B --> D
  B --> I
  B --> L
  F --> K
  J --> B
  M --> A
  N --> F
  O --> C
  P --> B
  Q --> E
```

## Operating Rule

- `rey.control_plane_orchestrator` authorizes only repo-scoped next-lane
  packaging in this PR.
- `rey.frontier_guardian` owns live, cost, production, remote mutation and
  worktree gates.
- `court.openai_dispatcher` owns the OpenAI and Agents SDK runtime boundary.
- `court.sdu_gate` reviews decisions and prevents self-approval.
- `court.seshat_evidence` owns evidence and readback continuity.
- `court.thot_schema` owns matrix, schema and validator consistency.

## Stop

Stop at PR review until a human gate explicitly authorizes ready promotion or
merge precheck with fixed HEAD.
