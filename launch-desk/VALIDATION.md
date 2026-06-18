# Launch Desk validation checklist

## Integrated smoke 2026-06-18

- [x] Main branch smoke returned `status: prepared`.
- [x] `OPENAI_API_KEY` is present locally without exposing the secret value.
- [x] Agents SDK is installed as `openai-agents` version `0.17.5`.
- [x] SDK surface reports 6 SDU agents defined.
- [x] Launch Desk CLI is available with `backend`, `frontend`, and `dev` commands.
- [x] Gate remains `local-only`.

## Agent behavior

- [ ] The agent uses the brief, audience, launch date, constraints, and assets as inputs.
- [ ] The agent produces a prioritized plan.
- [ ] The agent produces a risk register.
- [ ] The agent produces an owner checklist.
- [ ] The agent produces channel-specific copy suggestions.
- [ ] The agent asks follow-up questions when key details are missing.

## Frontend flow

- [ ] The form loads in the browser.
- [ ] Submitting the form sends a POST to `/api/launch-plan/stream`.
- [ ] The streaming panel updates before the run ends.
- [ ] Cancel stops the active browser request and returns the UI to an idle state.
- [ ] API errors are shown in plain language instead of raw stack traces.
- [ ] The final plan renders into structured sections.
- [ ] Recent runs appear in the history panel and can be reopened.
- [ ] The history panel supports search and verdict filtering.
- [ ] The visible plan can be exported as Markdown without reopening it from history.
- [ ] The visible plan can be exported as JSON without reopening it from history.
- [ ] A saved run can be exported as Markdown.
- [ ] A saved run can be exported as JSON.
- [ ] The UI remains usable on a smaller window width.

## Tool outputs

- [ ] `extract_tasks_from_brief` returns a prioritized task set.
- [ ] `check_launch_readiness` returns a score, verdict, and rubric.
- [ ] `generate_owner_checklist` returns owners with concrete action lists.
- [ ] `draft_channel_copy` returns channel-specific copy.
- [ ] `identify_missing_details` returns blocking and non-blocking follow-up questions.

## End-to-end verification

- [ ] Backend runs with a real `OPENAI_API_KEY`.
- [ ] `/api/health` reports the active model and model profile.
- [ ] The streamed POST emits at least one `tool_progress` event.
- [ ] The streamed POST emits at least one `text_delta` event.
- [ ] The streamed POST ends with a `final` event containing the structured report.
- [ ] `launch-desk/scripts/smoke_launch_desk_stream.py` passes against the local backend.
- [ ] A saved run can be retrieved through `/api/history`.
- [ ] A saved run can be exported through `/api/history/{request_id}/export`.

## Quality, latency, reliability, and cost

- [ ] `LAUNCH_DESK_MODEL_PROFILE` can switch between quality, balanced, fast, and nano profiles.
- [ ] `LAUNCH_DESK_RUN_TIMEOUT_SECONDS` produces a clear timeout error when exceeded.
- [ ] Repeating an identical request with cache enabled returns a `cache_hit`.
- [ ] Setting `LAUNCH_DESK_ENABLE_CACHE=0` forces a fresh model call.
- [ ] Structured output validation rejects malformed reports during tests.
