from __future__ import annotations

import json

import pytest

pytest.importorskip("openpyxl")

from tools.update_codex_config_workbook import load_json_file, read_json_obj


def test_workbook_json_helpers_accept_utf8_sig(tmp_path) -> None:
    path = tmp_path / "dataverse-live-read.json"
    path.write_text("\ufeff" + json.dumps({"pairs": [{"label": "sdu"}]}), encoding="utf-8")

    assert read_json_obj(path)["pairs"][0]["label"] == "sdu"
    assert load_json_file(path)["pairs"][0]["label"] == "sdu"
