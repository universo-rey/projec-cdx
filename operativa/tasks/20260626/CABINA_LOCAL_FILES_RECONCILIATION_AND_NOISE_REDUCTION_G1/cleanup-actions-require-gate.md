# CLEANUP ACTIONS REQUIRE GATE

Command: CABINA_LOCAL_FILES_RECONCILIATION_AND_NOISE_REDUCTION_G1
Generated: 2026-06-26T07:07:32Z

Every item below requires a new human gate before any apply pass.

- GATE_QUARANTINE_CACHE_TEMP
  Target: __pycache__/, .ruff_cache/, .codex_tmp/, out/, graphify-out/.
  Reason: candidate noise, but still requires explicit target list.
  Rollback: future quarantine manifest with original path, hash/size metadata where safe, and restore procedure.
  Postcheck: rerun inventory and project validators.

- GATE_LEGACY_READONLY
  Target: operativa/archive/root-dirs/, operativa/archive/root-loose/, .bmad-backup/, workbooks/_backups/.
  Reason: historical evidence and backup retention needs owner decision.
  Rollback: preserve exact path map before any future move.
  Postcheck: readbacks still resolve and Git delta remains isolated.

- GATE_AGENT_SKILL_DUPLICATE
  Target: .agents/skills/agileagentcanvas-help/SKILL.md and .cursor/skills/agileagentcanvas-help/SKILL.md.
  Reason: duplicate skill bridge needs canonical owner decision.
  Rollback: keep both until canonical owner is selected.
  Postcheck: skill discovery resolves the chosen canonical path.

- BLOCKED_RUNTIME_AND_SENSITIVE
  Target: .env.local, .cabina/, node_modules/, reparse points, outputs/ceo-suite-test temp repos.
  Reason: sensitive/runtime/junction/nested repo boundaries.
  Rollback: no action permitted in G1.
  Postcheck: no action in G1.