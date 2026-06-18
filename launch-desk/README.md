# Launch Desk

Launch Desk is a launch-planning app for engineering teams. It turns a rough launch brief into:

- a prioritized plan
- a risk register
- an owner checklist
- launch copy suggestions
- follow-up questions when the brief is still missing critical details

## Stack

- Backend: FastAPI + OpenAI Agents SDK
- Frontend: static HTML, CSS, and vanilla JavaScript
- Streaming: NDJSON over HTTP so the UI can update while the model is still working

## Setup

1. Make sure `OPENAI_API_KEY` is available, either in the shell or in `.env.local`.
2. Install the project dependencies:

```powershell
& 'C:\Users\enzo1\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -m pip install -e .
```

3. Start the backend:

```powershell
& 'C:\Users\enzo1\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -m launch_desk backend
```

4. Start the frontend:

```powershell
& 'C:\Users\enzo1\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -m launch_desk frontend
```

5. Open `http://127.0.0.1:3000`.

## Runtime options

- `LAUNCH_DESK_MODEL_PROFILE=quality|balanced|fast|nano` selects a model profile. The default is `quality`.
- `LAUNCH_DESK_MODEL=gpt-5.5` overrides the profile with an explicit model.
- `LAUNCH_DESK_RUN_TIMEOUT_SECONDS=90` caps agent runs so the API fails clearly instead of hanging.
- `LAUNCH_DESK_ENABLE_CACHE=1` reuses exact matching saved runs from local history. Set to `0` for forced fresh model calls.
- `LAUNCH_DESK_ENABLE_SDK_TOOLS=0` keeps local deterministic tool preflight as the default. Set to `1` when developing Agents SDK function-tool loops directly.

## Smoke verification

After both servers are running with a real `OPENAI_API_KEY`, verify the actual streamed agent route:

```powershell
& 'C:\Users\enzo1\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' launch-desk/scripts/smoke_launch_desk_stream.py
```

The script fails unless it observes at least one `tool_progress` event, one model `text_delta`, and one `final` event.

## Observability

- The Agents SDK traces are available server-side.
- The backend also logs request ids plus LLM and tool lifecycle events.

## Developer notes

- The frontend talks to `http://127.0.0.1:8000/api/launch-plan/stream`.
- The server emits `run_started`, `tool_progress`, `text_delta`, and `final` events.
- Exact repeated requests can emit `cache_hit` and return without a new model call when cache is enabled.
- Saved runs are written locally to `launch-desk/data/history.jsonl` by default and can be reviewed in the history panel or via `/api/history`.
- The history panel supports text search and verdict filtering, and the visible plan or any saved run can be exported as Markdown or JSON.
- Use the validation checklist in `launch-desk/VALIDATION.md` before calling the app done.
