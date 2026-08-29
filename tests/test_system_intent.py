from projec_cdx_cloud.system_intent import build_system_intent_response


def _current_state():
    return {
        "NEXT_SYSTEM_ACTION": "FALLBACK_SYSTEM_ACTION",
        "NEXT_BUSINESS_ACTION": "FALLBACK_BUSINESS_ACTION",
        "visible_operation": {
            "order_id": "local-artifact:CURRENT-WEB-EXPOSURE",
            "correlation_id": "SYSTEM-SCHEDULED-20260822-180000-180000",
            "parent_correlation_id": "SYSTEM-SCHEDULED-20260822-180000-180000",
            "child_correlation_id": "THREAD-3-SYSTEM-SCHEDULED-20260822-180000-180000-NOC-PROJECTOR",
            "projection_run_id": "projection-run-001",
            "system_cursor": "NOC_VISIBLE_PROJECTION_CURRENT",
            "business_cursor": "WEB_EXPOSURE_READY",
            "next_system_action": "CONTINUE_CURRENT_WEB_EXPOSURE",
            "next_business_action": "EXPOSE_PRE_RESOLVED_INTENT_ROUTE",
            "return_flow": "D:/",
            "federated_primary_binding": {
                "execution_primary": "watchdog_operator",
                "lock_key": "lock.primary.local_runtime.test",
                "fanin_target": "NOC->AAC->D:/",
                "return_target": "D:/",
            },
            "intent_profile_routing": {
                "status": "FUNCTIONAL_TECHNICAL_PROFILE_RESOLVED",
                "functional_profile": "SDU-DOCUMENT-CHAIN",
                "primary_profile": "SDU-DOCUMENT-CHAIN",
                "participating_profiles": ["SDU-DOCUMENT-CHAIN"],
                "participating_profile_bindings": [
                    {
                        "profile": "SDU-DOCUMENT-CHAIN",
                        "priority": 1000,
                        "matched_terms": ["document chain"],
                        "technical_profile": "SDU-FEDERAL-CONTROL",
                        "workspace": "C:/CEO/sdu-control-plane/12_WORKSPACES/SDU_DOCUMENT_CHAIN.code-workspace",
                        "open_command": "Open-SDUProfileDocumentChain",
                        "default_recipe": "recipe.sdu.docs.readback.chain",
                        "capabilities": ["readbacks", "document_chain"],
                        "blocked_capabilities": ["graph_write"],
                        "gates_required": [],
                        "do_not_use_when": ["external-write"],
                        "unpublished_internal_field": "must-not-leak",
                    }
                ],
                "participating_technical_profiles": ["SDU-FEDERAL-CONTROL"],
                "participating_workspaces": [
                    "C:/CEO/sdu-control-plane/12_WORKSPACES/SDU_DOCUMENT_CHAIN.code-workspace"
                ],
                "composition_mode": "SINGLE_PROFILE",
                "conflicts": [],
                "technical_profile": "SDU-FEDERAL-CONTROL",
                "functional_workspace": "C:/CEO/sdu-control-plane/12_WORKSPACES/SDU_DOCUMENT_CHAIN.code-workspace",
                "open_command": "Open-SDUProfileDocumentChain",
                "default_recipe": "recipe.sdu.docs.readback.chain",
                "matched_terms": [],
                "excluded_terms": [],
                "intent_semantics": "REQUESTED_CAPABILITY_MATCHES__MENTIONED_OR_EXCLUDED_CAPABILITY_DOES_NOT_ROUTE",
                "selection_source": "V42_EXACT_ROUTE",
                "launch_allowed": True,
                "external_write_allowed": False,
                "router": "C:/CEO/sdu-control-plane/16_CAPABILITY_AUTOPILOT/INTENT_PROFILE_ROUTER.json",
                "profile_matrix": "C:/CEO/sdu-control-plane/15_INSIDERS_PROFILES/INSIDERS_PROFILE_MATRIX.json",
                "capability_matrix": "C:/CEO/sdu-control-plane/16_CAPABILITY_AUTOPILOT/CAPABILITY_ROUTING_MATRIX.json",
            },
        },
    }


def test_projects_current_v42_route_without_reimplementing_routing():
    result = build_system_intent_response(
        _current_state(), requested_intent="mantener la corte viva"
    )

    assert result["schema_version"] == "sdu.system_intent.web.v1"
    assert result["resolution_mode"] == "PRE_RESOLVED_V42_PROJECTION"
    assert result["route_available"] is True
    assert result["requested_intent"] == "mantener la corte viva"
    assert result["requested_intent_routed_by_adapter"] is False
    assert result["primary_profile"] == "SDU-DOCUMENT-CHAIN"
    assert result["technical_profile"] == "SDU-FEDERAL-CONTROL"
    assert result["selection_source"] == "V42_EXACT_ROUTE"
    assert result["open_command"] == "Open-SDUProfileDocumentChain"
    assert result["launch_allowed"] is True
    assert result["external_write_allowed"] is False
    assert result["mutates"] is False
    assert result["external_write_performed"] is False

    binding = result["participating_profile_bindings"][0]
    assert binding["capabilities"] == ["readbacks", "document_chain"]
    assert "unpublished_internal_field" not in binding

    current = result["current"]
    assert current["execution_primary"] == "watchdog_operator"
    assert current["fanin_target"] == "NOC->AAC->D:/"
    assert current["correlation_id"] == "SYSTEM-SCHEDULED-20260822-180000-180000"
    assert current["projection_run_id"] == "projection-run-001"


def test_fails_closed_when_current_routing_is_missing():
    result = build_system_intent_response(
        {
            "visible_operation": {
                "correlation_id": "SYSTEM-SCHEDULED-20260822-190000-190000",
                "return_flow": "D:/",
            }
        },
        requested_intent="unknown task",
    )

    assert result["status"] == "ROUTING_NOT_AVAILABLE"
    assert result["route_available"] is False
    assert result["launch_allowed"] is False
    assert result["external_write_allowed"] is False
    assert result["requested_intent_routed_by_adapter"] is False
    assert result["mutates"] is False
    assert result["external_write_performed"] is False
    assert result["current"]["return_target"] == "D:/"


def test_top_level_current_route_is_supported_as_non_historical_fallback():
    result = build_system_intent_response(
        {
            "intent_profile_routing": {
                "status": "FUNCTIONAL_TECHNICAL_PROFILE_RESOLVED",
                "primary_profile": "SDU-CODEX-LOCAL",
                "selection_source": "V42_EXACT_ROUTE",
                "launch_allowed": True,
                "external_write_allowed": False,
            }
        }
    )

    assert result["route_available"] is True
    assert result["primary_profile"] == "SDU-CODEX-LOCAL"
    assert result["selection_source"] == "V42_EXACT_ROUTE"


def test_explicit_empty_visible_route_does_not_reuse_stale_top_level_route():
    result = build_system_intent_response(
        {
            "visible_operation": {
                "correlation_id": "SYSTEM-SCHEDULED-20260829-CURRENT",
                "intent_profile_routing": {},
            },
            "intent_profile_routing": {
                "status": "FUNCTIONAL_TECHNICAL_PROFILE_RESOLVED",
                "primary_profile": "STALE-PROFILE",
                "selection_source": "PRIOR_V42_ROUTE",
                "launch_allowed": True,
                "external_write_allowed": False,
            },
        }
    )

    assert result["route_available"] is False
    assert result["status"] == "ROUTING_NOT_AVAILABLE"
    assert result["launch_allowed"] is False
    assert result["current"]["correlation_id"] == "SYSTEM-SCHEDULED-20260829-CURRENT"
    assert "primary_profile" not in result
