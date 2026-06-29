const SOURCE = '/noc/noc-state.json';
const REFRESH_MS = 3000;
const STALE_AFTER_MS = 12000;

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
  lastGoodData: null,
  lastSuccessfulRefreshMs: 0,
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
    .metrics{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:16px}.metric-card{padding:16px;border-radius:12px;border:1px solid var(--border);background:var(--panel-soft);min-height:140px;display:grid;align-content:space-between}.metric-card__icon{width:28px;height:28px;border-radius:8px;display:grid;place-items:center;font-weight:800;background:rgba(148,163,184,.12)}.metric-card__label{margin-top:12px;font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted)}.metric-card__value{font-size:34px;line-height:1;font-weight:800;margin-top:8px;overflow-wrap:anywhere}.metric-card__caption{color:var(--muted);margin-top:10px;font-size:13px}.metric-card--critical .metric-card__value,.metric-card--critical .metric-card__icon{color:var(--critical)}.metric-card--warning .metric-card__value,.metric-card--warning .metric-card__icon{color:var(--warning)}.metric-card--info .metric-card__value,.metric-card--info .metric-card__icon{color:var(--info)}.metric-card--healthy .metric-card__value,.metric-card--healthy .metric-card__icon{color:var(--healthy)}
    .dashboard-grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.1fr);gap:20px}.status-card,.entry,.empty-state,.layer-box{padding:16px;border-radius:12px;border:1px solid var(--border);background:var(--panel-soft)}.status-card{display:grid;gap:14px}.status-card__badge,.status-card__sync,.decision-pill{width:fit-content;padding:6px 9px;border-radius:999px;font-size:11px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.status-card__badge--healthy,.status-card__sync--fresh{color:var(--healthy);background:rgba(34,197,94,.14)}.status-card__badge--degraded,.entry--critical .entry__title,.entry--critical .entry__pill{color:var(--critical)}.status-card__title{font-size:24px;font-weight:800}.status-card__body,.entry__body,.empty-state{color:var(--muted);line-height:1.5}.status-card__grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.agent-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px}.status-card__grid div,.agent-chip{padding:12px;border-radius:10px;border:1px solid var(--border);background:rgba(148,163,184,.05)}.status-card__grid span,.agent-chip span{display:block;color:var(--muted);font-size:12px;margin-bottom:6px}.agent-chip span{text-transform:uppercase}.status-card__grid strong,.agent-chip strong{display:block;overflow-wrap:anywhere}
    .entry__head,.layer-box__head{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:8px}.entry__title{font-weight:800}.entry__pill,.decision-pill{color:var(--muted)}.entry--warning .entry__title,.entry--warning .entry__pill{color:var(--warning)}.entry--info .entry__title,.entry--info .entry__pill{color:var(--info)}
    .layer-grid{display:grid;grid-template-columns:1fr;gap:14px}.layer-box{min-height:0}.layer-box__head h3{margin:0;font-size:13px;letter-spacing:.08em;color:var(--muted)}.layer-box__head span{padding:4px 8px;border-radius:999px;border:1px solid var(--border);font-size:12px;font-weight:800}.history-summary{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:6px 12px;color:var(--muted)}.history-summary strong{color:var(--text);font-size:34px;line-height:1}.history-summary span{font-weight:700}.history-summary small{grid-column:1/-1;line-height:1.45}
    @media(max-width:1180px){.metrics{grid-template-columns:repeat(3,minmax(0,1fr))}.dashboard-grid,.layer-grid{grid-template-columns:1fr}}@media(max-width:900px){#app.dashboard{grid-template-columns:1fr}.sidebar{position:relative;min-height:auto;border-right:0;border-bottom:1px solid var(--border)}.metrics,.status-card__grid,.agent-grid{grid-template-columns:1fr}.topbar{flex-direction:column}.topbar__meta{justify-items:start;text-align:left}}@media(max-width:640px){.main,.sidebar{padding:16px}.topbar__copy h1{font-size:34px}}
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

function formatDate(value) {
  if (!value) return 'No disponible';
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return String(value);
  return new Intl.DateTimeFormat('es-AR', {
    dateStyle: 'medium',
    timeStyle: 'medium',
  }).format(date);
}

function asArray(value) {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

function snapshotTimestampMs(data) {
  const raw = data?.generated_at || data?.operation_live?.generated_at || data?.last_run?.timestamp;
  const parsed = Date.parse(raw);
  return Number.isFinite(parsed) ? parsed : Date.now();
}

function deriveLayers(data) {
  const live = data?.operation_live || data?.noc?.operacion_en_vivo || {};
  const layers = live.capas_alertas || {};
  const foco = asArray(live.foco_visible || layers.foco);
  const monitoreo = asArray(live.monitoreo_agregado || layers.monitoreo);
  const historico = layers.historico || {
    silenciado: Boolean(live.historico_silenciado),
    eventos_repetidos: Math.max(0, n(data?.bus?.visible_alerts) - monitoreo.length),
    eventos_fuente: n(data?.bus?.visible_alerts),
    detalle: 'Eventos repetidos y logs tecnicos permanecen en bitacora',
  };
  return { foco, monitoreo, historico };
}

function deriveSuggestions(data, layers) {
  const live = data?.operation_live || {};
  const suggestions = asArray(live.sugerencias_automaticas || live.sugerencias);
  if (suggestions.length) return suggestions;

  if (layers.monitoreo.length && !layers.foco.length) {
    return [
      {
        gravedad: 'info',
        problema: 'Riesgo controlado en monitoreo',
        accion_sugerida: 'Mantener LOG_ONLY y revisar solo si aparece foco critico o escalacion.',
        requiere_confirmacion: false,
      },
    ];
  }
  return [];
}

function deriveView(data) {
  const live = data?.operation_live || data?.noc?.operacion_en_vivo || {};
  const layers = deriveLayers(data);
  const suggestions = deriveSuggestions(data, layers);
  const health = data?.health || {};
  const noc = data?.noc || {};
  const agentStatus = asArray(data?.agent?.status?.all);
  const predictive = live.alertas_activas?.[0]?.predictive_score || {};
  const healthStatus = String(health.status || data?.status || 'UNKNOWN').toUpperCase();
  const critical = layers.foco.filter((item) => item.classification === 'critical' || item.escalation === true).length;
  const monitoringCount = layers.monitoreo.reduce((sum, item) => sum + Math.max(1, n(item.count)), 0);

  return {
    data,
    live,
    layers,
    suggestions,
    agentStatus,
    predictive,
    status: data?.status || 'NOC_UNKNOWN',
    healthScore: n(health.score),
    healthStatus,
    risk: health.risk || 'INFO',
    trend: health.trend || 'STABLE',
    totalExpedientes: n(noc.total_expedientes),
    expedientesOk: n(noc.expedientes_ok),
    expedientesError: n(noc.expedientes_con_error),
    visibleAlerts: n(data?.bus?.visible_alerts || noc.alertas_activas),
    visibleEvents: n(data?.bus?.visible_events),
    latestEventType: data?.bus?.latest_event_type || noc.ultimo_evento_tipo || 'N/A',
    latestRun: data?.last_run?.timestamp || live.alertas_activas?.[0]?.latest_timestamp,
    critical,
    monitoringCount,
  };
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

function renderDecisionPill(item) {
  const decision = item?.decision || item?.mode || 'OBSERVE';
  const classification = item?.classification || item?.status || 'observed';
  return `<span class="decision-pill">${text(classification)} · ${text(decision)}</span>`;
}

function renderFocus(item, index) {
  return `
    <article class="entry entry--critical">
      <div class="entry__head">
        <div class="entry__title">${text(item.id || item.tipo || `Foco ${index + 1}`)}</div>
        ${renderDecisionPill(item)}
      </div>
      <div class="entry__body">Escalacion activa · ${text(item.latest_timestamp || 'sin timestamp')}</div>
    </article>
  `;
}

function renderMonitoring(item) {
  return `
    <article class="entry entry--warning">
      <div class="entry__head">
        <div class="entry__title">${text(item.tipo || item.id || 'Monitoreo')}</div>
        ${renderDecisionPill(item)}
      </div>
      <div class="entry__body">
        <strong>${text(item.count || 1)}</strong> eventos agrupados · ${text(item.note || 'Sin impacto operativo')}
      </div>
    </article>
  `;
}

function renderSuggestion(item, index) {
  const tone = String(item?.gravedad || item?.level || 'info').toLowerCase();
  const title = item?.problema || item?.title || item?.name || `Sugerencia ${index + 1}`;
  const action = item?.accion_sugerida || item?.action || item?.recommendation || item?.detail || 'Sin accion sugerida';
  const confirm = item?.requiere_confirmacion === true ? 'requiere confirmacion' : 'sin confirmacion';
  return `
    <article class="entry entry--${tone}">
      <div class="entry__head">
        <div class="entry__title">${text(title)}</div>
        <div class="entry__pill">${text(tone.toUpperCase())}</div>
      </div>
      <div class="entry__body">${text(action)} · ${text(confirm)}</div>
    </article>
  `;
}

function renderList(items, emptyLabel, renderer) {
  if (!items.length) return `<div class="empty-state">${text(emptyLabel)}</div>`;
  return `<div class="stack">${items.map((item, index) => renderer(item, index)).join('')}</div>`;
}

function renderKeyValue(label, value) {
  return `
    <div>
      <span>${text(label)}</span>
      <strong>${text(value)}</strong>
    </div>
  `;
}

async function loadState() {
  const response = await fetch(SOURCE);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
}

function setNavActive(targetId) {
  els.navItems.forEach((button) => {
    const active = button.dataset.target === targetId;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-current', active ? 'page' : 'false');
  });
}

function setLiveIndicator(referenceMs, stale) {
  const ageMs = Date.now() - referenceMs;
  const delayed = ageMs > STALE_AFTER_MS;
  const live = !delayed && !stale;

  els.liveState.textContent = live ? 'LIVE' : stale ? 'STALE' : 'DELAYED';
  els.liveState.classList.toggle('live-pill--healthy', live);
  els.liveState.classList.toggle('live-pill--delayed', !live);
  els.statusTag.textContent = stale ? 'DATA STALE' : live ? 'LIVE' : 'DELAYED';
  els.statusTag.classList.toggle('panel__tag--stale', stale || delayed);
}

function renderAgents(view) {
  if (!view.agentStatus.length) return '';
  return `
    <div class="agent-grid">
      ${view.agentStatus.map((agent) => `
        <div class="agent-chip">
          <span>${text(agent.name)}</span>
          <strong>${text(agent.status)}</strong>
        </div>
      `).join('')}
    </div>
  `;
}

function renderDashboard(data, { stale = false } = {}) {
  const view = deriveView(data);
  const timestampMs = snapshotTimestampMs(data);
  const updatedAt = formatDate(timestampMs);
  const focusHealthy = view.critical === 0;
  const sourcePath = SOURCE.replace('http://127.0.0.1:8080', '');

  state.lastSuccessfulRefreshMs = Date.now();
  setLiveIndicator(state.lastSuccessfulRefreshMs, stale);

  els.metrics.innerHTML = [
    renderMetricCard('SALUD', view.healthScore || view.healthStatus, view.healthStatus === 'RED' ? 'critical' : 'warning', `${view.healthStatus} · riesgo ${view.risk}`, 'S'),
    renderMetricCard('EXPEDIENTES', `${view.expedientesOk}/${view.totalExpedientes}`, 'healthy', `${view.expedientesError} con error`, 'E'),
    renderMetricCard('FOCO', view.critical, view.critical ? 'critical' : 'healthy', 'Criticos y escalaciones', 'F'),
    renderMetricCard('MONITOREO', view.monitoringCount, 'warning', 'Controlados en LOG_ONLY', 'M'),
    renderMetricCard('BUS', view.visibleAlerts, 'info', `${view.visibleEvents} eventos visibles`, 'B'),
    renderMetricCard('TENDENCIA', view.trend, 'info', view.latestEventType, 'T'),
  ].join('');

  els.statusCard.innerHTML = `
    <div class="status-card__badge ${focusHealthy ? 'status-card__badge--healthy' : 'status-card__badge--degraded'}">
      ${focusHealthy ? 'CONTROLADO' : 'REQUIERE ACCION'}
    </div>
    <div class="status-card__title">${text(view.status)}</div>
    <div class="status-card__body">
      ${text(focusHealthy ? 'Sin foco critico visible. Las alertas repetidas quedan agrupadas en monitoreo.' : 'Hay foco critico o escalacion activa en el panel.')}
    </div>
    <div class="status-card__sync ${stale ? 'status-card__sync--stale' : 'status-card__sync--fresh'}">
      ${stale ? 'DATA STALE' : 'DATA FRESH'}
    </div>
    <div class="status-card__grid">
      ${renderKeyValue('Modo', data.mode || 'N/A')}
      ${renderKeyValue('Ultima corrida', view.latestRun || 'N/A')}
      ${renderKeyValue('Historico', view.layers.historico.silenciado ? 'silenciado' : 'visible')}
      ${renderKeyValue('Fuente', sourcePath)}
    </div>
    ${renderAgents(view)}
  `;

  const history = view.layers.historico;
  els.alertsList.innerHTML = `
    <div class="layer-grid">
      <section class="layer-box layer-box--focus">
        <div class="layer-box__head">
          <h3>FOCO</h3>
          <span>${view.layers.foco.length}</span>
        </div>
        ${renderList(view.layers.foco, 'Sin criticos ni escalaciones', renderFocus)}
      </section>
      <section class="layer-box layer-box--monitoring">
        <div class="layer-box__head">
          <h3>MONITOREO</h3>
          <span>${view.layers.monitoreo.length}</span>
        </div>
        ${renderList(view.layers.monitoreo, 'Sin alertas en monitoreo', renderMonitoring)}
      </section>
      <section class="layer-box layer-box--history">
        <div class="layer-box__head">
          <h3>HISTORICO</h3>
          <span>${history.silenciado ? 'OFF' : 'ON'}</span>
        </div>
        <div class="history-summary">
          <strong>${text(history.eventos_repetidos ?? 0)}</strong>
          <span>eventos repetidos silenciados</span>
          <small>${text(history.detalle || 'Detalle tecnico en bitacora')}</small>
        </div>
      </section>
    </div>
  `;

  els.suggestionsList.innerHTML = renderList(view.suggestions, 'Sin sugerencias', renderSuggestion);
  els.alertsCount.textContent = `${view.layers.foco.length}/${view.layers.monitoreo.length}`;
  els.suggestionsCount.textContent = String(view.suggestions.length);
  els.lastUpdated.textContent = `Ultima actualizacion: ${text(updatedAt)}`;
  els.sourcePath.textContent = sourcePath;
}

function renderFallback(errorMessage) {
  setLiveIndicator(state.lastSuccessfulRefreshMs || 0, true);
  els.statusCard.innerHTML = `
    <div class="status-card__badge status-card__badge--degraded">DATA STALE</div>
    <div class="status-card__title">No se pudo refrescar</div>
    <div class="status-card__body">${text(errorMessage)}</div>
  `;
}

async function refresh() {
  if (state.refreshInFlight) return;
  state.refreshInFlight = true;
  try {
    const data = await loadState();
    state.lastGoodData = data;
    renderDashboard(data, { stale: false });
  } catch (error) {
    if (state.lastGoodData) renderDashboard(state.lastGoodData, { stale: true });
    renderFallback(error.message);
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
