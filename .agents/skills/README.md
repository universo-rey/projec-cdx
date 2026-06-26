# Cabina Skills Root

This folder is the repo-local portable skill root for the C root.

Use it for skills that must travel with `universo-rey/cabina-universal-d`.
The governance catalog, assignments and source references remain under
`.agents\codex\skills` and related matrices.

Storage rule:

- `.agents\skills\<skill>\SKILL.md`: executable skill instruction package.
- `.agents\codex\skills`: catalog, source references and subskill matrices.
- Machine-global roots such as `C:\Users\enzo1\.agents\skills` are runtime
  installs, not the durable repo source for this cabina.

Metadata rule:

- each repo-local `SKILL.md` must declare an activable `description`, trigger
  boundary, allowed actions, blocked actions and validator section.
- quality metadata is tracked in
  `.agents\codex\skills\SKILL_METADATA_QUALITY_MATRIX.csv`.
- validate with
  `.agents\codex\tools\local_validate_skill_metadata.ps1`.

See [MATRIZ_OPERATIVA.md](MATRIZ_OPERATIVA.md) for the 3-step mirror.
