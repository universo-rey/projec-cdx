from tools import sdu_intelligent_operation_layer as intelligence


def test_chain_missing_external_csv_is_warning() -> None:
    chain_result = {
        "status": "FAIL",
        "checks": [
            {"name": "chain_csv_exists", "status": "FAIL"},
            {"name": "schema_csv_exists", "status": "FAIL"},
            {"name": "atomic_matrix_exists", "status": "PASS"},
        ],
    }

    events = intelligence.build_chain_events(chain_result)

    assert len(events) == 1
    assert events[0]["id"] == "external_operational_chain_csv_missing"
    assert events[0]["gravedad"] == "WARNING"
    assert events[0]["sugerencia"]["requiere_confirmacion"] is True


def test_chain_canonized_external_csv_is_info() -> None:
    chain_result = {
        "status": "WARNING_CANONIZED",
        "checks": [
            {"name": "chain_csv_exists", "status": "WARNING_CANONIZED"},
            {"name": "schema_csv_exists", "status": "WARNING_CANONIZED"},
            {"name": "operational_chain_fallback", "status": "WARNING_CANONIZED"},
        ],
    }

    events = intelligence.build_chain_events(chain_result)

    assert len(events) == 1
    assert events[0]["id"] == "external_operational_chain_csv_canonized"
    assert events[0]["gravedad"] == "INFO"
    assert events[0]["sugerencia"]["requiere_confirmacion"] is False


def test_chain_non_external_failure_is_critical() -> None:
    chain_result = {
        "status": "FAIL",
        "checks": [
            {"name": "required_values", "status": "FAIL"},
        ],
    }

    events = intelligence.build_chain_events(chain_result)

    assert events[0]["id"] == "operational_chain_contract_failure"
    assert events[0]["gravedad"] == "CRITICAL"


def test_priority_orders_by_risk_impact_recurrence() -> None:
    events = [
        intelligence.make_event(
            event_id="info",
            fuente="repo",
            problema="Estado estable.",
            gravedad="INFO",
            accion_sugerida="Continuar.",
            impacto=1,
            urgencia=1,
        ),
        intelligence.make_event(
            event_id="critical",
            fuente="ci",
            problema="CI failed.",
            gravedad="CRITICAL",
            accion_sugerida="Bloquear release.",
            impacto=9,
            urgencia=9,
        ),
    ]

    ordered = intelligence.sort_events(events)

    assert [event["id"] for event in ordered] == ["critical", "info"]
