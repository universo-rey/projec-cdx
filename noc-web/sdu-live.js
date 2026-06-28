(function () {
  "use strict";

  const root = document.getElementById("root") || document.body;
  const styles = `
    <style>
      * { box-sizing: border-box; }
      .wrap { min-height: 100vh; padding: 28px; background: #07111f; color: #f3f7ff; }
      .title { margin: 0 0 10px; font-size: 38px; line-height: 1.1; }
      .sub { margin: 0 0 24px; color: #94a3b8; }
      .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 14px; margin-bottom: 20px; }
      .card { background: #0f172a; border: 1px solid #22304a; border-radius: 10px; padding: 16px; }
      .label { font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: #94a3b8; margin-bottom: 10px; }
      .value { font-size: 40px; font-weight: 700; }
      .value.bad { color: #fb7185; }
      .value.warn { color: #fbbf24; }
      .value.good { color: #34d399; }
      .section { margin-top: 18px; }
      .section h2 { margin: 0 0 10px; font-size: 18px; }
      .list { display: grid; gap: 10px; }
      .item { background: #0f172a; border: 1px solid #22304a; border-radius: 10px; padding: 14px; }
      .pill { display: inline-block; margin-right: 8px; padding: 3px 8px; border-radius: 999px; font-size: 12px; font-weight: 700; }
      .pill.bad { background: #3f1d2a; color: #fb7185; }
      .pill.warn { background: #3c2b05; color: #fbbf24; }
      .pill.good { background: #0f2d26; color: #34d399; }
      .muted { color: #94a3b8; }
      code { color: #cbd5e1; }
    </style>
  `;

  document.body.innerHTML = `<div id="root">${styles}<div class="wrap"><h1 class="title">SDU NOC</h1><p class="sub">Cargando estado en tiempo real.</p></div></div>`;

  async function render() {
    try {
      const res = await fetch("/core/noc/noc-state.json", { cache: "no-store" });
      const data = await res.json();
      const live = data.operation_live || {};
      const summary = (live.inteligencia && live.inteligencia.summary) || {};
      const alerts = Array.isArray(live.alertas_activas) ? live.alertas_activas : [];
      const suggestions = Array.isArray(live.sugerencias_automaticas) ? live.sugerencias_automaticas : [];
      const priority = Array.isArray(live.prioridad) ? live.prioridad : [];

      root.innerHTML = `
        ${styles}
        <main class="wrap">
          <h1 class="title">SDU NOC ACTIVO</h1>
          <p class="sub">Fuente: <code>/core/noc/noc-state.json</code></p>

          <section class="grid">
            <div class="card">
              <div class="label">CRITICAL</div>
              <div class="value bad">${summary.CRITICAL ?? 0}</div>
            </div>
            <div class="card">
              <div class="label">WARNING</div>
              <div class="value warn">${summary.WARNING ?? 0}</div>
            </div>
            <div class="card">
              <div class="label">INFO</div>
              <div class="value good">${summary.INFO ?? 0}</div>
            </div>
          </section>

          <section class="section">
            <h2>Alertas activas</h2>
            <div class="list">
              ${
                alerts.length
                  ? alerts.map((item) => `
                      <div class="item">
                        <span class="pill ${String(item.gravedad || "INFO").toLowerCase() === "critical" ? "bad" : String(item.gravedad || "INFO").toLowerCase() === "warning" ? "warn" : "good"}">
                          ${item.gravedad || "INFO"}
                        </span>
                        <strong>${item.id || item.event_id || item.fuente || "alerta"}</strong>
                        <div class="muted">${item.problema || item.sugerencia?.problema || "Sin detalle"}</div>
                      </div>
                    `).join("")
                  : `<div class="item"><span class="pill good">OK</span>Sin alertas activas.</div>`
              }
            </div>
          </section>

          <section class="section">
            <h2>Sugerencias</h2>
            <div class="list">
              ${
                suggestions.length
                  ? suggestions.map((item) => `
                      <div class="item">
                        <span class="pill ${String(item.gravedad || "INFO").toLowerCase() === "warning" ? "warn" : "good"}">${item.gravedad || "INFO"}</span>
                        <strong>${item.problema || "Sugerencia"}</strong>
                        <div class="muted">${item.accion_sugerida || "Sin acción sugerida"}</div>
                      </div>
                    `).join("")
                  : `<div class="item"><span class="pill good">OK</span>Sin sugerencias.</div>`
              }
            </div>
          </section>

          <section class="section">
            <h2>Prioridad</h2>
            <div class="list">
              ${
                priority.length
                  ? priority.slice(0, 5).map((item) => `
                      <div class="item">
                        <span class="pill ${String(item.gravedad || "INFO").toLowerCase() === "warning" ? "warn" : "good"}">#${item.rank}</span>
                        <strong>${item.id}</strong>
                        <div class="muted">${item.problema}</div>
                      </div>
                    `).join("")
                  : `<div class="item"><span class="pill good">OK</span>Sin prioridad calculada.</div>`
              }
            </div>
          </section>
        </main>
      `;
    } catch (error) {
      console.error(error);
      root.innerHTML = `${styles}<main class="wrap"><h1 class="title">ERROR</h1><p class="sub">${String(error.message || error)}</p></main>`;
    }
  }

  render();
})();
