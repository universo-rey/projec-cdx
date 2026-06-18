const API_BASE = "http://127.0.0.1:8000";

const form = document.getElementById("launch-form");
const statusCard = document.getElementById("status-card");
const streamLog = document.getElementById("stream-log");
const resultBody = document.getElementById("result-body");
const historyList = document.getElementById("history-list");
const historyQueryInput = document.getElementById("history-query");
const historyVerdictSelect = document.getElementById("history-verdict");
const streamPill = document.getElementById("stream-pill");
const scoreBadge = document.getElementById("score-badge");
const exportMarkdownButton = document.getElementById("export-markdown");
const exportJsonButton = document.getElementById("export-json");
const cancelRunButton = document.getElementById("cancel-run");
const loadSampleButton = document.getElementById("load-sample");
const resetButton = document.getElementById("reset-form");
const refreshHistoryButton = document.getElementById("refresh-history");

const fields = {
  productBrief: document.getElementById("product_brief"),
  audience: document.getElementById("audience"),
  launchDate: document.getElementById("launch_date"),
  constraints: document.getElementById("constraints"),
  assets: document.getElementById("assets"),
  desiredChannels: document.getElementById("desired_channels"),
};

const sample = {
  productBrief:
    "Launch Desk is a planning assistant for engineering teams. It should turn a rough launch idea into an actionable release plan, highlight risks, and draft channel-specific copy for the team to review.",
  audience: "Engineering leadership, product managers, support, and release owners",
  launchDate: nextWeekDate(),
  constraints:
    "No production downtime\nSecurity review required\nMarketing copy must be approved before public comms",
  assets:
    "Product screenshots\nInternal FAQ draft\nRelease notes outline\nLaunch timeline sketch",
  desiredChannels: "Slack, Email, Release notes",
};

function nextWeekDate() {
  const value = new Date();
  value.setDate(value.getDate() + 7);
  return value.toISOString().slice(0, 10);
}

function setStatus(label, title, copy) {
  statusCard.innerHTML = `
    <span class="status-label">${label}</span>
    <strong>${title}</strong>
    <p>${copy}</p>
  `;
}

function setPill(text) {
  streamPill.textContent = text;
}

function clearNode(node, fallbackText) {
  node.innerHTML = "";
  if (fallbackText) {
    const p = document.createElement("p");
    p.className = "stream-empty";
    p.textContent = fallbackText;
    node.appendChild(p);
  }
}

