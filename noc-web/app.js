const API = {
  state: '/state',
  alerts: '/alerts',
  kpis: '/kpis',
  decisions: '/decisions',
};

const REFRESH_MS = 5000;
const STALE_AFTER_MS = 15000;

const els = {
  metrics: document.getElementById('metrics'),
  statusCard: document.getElementById('statusCard'),
  alertsList: document.getElementById('alertsList'),
  suggestionsList: document.getElementById('suggestionsList'),
  alertsCount: document.getElementById('alertsCount'),
  suggestionsCount: document.getElementById('suggestionsCount'),
  statusTag: document.getElementById('statusTag'),
  liveState: document.getElementById('liveState'),
  lastUpdated: document.getElementById('lastUpdated'),
  refreshBtn: document.getElementById('refreshBtn'),
  autoToggle: document.getElementById('autoToggle'),
  sourcePath: document.getElementById('sourcePath'),
  navItems: Array.from(document.querySelectorAll('.nav-item')),
};

const state = {
  autoRefresh: true,
  timerId: null,
  refreshInFlight: false,
  lastGoodPayload: null,
  lastRefreshMs: 0,
};

function injectCriticalStyles() {
  if (document.getElementById('nocCriticalStyles')) return;
  const style = document.createElement('style');
  style.id = 'nocCriticalStyles';
  style.textContent = `
    :root{color-scheme:dark;--bg:#0f172a;--panel:rgba(15,23,42,.94);--panel-soft:rgba(15,23,42,.72);--border:rgba(148,163,184,.18);--text:#f8fafc;--muted:#94a3b8;--critical:#ef4444;--warning:#f59e0b;--info:#38bdf8;--healthy:#22c55e;--stale:#eab308;--shadow:0 18px 44px rgba(2,6,23,.28)}
    *{box-sizing:border-box}html,body{margin:0;min-height:100%;background:linear-gradient(180deg,#0b1220 0%,#101827 52%,var(--bg) 100%);color:var(--text);font-family:Inter,Segoe UI,Arial,sans-serif}button,input{font:inherit}
    #app.dashboard{min-height:100vh;display:grid;grid-template-columns:292px minmax(0,1fr)}.sidebar{position:sticky;top:0;min-height:100vh;padding:24px 18px;display:grid;gap:22px;align-content:start;border-right:1px solid var(--border);background:rgba(8,15,29,.88)}
    .brand{display:flex;align-items:center;gap:12px}.brand__mark{width:48px;height:48px;border-radius:12px;display:grid;place-items:center;background:rgba(56,189,248,.14);border:1px solid var(--border);font-weight:800;letter-spacing:.08em}.brand__title{font-size:18px;font-weight:800}.brand__subtitle,.source-card__label,.eyebrow,.timestamp{color:var(--muted);font-size:12px}
    .sidebar__nav,.sidebar__tools,.stack{display:grid;gap:12px}.nav-item,.btn{min-height:42px;border:1px solid var(--border);border-radius:10px;background:rgba(148,163,184,.06);color:var(--text);cursor:pointer}.nav-item{width:100%;padding:12px 14px;text-align:left}.nav-item.is-active,.nav-item:hover{background:rgba(148,163,184,.12)}.btn--primary{font-weight:800;border-color:rgba(56,189,248,.32)}
    .toggle{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:12px;cursor:pointer}.toggle input{position:absolute;opacity:0}.toggle__track{width:48px;height:28px;border-radius:999px;background:rgba(148,163,184,.2);border:1px solid var(--border);position:relative}.toggle__thumb{position:absolute;top:3px;left:3px;width:20px;height:20px;border-radius:50%;background:var(--text);transition:transform .2s}.toggle input:checked+.toggle__track{background:rgba(34,197,94,.24)}.toggle input:checked+.toggle__track .toggle__thumb{transform:translateX(20px)}.source-card{padding:14px;border-radius:12px;border:1px solid var(--border);background:var(--panel-soft)}.source-card code{display:block;margin-top:6px;word-break:break-word}
    .main{min-width:0;padding:28px;display:grid;gap:20px}.topbar{display:flex;justify-content:space-between;gap:20px;align-items:flex-start}.topbar__copy h1{margin:6px 0 8px;font-size:42px;line-height:1.05}.topbar__copy p{margin:0;color:var(--muted);max-width:760px}.topbar__meta{text-align:right;display:grid;gap:10px;justify-items:end}.live-pill,.panel__tag{padding:7px 10px;border-radius:999px;border:1px solid var(--border);font-size:12px;font-weight:800;letter-spacing:.08em}.live-pill{color:var(--healthy);background:rgba(34,197,94,.14)}.live-pill--delayed,.panel__tag--stale{color:var(--stale);background:rgba(234,179,8,.14)}
    .panel{padding:20px;border-radius:14px;border:1px solid var(--border);background:var(--panel);box-shadow:var(--shadow)}.panel__head{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:16px}.panel__head h2{margin:0;font-size:18px}.panel__tag{background:rgba(148,163,184,.08);color:var(--muted)}
    .metrics{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:16px}.metric-card,.status-card,.entry,.empty-state,.layer-box{padding:16px;border-radius:12px;border:1px solid var(--border);background:var(--panel-soft)}.metric-card{min-height:140px;display:grid;align-content:space-between}.metric-card__icon{width:28px;height:28px;border-radius:8px;display:grid;place-items:center;font-weight:800;background:rgba(148,163,184,.12)}.metric-card__label{margin-top:12px;font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted)}.metric-card__value{font-size:34px;line-height:1;font-weight:800;margin-top:8px;overflow-wrap:anywhere}.metric-card__caption{color:var(--muted);margin-top:10px;font-size:13px}.metric-card--critical .metric-card__value,.metric-card--critical .metric-card__icon{color:var(--critical)}.metric-card--warning .metric-card__value,.metric-card--warning .metric-card__icon{color:var(--warning)}.metric-card--info .metric-card__value,.metric-card--info .metric-card__icon{color:var(--info)}.metric-card--healthy .metric-card__value,.metric-card--healthy .metric-card__icon{color:var(--healthy)}
    .dashboard-grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.1fr);gap:20px}.status-card{display:grid;gap:14px}.status-card__badge,.status-card__sync,.decision-pill{width:fit-content;padding:6px 9px;border-radius:999px;font-size:11px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.status-card__badge--healthy,.status-card__sync--fresh{color:var(--healthy);background:rgba(34,197,94,.14)}.status-card__badge--degraded,.entry--critical .entry__title,.entry--critical .entry__pill{color:var(--critical)}.status-card__title{font-size:24px;font-weight:800}.status-card__body,.entry__body,.empty-state{color:var(--muted);line-height:1.5}.status-card__grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.status-card__grid div{padding:12px;border-radius:10px;border:1px solid var(--border);background:rgba(148,163,184,.05)}.status-card__grid span{display:block;color:var(--muted);font-size:12px;margin-bottom:6px}.status-card__grid strong{display:block;overflow-wrap:anywhere}
    .entry__head,.layer-box__head{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:8px}.entry__title{font-weight:800}.entry__pill,.decision-pill{color:var(--muted)}.entry--warning .entry__title,.entry--warning .entry__pill{color:var(--warning)}.entry--info .entry__title,.entry--info .entry__pill{color:var(--info)}
    .layer-grid{display:grid;grid-template-columns:1fr;gap:14px}.layer-box__head h3{margin:0;font-size:13px;letter-spacing:.08em;color:var(--muted)}.layer-box__head span{padding:4px 8px;border-radius:999px;border:1px solid var(--border);font-size:12px;font-weight:800}
    @media(max-width:1180px){.metrics{grid-template-columns:repeat(3,minmax(0,1fr))}.dashboard-grid{grid-template-columns:1fr}}@media(max-width:900px){#app.dashboard{grid-template-columns:1fr}.sidebar{position:relative;min-height:auto;border-right:0;border-bottom:1px solid var(--border)}.metrics,.status-card__grid{grid-template-columns:1fr}.topbar{flex-direction:column}.topbar__meta{justify-items:start;text-align:left}}@media(max-width:640px){.main,.sidebar{padding:16px}.topbar__copy h1{font-size:34px}}
  `;
  document.head.appendChild(style);
}

