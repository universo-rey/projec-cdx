from __future__ import annotations

import json
from pathlib import Path

from metadata.audit_compare import compare_audit_reports


def test_compare_audit_reports_detects_elevation_and_env_drift() -> None:
    left = {
        "computer": {"elevated": False},
        "environment": {"codex": [{"Name": "CODEX_HOME", "Value": "C:/Users/enzo1/.codex"}]},
        "powershell": {"psversiontable": {"PSVersion": {"Major": 7, "Minor": 6, "Patch": 2}}},
    }
    right = {
        "computer": {"elevated": True},
        "environment": {
            "codex": [
                {"Name": "CODEX_HOME", "Value": "C:/Users/enzo1/.codex"},
                {"Name": "CODEX_PROJECT_ROOT", "Value": "C:/CEO/project-cdx"},
            ]
        },
        "powershell": {"psversiontable": {"PSVersion": {"Major": 7, "Minor": 6, "Patch": 2}}},
    }

    diff = compare_audit_reports(left, right)

    assert "powershell" in diff["summary"]["identical_sections"]
    assert "computer" in diff["summary"]["changed_sections"]
    assert "elevation_mismatch" in diff["summary"]["focus_flags"]
    assert diff["differences"][0]["section"] == "computer"


def test_compare_cli_writes_json(tmp_path: Path) -> None:
    left = tmp_path / "left.json"
    right = tmp_path / "right.json"
    output = tmp_path / "diff.json"
    left.write_text(json.dumps({"computer": {"elevated": False}}), encoding="utf-8")
    right.write_text(json.dumps({"computer": {"elevated": True}}), encoding="utf-8")

    from metadata.audit_compare import main

    exit_code = main(["--left", str(left), "--right", str(right), "--output", str(output)])

    assert exit_code == 0
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["summary"]["focus_flags"] == ["elevation_mismatch"]