function splitMultiValue(value) {
  return value
    .split(/[\n,]/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function buildPayload() {
  return {
    product_brief: fields.productBrief.value.trim(),
    audience: fields.audience.value.trim(),
    launch_date: fields.launchDate.value || null,
    constraints: splitMultiValue(fields.constraints.value),
    assets: splitMultiValue(fields.assets.value),
    desired_channels: splitMultiValue(fields.desiredChannels.value),
  };
}

function renderStreamItem(title, body, tone = "") {
  const item = document.createElement("div");
  item.className = "stream-item";
  item.innerHTML = `
    <strong>${title}</strong>
    <p>${body}</p>
  `;
  streamLog.prepend(item);
}

function renderListSection(title, items) {
  const section = document.createElement("article");
  section.className = "result-section";
  section.innerHTML = `
    <h3>${title}</h3>
    <ul>
      ${items.map((item) => `<li>${item}</li>`).join("")}
    </ul>
  `;
  return section;
}

function renderKeyValueSection(title, rows) {
  const section = document.createElement("article");
  section.className = "result-section";
  section.innerHTML = `<h3>${title}</h3>`;
  const grid = document.createElement("div");
  grid.className = "result-grid";
  for (const row of rows) {
    const card = document.createElement("div");
    card.className = "stream-item";
    card.innerHTML = `
      <strong>${row.title}</strong>
      <p>${row.body}</p>
    `;
    grid.appendChild(card);
  }
  section.appendChild(grid);
  return section;
}

function renderFinalReport(report) {
  clearNode(resultBody);

  scoreBadge.textContent = `${report.readiness.score}%`;
  scoreBadge.className = "score-badge";
  if (report.readiness.verdict === "go") {
    scoreBadge.classList.add("good");
  } else if (report.readiness.verdict === "go_with_risks") {
    scoreBadge.classList.add("warn");
  } else {
    scoreBadge.classList.add("bad");
  }

  const summary = document.createElement("article");
  summary.className = "result-section";
  summary.innerHTML = `
    <h3>${report.title}</h3>
    <p>${report.summary}</p>
    <p class="muted">${report.next_action}</p>
  `;
  resultBody.appendChild(summary);

  resultBody.appendChild(
    renderListSection(
      "Prioritized plan",
      report.prioritized_plan.map(
        (step) =>
          `<strong>#${step.priority} ${step.owner}</strong>: ${step.action}<br /><span class="muted">${step.reason}</span>`
      )
    )
  );

  resultBody.appendChild(
    renderListSection(
      "Risk register",
      report.risk_register.map(
        (risk) =>
          `<strong>${risk.risk}</strong> <span class="muted">[${risk.severity}/${risk.likelihood}]</span><br />${risk.mitigation}<br /><span class="muted">Owner: ${risk.owner}</span>`
      )
    )
  );

  resultBody.appendChild(
    renderKeyValueSection(
      "Owner checklist",
      report.owner_checklist.map((item) => ({
        title: item.owner,
        body: item.checklist.map((entry) => `- ${entry}`).join("<br />"),
      }))
    )
  );

  resultBody.appendChild(
    renderListSection(
      "Launch copy suggestions",
      report.launch_copy_suggestions.map(
        (copy) =>
          `<strong>${copy.channel}</strong> <span class="muted">(${copy.tone})</span><br />${copy.draft}`
      )
    )
  );

  resultBody.appendChild(
    renderListSection(
      "Follow-up questions",
      report.follow_up_questions.map(
        (item) =>
          `<strong>${item.blocking ? "Blocking" : "Helpful"}:</strong> ${item.question}<br /><span class="muted">${item.why_it_matters}</span>`
      )
    )
  );

  const readiness = document.createElement("article");
  readiness.className = "result-section";
  readiness.innerHTML = `<h3>Readiness rubric</h3>`;
  readiness.appendChild(
    renderKeyValueSection(
      "Score details",
      report.readiness.rubric.map((item) => ({
        title: `${item.dimension} - ${item.status}`,
        body: item.notes,
      }))
    )
  );
  resultBody.appendChild(readiness);
}

function renderHistoryEmpty(message) {
  historyList.innerHTML = "";
  const p = document.createElement("p");
  p.className = "stream-empty";
  p.textContent = message;
  historyList.appendChild(p);
}

let historyState = [];
let activeHistoryId = null;
let historyReloadTimer = null;
let activeRunModel = null;
let pendingRequestPayload = null;
let currentExportRecord = null;
let activeRunController = null;

function syncExportButtons() {
  const enabled = Boolean(currentExportRecord || activeHistoryId);
  exportMarkdownButton.disabled = !enabled;
  exportJsonButton.disabled = !enabled;
}

function syncRunButtons(isRunning) {
  const submitButton = form.querySelector('button[type="submit"]');
  submitButton.disabled = isRunning;
  cancelRunButton.disabled = !isRunning;
}

function lineList(items, formatter = (item) => item) {
  return items && items.length ? items.map((item) => `- ${formatter(item)}`).join("\n") : "- None";
}

function renderRecordMarkdown(record) {
  const request = record.request || {};
  const report = record.report || {};
  const readiness = report.readiness || {};
  const lines = [
    `# ${report.title || "Launch plan"}`,
    "",
    `- Request ID: \`${record.request_id || ""}\``,
    `- Created at: \`${record.created_at || ""}\``,
    `- Model: \`${record.model || ""}\``,
    `- Audience: \`${request.audience || ""}\``,
  ];

  if (request.launch_date) {
    lines.push(`- Launch date: \`${request.launch_date}\``);
  }

  lines.push(
    "",
    "## Summary",
    "",
    report.summary || "No summary available.",
    "",
    "## Next Action",
    "",
    report.next_action || "No next action available.",
    "",
    "## Prioritized Plan",
    lineList(report.prioritized_plan || [], (step) => {
      const due = step.due ? ` Due: ${step.due}` : "";
      return `#${step.priority || "?"} ${step.owner || ""}: ${step.action || ""} (${step.reason || ""})${due}`;
    }),
    "",
    "## Risk Register",
    lineList(report.risk_register || [], (risk) => `${risk.risk || ""} [${risk.severity || ""}/${risk.likelihood || ""}] Owner: ${risk.owner || ""}. Mitigation: ${risk.mitigation || ""}`),
    "",
    "## Owner Checklist",
    lineList(report.owner_checklist || [], (item) => `${item.owner || ""}: ${(item.checklist || []).join("; ")}`),
    "",
    "## Launch Copy",
    lineList(report.launch_copy_suggestions || [], (copy) => `${copy.channel || ""} (${copy.tone || ""}): ${copy.draft || ""}`),
    "",
    "## Follow-up Questions",
    lineList(report.follow_up_questions || [], (item) => `${item.blocking ? "Blocking" : "Helpful"}: ${item.question || ""} (${item.why_it_matters || ""})`),
    "",
    "## Readiness",
    "",
    `- Score: \`${readiness.score ?? 0}\``,
    `- Verdict: \`${readiness.verdict || ""}\``,
    "",
    "### Top Gaps",
    lineList(readiness.top_gaps || []),
    "",
    "### Rubric",
    lineList(readiness.rubric || [], (item) => `${item.dimension || ""}: ${item.status || ""} - ${item.notes || ""}`),
    "",
    "## Assumptions",
    lineList(report.assumptions || [])
  );

  return `${lines.join("\n").trim()}\n`;
}

function renderHistoryItems(items, emptyMessage = "No runs saved yet. Finish a launch plan and it will appear here.") {
  historyState = items;
  historyList.innerHTML = "";

  if (!items.length) {
    renderHistoryEmpty(emptyMessage);
    return;
  }

  for (const item of items) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `history-item${item.request_id === activeHistoryId ? " active" : ""}`;
    button.innerHTML = `
      <strong>${item.title}</strong>
      <span class="muted">${item.created_at}</span>
      <span class="muted">Score ${item.score}% | ${item.verdict} | ${item.audience}</span>
      <span>${item.summary}</span>
    `;
    button.addEventListener("click", () => loadHistoryItem(item.request_id));
    historyList.appendChild(button);
  }
}

async function loadHistory(limit = 5) {
  try {
    const params = new URLSearchParams({ limit: String(limit) });
    const query = historyQueryInput.value.trim();
    const verdict = historyVerdictSelect.value;
    if (query) {
      params.set("query", query);
    }
    if (verdict && verdict !== "all") {
      params.set("verdict", verdict);
    }

    const response = await fetch(`${API_BASE}/api/history?${params.toString()}`);
    if (!response.ok) {
      throw new Error(`History request failed with ${response.status}`);
    }
    const data = await response.json();
    const hasFilters = Boolean(historyQueryInput.value.trim() || historyVerdictSelect.value !== "all");
    renderHistoryItems(
      data.items || [],
      hasFilters ? "No runs match the current filters." : undefined
    );
  } catch (error) {
    renderHistoryEmpty(`History could not load: ${error.message}`);
  }
}

async function loadHistoryItem(requestId) {
  try {
    const response = await fetch(`${API_BASE}/api/history/${requestId}`);
    if (!response.ok) {
      throw new Error(`History item request failed with ${response.status}`);
    }
    const record = await response.json();
    activeHistoryId = requestId;
    currentExportRecord = record;
    syncExportButtons();
    renderHistoryItems(historyState);
    renderFinalReport(record.report);
    setStatus("Loaded", "Past launch run opened", `Reviewing saved run ${requestId}.`);
    setPill("History");
  } catch (error) {
    setStatus("Blocked", "Could not load history item", error.message);
    renderStreamItem("Error", error.message, "bad");
  }
}

function appendStreamEvent(event) {
  if (event.type === "run_started") {
    activeRunModel = event.model || null;
    setStatus("Running", "Building the launch plan", "The agent is now working through the brief.");
    setPill("Running");
    renderStreamItem("Run started", `Request ${event.request_id} on ${event.model}`);
    return;
  }

  if (event.type === "event" && event.tool_progress) {
    return;
  }

  if (event.type === "event" && event.event_name === "tool_progress") {
    const detail = event.tool || "tool";
    renderStreamItem("Tool progress", `${event.phase} via ${detail}`, "warn");
    return;
  }

  if (event.type === "event" && event.event_name === "cache_hit") {
    renderStreamItem("Cache hit", "Loaded a matching saved launch plan from local history.", "good");
    return;
  }

  if (event.type === "text_delta") {
    renderStreamItem("Model text", event.delta || " ", "good");
    return;
  }

  if (event.type === "reasoning_delta") {
    renderStreamItem("Reasoning", event.delta || " ", "warn");
    return;
  }

  if (event.type === "final") {
    setPill("Done");
    setStatus("Done", "Launch plan ready", "The final structured report is on the right.");
    renderFinalReport(event.report);
    activeHistoryId = event.request_id || null;
    currentExportRecord = {
      request_id: event.request_id || "",
      created_at: event.created_at || new Date().toISOString(),
      model: event.model || activeRunModel || "",
      request: event.request || pendingRequestPayload || {},
      report: event.report,
    };
    syncExportButtons();
    loadHistory();
    return;
  }

  if (event.type === "error") {
    setPill("Error");
    setStatus("Blocked", "The run hit an error", event.message);
    renderStreamItem("Error", event.message, "bad");
  }
}

async function readNdjsonStream(response) {
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  while (true) {
    const { value, done } = await reader.read();
    if (done) {
      break;
    }
    buffer += decoder.decode(value, { stream: true });
    let newlineIndex = buffer.indexOf("\n");
    while (newlineIndex >= 0) {
      const line = buffer.slice(0, newlineIndex).trim();
      buffer = buffer.slice(newlineIndex + 1);
      if (line) {
        appendStreamEvent(JSON.parse(line));
      }
      newlineIndex = buffer.indexOf("\n");
    }
  }

  const trailing = buffer.trim();
  if (trailing) {
    appendStreamEvent(JSON.parse(trailing));
  }
}

async function runLaunchPlan(event) {
  event.preventDefault();
  const payload = buildPayload();

  if (!payload.product_brief || !payload.audience) {
    setStatus("Needs input", "Add a brief and audience", "Those fields are required before the plan can run.");
    return;
  }

  clearNode(streamLog, "");
  clearNode(resultBody, "The final report will render here after the run completes.");
  scoreBadge.textContent = "--";
  scoreBadge.className = "score-badge";
  activeHistoryId = null;
  activeRunModel = null;
  pendingRequestPayload = payload;
  currentExportRecord = null;
  syncExportButtons();
  setPill("Working");
  setStatus("Running", "Building the launch plan", "The agent is working through the brief in real time.");

  activeRunController = new AbortController();
  syncRunButtons(true);

  try {
    const response = await fetch(`${API_BASE}/api/launch-plan/stream`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/x-ndjson",
      },
      body: JSON.stringify(payload),
      signal: activeRunController.signal,
    });

    if (!response.ok || !response.body) {
      let detail = await response.text();
      try {
        detail = JSON.parse(detail).detail || detail;
      } catch {
        // Keep the raw response text when it is not JSON.
      }
      throw new Error(detail || `Request failed with ${response.status}`);
    }

    await readNdjsonStream(response);
  } catch (error) {
    if (error.name === "AbortError") {
      setPill("Canceled");
      setStatus("Canceled", "Launch planning stopped", "The current run was canceled before completion.");
      renderStreamItem("Canceled", "The active launch planning run was canceled.", "warn");
    } else {
      setPill("Error");
      setStatus("Blocked", "The agent could not finish", error.message);
      renderStreamItem("Error", error.message, "bad");
    }
  } finally {
    activeRunController = null;
    syncRunButtons(false);
  }
}

