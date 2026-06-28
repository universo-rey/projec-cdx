from __future__ import annotations

from pathlib import Path

from projec_cdx_cloud import runtime


def test_build_noc_system_summary_synthesizes_read_only_view() -> None:
    sdu_state = {"health": {"status": "YELLOW"}}
    noc_state = {
        "status": "NOC_OPERATIONAL",
        "entrypoint_observability": {
            "current_cwd": "C:/CEO/project-cdx",
            "status": "CANONICAL",
        },
        "governance": {
            "multirepo": {
                "readiness": "READY",
                "validation": {"decision": "PASS"},
            }
        },
        "last_run": {"mode": "WATCHDOG_RUN"},
    }
    intelligence_state = {
        "status": "NOC_INTELLIGENCE_ACTIVE",
        "generated_at": "2026-06-26T18:01:19.094672Z",
        "alerts_detected": 1,
        "anomalies_detected": 2,
    }

    summary = runtime.build_noc_system_summary(sdu_state, noc_state, intelligence_state)

    assert summary["title"] == "SDU System Summary"
    assert summary["status"] == "WARN"
    assert summary["entrypoint"]["cwd"] == "C:/CEO/project-cdx"
    assert summary["entrypoint"]["status"] == "canonical"
    assert summary["coordinator"]["state"] == "idle"
    assert summary["multirepo"]["decision"] == "PASS"
    assert summary["intelligence"]["last_run"] == "2026-06-26T18:01:19.094672Z"
    assert "alerts_detected:1" in summary["intelligence"]["changes_detected"]
    assert len(summary["summary_lines"]) == 5
    assert summary["headline"] == "WARN. Entry: Canonical. Coord: Idle. Repo: Ready. Drift: Alert."
    assert summary["headline"].count(".") == 5
    assert all(len(segment.split()) <= 3 for segment in summary["headline"].split(". ") if segment)


def test_build_noc_system_summary_uses_error_and_action_tokens() -> None:
    sdu_state = {"health": {"status": "RED"}}
    noc_state = {
        "status": "NOC_DEGRADED",
        "entrypoint_observability": {
            "current_cwd": "C:/CEO/project-cdx",
            "status": "DEGRADED",
        },
        "governance": {
            "multirepo": {
                "readiness": "DEFERRED",
                "validation": {"decision": "FAIL"},
            }
        },
        "last_run": {"mode": "PLAN"},
    }
    intelligence_state = {
        "status": "NOC_INTELLIGENCE_ACTIVE",
        "anomalies_detected": 2,
    }

    summary = runtime.build_noc_system_summary(sdu_state, noc_state, intelligence_state)

    assert summary["status"] == "CRITICAL"
    assert (
        summary["headline"] == "ERR. Entry: Degraded. Coord: Plan. Repo: Blocked. Drift: Anomaly."
    )


def test_build_noc_system_summary_elevates_untrusted_readback() -> None:
    sdu_state = {"health": {"status": "GREEN"}}
    noc_state = {
        "status": "NOC_OPERATIONAL",
        "entrypoint_observability": {
            "current_cwd": "C:/CEO/project-cdx",
            "status": "CANONICAL",
        },
        "governance": {
            "multirepo": {
                "readiness": "READY",
                "validation": {"decision": "PASS"},
            }
        },
        "last_run": {"mode": "WATCHDOG_RUN"},
        "readback": {
            "READBACK_UNTRUSTED": True,
            "READBACK_PARTIAL_DETAILS": True,
            "GRAPH_ACCESS": "DEGRADED",
            "absence_means_absence": False,
        },
    }
    intelligence_state = {"status": "NOC_INTELLIGENCE_ACTIVE"}

    summary = runtime.build_noc_system_summary(sdu_state, noc_state, intelligence_state)

    assert summary["status"] == "CRITICAL"
    assert summary["readback"]["status"] == "UNTRUSTED"
    assert summary["readback"]["graph_access"] == "DEGRADED"
    assert summary["headline"].endswith("Readback: Untrusted.")
    assert "Readback Untrusted." in summary["summary_lines"][-1]


def test_latest_intelligence_json_fallback_prefers_latest_file(monkeypatch, tmp_path) -> None:
    latest = tmp_path / "latest.json"
    latest.write_text('{"status":"GREEN","generated_at":"2026-06-27T00:00:00Z"}', encoding="utf-8")
    fallback = tmp_path / "fallback.json"
    fallback.write_text(
        '{"status":"CRITICAL","generated_at":"2026-06-26T00:00:00Z"}', encoding="utf-8"
    )

    payload = runtime._latest_existing_json([Path("missing.json"), latest, fallback])

    assert payload["status"] == "GREEN"
    assert payload["generated_at"] == "2026-06-27T00:00:00Z"
