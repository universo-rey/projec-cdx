# Recipe: baseline differential dependency validation

## Purpose

Classify a dependency-only candidate without converting pre-existing repository debt into a false regression or a false green. The recipe consumes an immutable local evidence packet and compares the same commands on an exact base and head. It never installs dependencies, executes the recorded commands, calls GitHub, or changes repository state.

## Owner and boundary

- Owner: `court.seshat_evidence`
- Reviewer: `court.thot_schema`
- Mode: `READ_ONLY`
- Allowed surface: local repository objects, an allowlisted dependency-file diff, and one local JSON evidence packet.
- Blocked: network installation, GitHub writes, merge, close, rebase, autofix, lock regeneration, secrets, Microsoft live, production, and any mutation.

## Required immutable inputs

1. Exact repository slug and local repo root.
2. Exact 40-character base and head commit IDs present locally.
3. Exact original PR number and evidence that its state was preserved.
4. Exact dependency-file allowlist; the complete `base..head` diff must be contained in it.
5. One JSON evidence packet with the same repository, base, head, original PR, allowlist, and paired results.
6. For every changed file, a SHA-256 of the file bytes at the checked-out head. A domain `global_hash` is separate metadata and must never substitute for this byte hash.

## Evidence packet contract

```json
{
  "schema_version": "1.0",
  "repository": "owner/repo",
  "base_sha": "40 hex characters",
  "head_sha": "40 hex characters",
  "original_pr": {
    "number": 31,
    "state_before": "OPEN",
    "state_after": "OPEN",
    "preserved": true,
    "rebase_performed": false,
    "close_performed": false
  },
  "allowed_dependency_paths": ["package.json", "package-lock.json"],
  "commands": [
    {
      "id": "root-build",
      "command": "recorded command; not executed by this validator",
      "baseline": {"status": "PASS", "exit_code": 0, "normalized_fingerprint": "PASS"},
      "head": {"status": "PASS", "exit_code": 0, "normalized_fingerprint": "PASS"},
      "harness_defect": false
    }
  ],
  "file_hashes": [
    {
      "path": "package.json",
      "file_sha256": "64 hex characters",
      "domain_global_hash": null,
      "hash_semantics": "FILE_BYTES_SHA256_NOT_DOMAIN_GLOBAL_HASH"
    }
  ],
  "decision": "COMPATIBLE",
  "network_install_attempts": 0,
  "github_write_count": 0,
  "secret_hits": 0
}
```

## Deterministic classification

Apply precedence in this order:

1. `INSUFFICIENT_EVIDENCE`: an identity, commit, allowlist, paired result, fingerprint, original-PR preservation assertion, or byte hash is missing or inconsistent.
2. `REGRESSION_INTRODUCED`: any baseline result passes while its head counterpart fails, or both fail with different normalized fingerprints without a proven harness defect.
3. `HARNESS_DEFECT`: no regression exists and at least one matching base/head failure is explicitly traced to the harness.
4. `BASELINE_DEBT_REPRODUCED`: no regression or harness defect exists and at least one base/head pair fails with the same non-empty normalized fingerprint.
5. `COMPATIBLE`: every head result passes and all required evidence is complete.

The declared decision must equal the validator's derived decision.

## Invocation

```powershell
pwsh -NoProfile -File .agents/codex/tools/local_validate_baseline_differential_dependency.ps1 `
  -RepoRoot <clean-local-repo> `
  -EvidencePath <local-evidence.json> `
  -ExpectedRepository owner/repo `
  -ExpectedBaseSha <base-sha> `
  -ExpectedHeadSha <head-sha> `
  -ExpectedOriginalPr 31 `
  -AllowedDependencyPath package.json,package-lock.json
```

## Stop conditions

- `baseline_differential_identity_mismatch`
- `baseline_differential_scope_drift`
- `baseline_differential_evidence_incomplete`
- `baseline_differential_hash_semantics_invalid`
- `baseline_differential_original_pr_not_preserved`
- `secret_detected`

## Output

Parseable JSON containing `status`, `decision`, exact base/head, changed paths, error count, secret hits, and mutation counters. `PASS` means the evidence packet is internally consistent and locally reproducible; it does not authorize merge, close, rebase, autofix, lock regeneration, or any remote write.