function scheduleHistoryReload() {
  clearTimeout(historyReloadTimer);
  historyReloadTimer = setTimeout(() => loadHistory(), 180);
}

async function downloadExport(format) {
  if (!currentExportRecord && !activeHistoryId) {
    setStatus("Need result", "Run or open a plan first", "Export is available after a launch plan appears on screen.");
    return;
  }

  try {
    let payload;
    let mimeType;
    let extension;

    if (currentExportRecord) {
      if (format === "json") {
        payload = JSON.stringify(currentExportRecord, null, 2);
        mimeType = "application/json";
        extension = "json";
      } else {
        payload = renderRecordMarkdown(currentExportRecord);
        mimeType = "text/markdown";
        extension = "md";
      }
    } else {
      const response = await fetch(`${API_BASE}/api/history/${activeHistoryId}/export?format=${format}`);
      if (!response.ok) {
        throw new Error(`Export request failed with ${response.status}`);
      }

      if (format === "json") {
        payload = JSON.stringify(await response.json(), null, 2);
        mimeType = "application/json";
        extension = "json";
      } else {
        payload = await response.text();
        mimeType = "text/markdown";
        extension = "md";
      }
    }

    const blob = new Blob([payload], { type: `${mimeType};charset=utf-8` });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    const exportId = currentExportRecord?.request_id || activeHistoryId;
    anchor.href = url;
    anchor.download = `launch-plan-${exportId}.${extension}`;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);

    setStatus("Exported", `Downloaded ${format.toUpperCase()}`, `Saved launch-plan-${exportId}.${extension}.`);
    renderStreamItem("Export", `Downloaded ${format.toUpperCase()} for ${exportId}.`);
  } catch (error) {
    setStatus("Blocked", "Export failed", error.message);
    renderStreamItem("Error", error.message, "bad");
  }
}