injectCriticalStyles();

function n(value) {
  return Number.isFinite(Number(value)) ? Number(value) : 0;
}

function text(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function toneForStatus(status) {
  const normalized = String(status || '').toUpperCase();
  if (['GREEN', 'OK', 'HEALTHY', 'PASS'].includes(normalized)) return 'healthy';
  if (['RED', 'CRITICAL', 'ERROR', 'FAIL'].includes(normalized)) return 'critical';
  return 'warning';
}

function formatDate(value) {
  if (!value) return 'No disponible';
  const parsed = Date.parse(value);
  if (!Number.isFinite(parsed)) return String(value);
  return new Intl.DateTimeFormat('es-AR', {
    dateStyle: 'medium',
    timeStyle: 'medium',
  }).format(new Date(parsed));
}

async function fetchJson(endpoint) {
  const response = await fetch(endpoint, { cache: 'no-store' });
  if (!response.ok) throw new Error(`${endpoint} HTTP ${response.status}`);
  return response.json();
}

async function loadPayload() {
  const [nocState, alerts, kpis, decisions] = await Promise.all([
    fetchJson(API.state),
    fetchJson(API.alerts),
    fetchJson(API.kpis),
    fetchJson(API.decisions),
  ]);
  return { nocState, alerts, kpis, decisions };
}

function renderMetricCard(label, value, tone, caption, icon) {
  return `
    <article class="metric-card metric-card--${tone}">
      <div class="metric-card__icon">${text(icon)}</div>
      <div class="metric-card__label">${text(label)}</div>
      <div class="metric-card__value">${text(value)}</div>
      <div class="metric-card__caption">${text(caption)}</div>
    </article>
  `;
}

function renderKeyValue(label, value) {
  return `
    <div>
      <span>${text(label)}</span>
      <strong>${text(value)}</strong>
    </div>
  `;
}

function renderDecisionPill(item) {
  return `<span class="decision-pill">${text(item.classification || item.status || 'observed')} · ${text(item.decision || 'OBSERVE')}</span>`;
}

function renderAlert(item, index) {
  const critical = item.escalation === true || item.block_operations === true || String(item.classification).toLowerCase() === 'critical';
  return `
    <article class="entry entry--${critical ? 'critical' : 'warning'}">
      <div class="entry__head">
        <div class="entry__title">${text(item.id || `alert-${index + 1}`)}</div>
        ${renderDecisionPill(item)}
      </div>
      <div class="entry__body">
        <strong>${text(item.count || 1)}</strong> eventos · ${text(item.note || item.source || 'Sin detalle')}
      </div>
    </article>
  `;
}

function renderDecision(item, index) {
  return `
    <article class="entry entry--info">
      <div class="entry__head">
        <div class="entry__title">${text(item.id || `decision-${index + 1}`)}</div>
        ${renderDecisionPill(item)}
      </div>
      <div class="entry__body">${text(item.reason || item.note || item.event_type || 'Decision registrada')}</div>
    </article>
  `;
}

function renderList(items, emptyLabel, renderer) {
  if (!items.length) return `<div class="empty-state">${text(emptyLabel)}</div>`;
  return `<div class="stack">${items.map((item, index) => renderer(item, index)).join('')}</div>`;
}

function setLiveIndicator(stale) {
  const delayed = Date.now() - state.lastRefreshMs > STALE_AFTER_MS;
  const healthy = !stale && !delayed;
  els.liveState.textContent = healthy ? 'LIVE' : stale ? 'STALE' : 'DELAYED';
  els.liveState.classList.toggle('live-pill--delayed', !healthy);
  els.statusTag.textContent = healthy ? 'LIVE' : stale ? 'DATA STALE' : 'DELAYED';
  els.statusTag.classList.toggle('panel__tag--stale', !healthy);
}

function renderDashboard(payload, { stale = false } = {}) {
  const { nocState, alerts, kpis, decisions } = payload;
  const globalStatus = nocState.global_status || {};
  const runtime = nocState.runtime || {};
  const activeAlerts = alerts.filter((alert) => String(alert.status || '').toUpperCase() !== 'RESOLVED');
  const focusCount = activeAlerts.filter((alert) => alert.escalation === true || alert.block_operations === true).length;
  const statusTone = toneForStatus(globalStatus.status);
  const updated = nocState.updated_at || new Date().toISOString();

  state.lastRefreshMs = Date.now();
  setLiveIndicator(stale);

  els.metrics.innerHTML = [
    renderMetricCard('SALUD', globalStatus.score ?? globalStatus.status ?? 'N/A', statusTone, `${globalStatus.status || 'UNKNOWN'} · riesgo ${globalStatus.risk || 'N/A'}`, 'S'),
    renderMetricCard('EXPEDIENTES', `${n(kpis.expedientes_ok)}/${n(kpis.total_expedientes)}`, 'healthy', `${n(kpis.expedientes_con_error)} con error`, 'E'),
    renderMetricCard('FOCO', focusCount, focusCount ? 'critical' : 'healthy', 'Criticos y escalaciones', 'F'),
    renderMetricCard('ALERTAS', n(kpis.live_alerts_visible || activeAlerts.length), 'warning', `${n(kpis.source_watchdog_alerts)} eventos fuente`, 'A'),
    renderMetricCard('BUS', n(kpis.visible_events), 'info', `${n(kpis.visible_alerts)} alertas visibles`, 'B'),
    renderMetricCard('DECISIONES', decisions.length, 'info', `${n(kpis.classified_events)} eventos clasificados`, 'D'),
  ].join('');

  els.statusCard.innerHTML = `
    <div class="status-card__badge ${focusCount ? 'status-card__badge--degraded' : 'status-card__badge--healthy'}">
      ${focusCount ? 'REQUIERE ACCION' : 'CONTROLADO'}
    </div>
    <div class="status-card__title">${text(globalStatus.label || 'NOC')}</div>
    <div class="status-card__body">
      ${text(focusCount ? 'Hay foco critico o escalacion activa.' : 'Sin foco critico visible; las alertas quedan en monitoreo.')}
    </div>
    <div class="status-card__sync ${stale ? 'status-card__sync--stale' : 'status-card__sync--fresh'}">
      ${stale ? 'DATA STALE' : 'DATA FRESH'}
    </div>
    <div class="status-card__grid">
      ${renderKeyValue('Runtime', runtime.runtime || 'N/A')}
      ${renderKeyValue('Gate cloud', runtime.cloud_gate || 'N/A')}
      ${renderKeyValue('Modo', runtime.operational_mode || 'N/A')}
      ${renderKeyValue('Proyecto', runtime.project_root || 'N/A')}
    </div>
  `;

  els.alertsList.innerHTML = `
    <div class="layer-grid">
      <section class="layer-box">
        <div class="layer-box__head">
          <h3>ALERTAS VIVAS</h3>
          <span>${activeAlerts.length}</span>
        </div>
        ${renderList(activeAlerts, 'Sin alertas activas', renderAlert)}
      </section>
    </div>
  `;

  els.suggestionsList.innerHTML = renderList(decisions, 'Sin decisiones registradas', renderDecision);
  els.alertsCount.textContent = `${focusCount}/${activeAlerts.length}`;
  els.suggestionsCount.textContent = String(decisions.length);
  els.lastUpdated.textContent = `Ultima actualizacion: ${text(formatDate(updated))}`;
  els.sourcePath.textContent = `${API.state} + ${API.alerts} + ${API.kpis} + ${API.decisions}`;
}

function renderError(errorMessage) {
  setLiveIndicator(true);
  els.statusCard.innerHTML = `
    <div class="status-card__badge status-card__badge--degraded">API UNREACHABLE</div>
    <div class="status-card__title">No se pudo refrescar</div>
    <div class="status-card__body">${text(errorMessage)}</div>
  `;
  if (!state.lastGoodPayload) {
    els.metrics.innerHTML = '';
    els.alertsList.innerHTML = '<div class="empty-state">Sin datos visibles hasta que el API responda.</div>';
    els.suggestionsList.innerHTML = '<div class="empty-state">Sin decisiones visibles hasta que el API responda.</div>';
  }
}

async function refresh() {
  if (state.refreshInFlight) return;
  state.refreshInFlight = true;
  try {
    const payload = await loadPayload();
    state.lastGoodPayload = payload;
    renderDashboard(payload, { stale: false });
  } catch (error) {
    if (state.lastGoodPayload) renderDashboard(state.lastGoodPayload, { stale: true });
    renderError(error.message);
  } finally {
    state.refreshInFlight = false;
  }
}

function startAutoRefresh() {
  stopAutoRefresh();
  state.timerId = setInterval(() => {
    if (state.autoRefresh && !state.refreshInFlight) refresh();
  }, REFRESH_MS);
}

function stopAutoRefresh() {
  if (state.timerId) clearInterval(state.timerId);
  state.timerId = null;
}

function setAutoRefresh(next) {
  state.autoRefresh = next;
  els.autoToggle.checked = next;
  if (next) {
    startAutoRefresh();
    refresh();
  } else {
    stopAutoRefresh();
  }
}

function setNavActive(targetId) {
  els.navItems.forEach((button) => {
    const active = button.dataset.target === targetId;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-current', active ? 'page' : 'false');
  });
}

els.refreshBtn.addEventListener('click', refresh);
els.autoToggle.addEventListener('change', () => setAutoRefresh(els.autoToggle.checked));
els.navItems.forEach((button) => {
  button.addEventListener('click', () => {
    const target = document.getElementById(button.dataset.target);
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      setNavActive(button.dataset.target);
    }
  });
});

refresh();
startAutoRefresh();
