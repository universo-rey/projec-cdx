from __future__ import annotations

from collections.abc import Mapping
from typing import Any

SCHEMA_VERSION = "sdu.system_intent.web.v1"
RESOLUTION_MODE = "PRE_RESOLVED_V42_PROJECTION"

_BINDING_FIELDS = (
    "profile",
    "priority",
    "matched_terms",
    "technical_profile",
    "workspace",
    "open_command",
    "default_recipe",
    "capabilities",
    "blocked_capabilities",
    "gates_required",
    "do_not_use_when",
)


def _mapping(value: Any) -> dict[str, Any]:
    if isinstance(value, Mapping):
        return dict(value)
    return {}


def _drop_none(values: Mapping[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in values.items() if value is not None}


def extract_current_intent_routing(system_state: Mapping[str, Any]) -> dict[str, Any]:
    """Return the current pre-resolved routing projection."""

    state = _mapping(system_state)
    visible_operation = _mapping(state.get("visible_operation"))

    if "intent_profile_routing" in visible_operation:
        return _mapping(visible_operation.get("intent_profile_routing"))

    routing = _mapping(state.get("intent_profile_routing"))
    if routing:
        return routing

    return {}


def _project_bindings(value: Any) -> list[dict[str, Any]]:
    if not isinstance(value, list):
        return []

    projected: list[dict[str, Any]] = []
    for item in value:
        binding = _mapping(item)
        if not binding:
            continue

        selected = {field: binding.get(field) for field in _BINDING_FIELDS}
        projected.append(_drop_none(selected))

    return projected


def _current_operation_context(system_state: Mapping[str, Any]) -> dict[str, Any]:
    state = _mapping(system_state)
    visible = _mapping(state.get("visible_operation"))
    primary = _mapping(visible.get("federated_primary_binding"))

    values = {
        "order_id": visible.get("order_id"),
        "correlation_id": (visible.get("correlation_id") or visible.get("visible_correlation_id")),
        "parent_correlation_id": visible.get("parent_correlation_id"),
        "child_correlation_id": visible.get("child_correlation_id"),
        "projection_run_id": visible.get("projection_run_id"),
        "system_cursor": visible.get("system_cursor"),
        "business_cursor": visible.get("business_cursor"),
        "next_system_action": (
            visible.get("next_system_action") or state.get("NEXT_SYSTEM_ACTION")
        ),
        "next_business_action": (
            visible.get("next_business_action") or state.get("NEXT_BUSINESS_ACTION")
        ),
        "execution_primary": primary.get("execution_primary"),
        "lock_key": primary.get("lock_key"),
        "fanin_target": primary.get("fanin_target") or visible.get("return_flow"),
        "return_target": primary.get("return_target") or visible.get("return_flow"),
    }
    return _drop_none(values)


def _base_response(requested_intent: str | None, current: Mapping[str, Any]) -> dict[str, Any]:
    return _drop_none(
        {
            "schema_version": SCHEMA_VERSION,
            "requested_intent": requested_intent,
            "requested_intent_routed_by_adapter": False,
            "resolution_mode": RESOLUTION_MODE,
            "mutates": False,
            "external_write_performed": False,
            "current": dict(current),
        }
    )


def build_system_intent_response(
    system_state: Mapping[str, Any], *, requested_intent: str | None = None
) -> dict[str, Any]:
    """Project the current BONTEMPS/V42 route into a web contract.

    The adapter never performs intent routing. It exposes the route already
    resolved by the local control plane and keeps requested intent as trace
    context only.
    """

    routing = extract_current_intent_routing(system_state)
    current = _current_operation_context(system_state)
    response = _base_response(requested_intent, current)

    if not routing:
        response.update(
            {
                "status": "ROUTING_NOT_AVAILABLE",
                "route_available": False,
                "launch_allowed": False,
                "external_write_allowed": False,
            }
        )
        return response

    status = routing.get("status")
    if not status:
        status = "FUNCTIONAL_TECHNICAL_PROFILE_RESOLVED"

    response.update(
        {
            "status": status,
            "route_available": True,
            "functional_profile": routing.get("functional_profile"),
            "primary_profile": routing.get("primary_profile"),
            "participating_profiles": routing.get("participating_profiles") or [],
            "participating_profile_bindings": _project_bindings(
                routing.get("participating_profile_bindings")
            ),
            "participating_technical_profiles": (
                routing.get("participating_technical_profiles") or []
            ),
            "participating_workspaces": routing.get("participating_workspaces") or [],
            "composition_mode": routing.get("composition_mode"),
            "conflicts": routing.get("conflicts") or [],
            "technical_profile": routing.get("technical_profile"),
            "functional_workspace": routing.get("functional_workspace"),
            "open_command": routing.get("open_command"),
            "default_recipe": routing.get("default_recipe"),
            "matched_terms": routing.get("matched_terms") or [],
            "excluded_terms": routing.get("excluded_terms") or [],
            "intent_semantics": routing.get("intent_semantics"),
            "selection_source": routing.get("selection_source"),
            "launch_allowed": bool(routing.get("launch_allowed")),
            "external_write_allowed": bool(routing.get("external_write_allowed")),
            "router": routing.get("router"),
            "profile_matrix": routing.get("profile_matrix"),
            "capability_matrix": routing.get("capability_matrix"),
        }
    )
    return _drop_none(response)
