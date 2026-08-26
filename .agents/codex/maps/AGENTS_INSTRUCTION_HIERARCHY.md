# AGENTS Instruction Hierarchy

## Effective Canonical Root

The effective repo-local root is the current `project-cdx` checkout or worktree supplied as `RepoRoot`. No fixed workstation checkout is canonical for validation.

## Precedence

1. Explicit human instruction within its authorized scope.
2. The nearest applicable `AGENTS.md`.
3. `.agents/codex/README.md` and the repo-local agent and routing registries.
4. Triggered repo-local skills and selected recipes.
5. Tool registries, generated evidence, and readbacks.

Lower layers refine higher layers but cannot expand authority.

## Contradiction Rule

Stop when a lower-precedence surface conflicts with human scope or `AGENTS.md`. Do not resolve authority, target, secrets, permissions, production, or external writes by inference.

## Nested Surface Policy

Adjacent worktrees and nested repositories retain their own repository, branch, validation, evidence, and promotion paths. Never absorb, move, or delete a nested repository or its branch from this hierarchy.

## Repo-local Surfaces

- `AGENTS.md`
- `.agents/codex/README.md`
- `.agents/codex/agents.json`
- `.agents/codex/routing.json`
- `.agents/skills/*/SKILL.md`
- `.agents/codex/recipes/RECIPE_INDEX.csv`
- `.agents/codex/tools/TOOL_INDEX.csv`

## Validation

Run `.agents/codex/tools/local_validate_agents_instruction_hierarchy.ps1` with explicit `-Root` and `-RepoRoot` for the current checkout. Companion validation is `.agents/codex/tools/local_validate_operational_chain.ps1` with the same exact root.
