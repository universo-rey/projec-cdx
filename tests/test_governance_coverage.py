import csv
import tempfile
import unittest
from pathlib import Path

from tools.validate_governance_coverage import validate

FIELDS = [
    "artifact_class",
    "required_index",
    "required_validator",
    "owner_agent",
    "coverage_status",
    "execution_mode",
    "stop_condition",
]


def _csv(path: Path, fields: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def _workflow_registry(root: Path, content: str) -> Path:
    workflow = root / ".github/workflows/approved.yml"
    workflow.parent.mkdir(parents=True)
    workflow.write_text(content, encoding="utf-8")
    registry = root / "workflows.csv"
    _csv(
        registry,
        ["workflow_id", "path", "status"],
        [
            {
                "workflow_id": "approved",
                "path": ".github/workflows/approved.yml",
                "status": "APPROVED_GITHUB_ACTIONS_SURFACE",
            }
        ],
    )
    return registry


def _rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


class GovernanceCoverageTests(unittest.TestCase):
    def _coverage(self, root: Path, mode: str, status: str = "covered") -> Path:
        coverage = root / "coverage.csv"
        _csv(
            coverage,
            FIELDS,
            [
                {
                    "artifact_class": "critical",
                    "required_index": "coverage.csv",
                    "required_validator": "tools/validator.py",
                    "owner_agent": "test",
                    "coverage_status": status,
                    "execution_mode": mode,
                    "stop_condition": "validator_unreachable",
                }
            ],
        )
        return coverage

    def test_rejects_ci_validator_present_but_not_reachable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            validator = root / "tools/validator.py"
            validator.parent.mkdir()
            validator.write_text("print('ok')\n", encoding="utf-8")
            errors = validate(
                root,
                self._coverage(root, "ci"),
                _workflow_registry(root, "run: python -m tools.other\n"),
            )
            self.assertTrue(any("not reachable" in error for error in errors))

    def test_accepts_ci_validator_reachable_from_approved_workflow(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            validator = root / "tools/validator.py"
            validator.parent.mkdir()
            validator.write_text("print('ok')\n", encoding="utf-8")
            errors = validate(
                root,
                self._coverage(root, "ci"),
                _workflow_registry(
                    root,
                    "jobs:\n  test:\n    steps:\n      - run: python tools/validator.py\n",
                ),
            )
            self.assertEqual(errors, [])

    def test_rejects_ci_validator_only_mentioned_outside_run(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            validator = root / "tools/validator.py"
            validator.parent.mkdir()
            validator.write_text("print('ok')\n", encoding="utf-8")
            workflow = "name: test\njobs:\n  test:\n    steps:\n      - name: tools/validator.py\n        env:\n          VALIDATOR: tools/validator.py\n        run: python -m tools.other\n"
            errors = validate(
                root,
                self._coverage(root, "ci"),
                _workflow_registry(root, workflow),
            )
            self.assertTrue(any("not reachable" in error for error in errors))

    def test_rejects_historical_validator_claiming_current_coverage(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            errors = validate(
                root, self._coverage(root, "historical"), _workflow_registry(root, "run: true\n")
            )
            self.assertTrue(any("requires coverage_status=historical" in error for error in errors))

    def test_rejects_active_row_without_validator(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            coverage = self._coverage(root, "manual")
            rows = _rows(coverage)
            rows[0]["required_validator"] = ""
            _csv(coverage, FIELDS, rows)
            errors = validate(root, coverage, _workflow_registry(root, "jobs: {}\n"))
            self.assertTrue(any("lacks required_validator" in error for error in errors))

    def test_rejects_active_row_with_missing_index(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            validator = root / "tools/validator.py"
            validator.parent.mkdir()
            validator.write_text("print('ok')\n", encoding="utf-8")
            coverage = self._coverage(root, "manual")
            rows = _rows(coverage)
            rows[0]["required_index"] = "missing.csv"
            _csv(coverage, FIELDS, rows)
            errors = validate(root, coverage, _workflow_registry(root, "jobs: {}\n"))
            self.assertTrue(any("active index is absent" in error for error in errors))

    def test_rejects_active_mode_with_historical_status(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            errors = validate(
                root,
                self._coverage(root, "manual", "historical"),
                _workflow_registry(root, "jobs: {}\n"),
            )
            self.assertTrue(any("requires coverage_status=covered" in error for error in errors))

    def test_rejects_nested_validator_only_mentioned_as_data(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            validator = root / "tools/validator.py"
            validator.parent.mkdir()
            validator.write_text("print('ok')\n", encoding="utf-8")
            (root / "tools/catalog.py").write_text('VALIDATOR = "validator.py"\n', encoding="utf-8")
            errors = validate(
                root,
                self._coverage(root, "nested"),
                _workflow_registry(root, "jobs: {}\n"),
            )
            self.assertTrue(any("no repo-local caller" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