loadSampleButton.addEventListener("click", () => {
  fields.productBrief.value = sample.productBrief;
  fields.audience.value = sample.audience;
  fields.launchDate.value = sample.launchDate;
  fields.constraints.value = sample.constraints;
  fields.assets.value = sample.assets;
  fields.desiredChannels.value = sample.desiredChannels;
  setStatus("Sample loaded", "Ready to plan", "The brief is prefilled with a realistic launch scenario.");
});

resetButton.addEventListener("click", () => {
  form.reset();
  fields.desiredChannels.value = "Slack, Email, Release notes";
  activeHistoryId = null;
  activeRunModel = null;
  pendingRequestPayload = null;
  currentExportRecord = null;
  syncExportButtons();
  setPill("Idle");
  setStatus("Ready", "Waiting for a launch brief", "Use the sample or paste your own launch idea.");
  clearNode(streamLog, "No run yet. Submit the form to start a live plan.");
  clearNode(resultBody, "The final report will render here after the run completes.");
  scoreBadge.textContent = "--";
  scoreBadge.className = "score-badge";
});

cancelRunButton.addEventListener("click", () => {
  if (activeRunController) {
    activeRunController.abort();
  }
});

refreshHistoryButton.addEventListener("click", () => loadHistory());
historyQueryInput.addEventListener("input", scheduleHistoryReload);
historyVerdictSelect.addEventListener("change", () => loadHistory());
exportMarkdownButton.addEventListener("click", () => downloadExport("markdown"));
exportJsonButton.addEventListener("click", () => downloadExport("json"));

form.addEventListener("submit", runLaunchPlan);

setStatus("Ready", "Waiting for a launch brief", "Use the sample or paste your own launch idea. The stream will light up as the agent works.");
syncExportButtons();
syncRunButtons(false);
loadHistory();
