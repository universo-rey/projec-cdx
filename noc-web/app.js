const SOURCE = 'http://127.0.0.1:8080/noc/noc-state.json';
const REFRESH_MS = 3000;
const STALE_AFTER_MS = 5000;

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
  lastGoodTimestampMs: 0,
  lastSuccessfulRefreshMs: 0,
};

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
  if (!value) {
    return 'No disponible';
  }
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) {
    return String(value);
  }
  return new Intl.DateTimeFormat('es-AR', {
    dateStyle: 'medium',
    timeStyle: 'medium',
  }).format(date);
}

function snapshotTimestampMs(data) {
  const raw = data?.generated_at || data?.timestamp || data?.updated_at;
  const parsed = Date.parse(raw);
  if (Number.isFinite(parsed)) {
    return parsed;
  }
  return Date.now();
}

function hasCompleteLiveBlock(data) {
  return Boolean(
    data &&
    data.operation_live &&
    data.operation_live.inteligencia &&
    data.operation_live.inteligencia.summary &&
    typeof data.operation_live.inteligencia.summary === 'object'
  );
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

function alertTitle(item, index) {
  return item?.titulo || item?.title || item?.problema || item?.name || `Alerta ${index + 1}`;
}

function alertBody(item) {
  return item?.detalle || item?.detail || item?.descripcion || item?.description || item?.message || item?.text || 'Evento activo';
}

function alertTone(item) {
  return String(item?.gravedad || item?.level || item?.severity || 'info').toLowerCase();
}

function renderAlert(item, index) {
  const tone = alertTone(item);
  return `
    <article class="entry entry--${tone}">
      <div class="entry__head">
        <div class="entry__title">${text(alertTitle(item, index))}</div>
        <div class="entry__pill">${text(tone.toUpperCase())}</div>
      </div>
      <div class="entry__body">${text(alertBody(item))}</div>
    </article>
  `;
}

function renderSuggestion(item, index) {
  const tone = String(item?.gravedad || item?.level || 'info').toLowerCase();
  const title = item?.problema || item?.title || item?.name || `Sugerencia ${index + 1}`;
  const action = item?.accion_sugerida || item?.action || item?.recommendation || item?.detail || 'Sin acción sugerida';
  const confirm = item?.requiere_confirmacion === true ? 'Requiere confirmación' : 'Sin confirmación';
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
  if (!items.length) {
    return `<div class="empty-state">${text(emptyLabel)}</div>`;
  }
  return `<div class="stack">${items.map((item, index) => renderer(item, index)).join('')}</div>`;
}

async function loadState() {
  const response = await fetch(SOURCE);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
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
  const live = !delayed;

  els.liveState.textContent = live ? '🟢 LIVE' : '🟡 DELAYED';
  els.liveState.classList.toggle('live-pill--healthy', live && !stale);
  els.liveState.classList.toggle('live-pill--delayed', !live || stale);
  els.statusTag.textContent = stale ? 'DATA STALE' : (live ? 'HEALTHY' : 'DELAYED');
  els.statusTag.classList.toggle('panel__tag--stale', stale);

  return { ageMs, delayed, live };
}

function renderDashboard(data, { stale = false } = {}) {
  const live = data.operation_live;
  const summary = live.inteligencia.summary;
  const critical = n(summary.CRITICAL);
  const warning = n(summary.WARNING);
  const info = n(summary.INFO);
  const alerts = Array.isArray(live.alertas_activas) ? live.alertas_activas : [];
  const suggestions = Array.isArray(live.sugerencias_automaticas)
    ? live.sugerencias_automaticas
    : Array.isArray(live.sugerencias)
      ? live.sugerencias
      : [];
  const healthy = critical === 0;
  const timestampMs = snapshotTimestampMs(data);
  const freshness = setLiveIndicator(state.lastSuccessfulRefreshMs || Date.now(), stale);
  const updatedAt = formatDate(timestampMs);

  state.lastGoodTimestampMs = timestampMs;
  state.lastSuccessfulRefreshMs = Date.now();

  els.metrics.innerHTML = [
    renderMetricCard('CRITICAL', critical, 'critical', 'Incidentes activos', '!'),
    renderMetricCard('WARNING', warning, 'warning', 'Alertas en observación', '△'),
    renderMetricCard('INFO', info, 'info', 'Señales informativas', 'i'),
  ].join('');

  els.statusCard.innerHTML = `
    <div class="status-card__badge ${healthy ? 'status-card__badge--healthy' : 'status-card__badge--degraded'}">
      ${healthy ? 'HEALTHY' : 'DEGRADED'}
    </div>
    <div class="status-card__title">${healthy ? 'Sistema estable' : 'Revisión requerida'}</div>
    <div class="status-card__body">
      ${text(healthy ? 'Sin condiciones críticas activas. El sistema opera con normalidad.' : 'Se detectaron condiciones críticas activas y requieren revisión.')}
    </div>
    <div class="status-card__sync ${stale ? 'status-card__sync--stale' : 'status-card__sync--fresh'}">
      ${stale ? 'DATA STALE' : 'DATA FRESH'}
    </div>
    <div class="status-card__grid">
      <div>
        <span>Modo</span>
        <strong>${text(data.mode || data.status || 'N/A')}</strong>
      </div>
      <div>
        <span>Última actualización</span>
        <strong>${text(updatedAt)}</strong>
      </div>
      <div>
        <span>Alertas</span>
        <strong>${text(alerts.length)}</strong>
      </div>
      <div>
        <span>Frescura</span>
        <strong>${text(freshness.live ? '🟢 LIVE' : '🟡 DELAYED')}</strong>
      </div>
    </div>
  `;

  els.alertsList.innerHTML = renderList(alerts, 'Sin alertas activas', renderAlert);
  els.suggestionsList.innerHTML = renderList(suggestions, 'Sin sugerencias', renderSuggestion);
  els.alertsCount.textContent = String(alerts.length);
  els.suggestionsCount.textContent = String(suggestions.length);
  els.lastUpdated.textContent = `Última actualización: ${text(updatedAt)}`;
  els.sourcePath.textContent = SOURCE.replace('http://127.0.0.1:8080', '');
}

function renderFallback(errorMessage) {
  const timestampMs = state.lastGoodTimestampMs || Date.now();
  const freshness = setLiveIndicator(state.lastSuccessfulRefreshMs || 0, true);
  const updatedAt = formatDate(timestampMs);

  els.statusCard.innerHTML = `
    <div class="status-card__badge status-card__badge--degraded">DEGRADED</div>
    <div class="status-card__title">DATA STALE</div>
    <div class="status-card__body">Se mantiene el último estado válido mientras la carga se recupera.</div>
    <div class="status-card__sync status-card__sync--stale">DATA STALE</div>
    <div class="status-card__grid">
      <div>
        <span>Última actualización</span>
        <strong>${text(updatedAt)}</strong>
      </div>
      <div>
        <span>Frescura</span>
        <strong>${text(freshness.live ? '🟢 LIVE' : '🟡 DELAYED')}</strong>
      </div>
      <div>
        <span>Estado</span>
        <strong>DATA STALE</strong>
      </div>
      <div>
        <span>Detalle</span>
        <strong>${text(errorMessage)}</strong>
      </div>
    </div>
  `;
  els.lastUpdated.textContent = `Última actualización: ${text(updatedAt)}`;
  els.statusTag.textContent = 'DATA STALE';
  els.statusTag.classList.add('panel__tag--stale');
}

async function refresh() {
  if (state.refreshInFlight) {
    return;
  }
  state.refreshInFlight = true;
  try {
    const data = await loadState();
    if (!hasCompleteLiveBlock(data)) {
      throw new Error('Incomplete operation_live block');
    }
    state.lastGoodData = data;
    renderDashboard(data, { stale: false });
  } catch (error) {
    if (state.lastGoodData) {
      renderDashboard(state.lastGoodData, { stale: true });
      renderFallback(error.message);
    } else {
      renderFallback(error.message);
    }
  } finally {
    state.refreshInFlight = false;
  }
}

function startAutoRefresh() {
  stopAutoRefresh();
  state.timerId = setInterval(() => {
    if (state.autoRefresh && !state.refreshInFlight) {
      refresh();
    }
  }, REFRESH_MS);
}

function stopAutoRefresh() {
  if (state.timerId) {
    clearInterval(state.timerId);
    state.timerId = null;
  }
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

els.refreshBtn.addEventListener('click', () => {
  refresh();
});

els.autoToggle.addEventListener('change', () => {
  setAutoRefresh(els.autoToggle.checked);
});

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
