from __future__ import annotations

import argparse
import json
import sys
import time
from datetime import date, timedelta

import httpx


def _sample_payload() -> dict:
    stamp = int(time.time())
    return {
        "product_brief": (
            f"Smoke test {stamp}: Launch Desk should help engineering teams plan a small internal "
            "release with owners, risks, and launch copy."
        ),
        "audience": "engineering leads and release owners",
        "launch_date": (date.today() + timedelta(days=14)).isoformat(),
        "constraints": ["security review before launch", "no customer-facing downtime"],
        "assets": ["draft release notes", "internal FAQ outline"],
        "desired_channels": ["Slack", "Email", "Release notes"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify Launch Desk streamed API end to end.")
    parser.add_argument("--url", default="http://127.0.0.1:8000/api/launch-plan/stream")
    parser.add_argument("--timeout", type=float, default=120.0)
    args = parser.parse_args()

    seen_tool = False
    seen_text = False
    seen_final = False
    request_id = None
    model = None

    with httpx.stream(
        "POST",
        args.url,
        json=_sample_payload(),
        headers={"Accept": "application/x-ndjson"},
        timeout=args.timeout,
    ) as response:
        response.raise_for_status()
        for line in response.iter_lines():
            if not line:
                continue
            event = json.loads(line)
            if event.get("type") == "run_started":
                request_id = event.get("request_id")
                model = event.get("model")
            if event.get("event_name") == "tool_progress":
                seen_tool = True
            if event.get("type") == "text_delta":
                seen_text = True
            if event.get("type") == "final":
                seen_final = True
            if event.get("type") == "error":
                raise RuntimeError(event.get("message", "Launch Desk stream returned an error event."))

    summary = {
        "request_id": request_id,
        "model": model,
        "seen_tool_progress": seen_tool,
        "seen_text_delta": seen_text,
        "seen_final": seen_final,
    }
    print(json.dumps(summary, indent=2))

    if not (seen_tool and seen_text and seen_final):
        print("Stream verification failed: required event types were not all observed.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
