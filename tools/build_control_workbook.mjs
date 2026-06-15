import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const root = process.cwd();
const workbookDir = path.join(root, "workbooks");
const outputDir = path.join(root, "outputs", "control_operativo_20260615");
await fs.mkdir(workbookDir, { recursive: true });
await fs.mkdir(outputDir, { recursive: true });

async function readText(relativePath) {
  try {
    return await fs.readFile(path.join(root, relativePath), "utf8");
  } catch {
    return "";
  }
}

function oneLine(text, fallback) {
  const line = text
    .split(/\r?\n/)
    .map((value) => value.trim())
    .find((value) => value && !value.startsWith("#"));
  return line || fallback;
}

function todayIso() {
  return new Date().toISOString().slice(0, 10);
}

const sources = {
  current: await readText("operativa/CURRENT.md"),
  next: await readText("operativa/NEXT.md"),
  blockers: await readText("operativa/BLOCKERS.md"),
  trace: await readText("operativa/TRACE.md"),
  todo: await readText("operativa/TODO_20260615.md"),
  cierreCadena: await readText("operativa/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md"),
  semaforoHistoricos: await readText("operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md"),
  liveRepoReview: await readText("outputs/live_repo_review_20260615/READBACK.md"),
  dataverseGate: await readText("dataverse/GATE.md"),
  dataverseRegister: await readText("dataverse/REGISTRO_BLOQUEOS.md"),
  dataversePlan: await readText("dataverse/PLAN_SEGUNDA_PASADA.md"),
  hiloOrigen: await readText("hitos/20260615-hilo-origen-v1/README.md"),
  manifests: await readText("operativa/MANIFESTS.md"),
  retention: await readText("operativa/RETENCION.md"),
};

const hasActiveBlocker = !/Ningun bloqueo operativo activo/i.test(sources.blockers);
const deltas = [
  {
    id: "DELTA-001",
    date: todayIso(),
    surface: "operativa",
    objective: oneLine(sources.current, "Organizacion punta a punta del workbench local."),
    playbook: "00-preflight-gobernado",
    status: "Activo",
    owner: "Codex local",
    output: "START_HERE, PROMPT_NUEVO_HILO, CONTROL, CURRENT, NEXT, BLOCKERS, TRACE",
    milestone: "hitos/20260615-cierre-workbench-v1",
    notes: "Mesa viva para que nuevos hilos nazcan con contexto.",
  },
  {
    id: "DELTA-002",
    date: todayIso(),
    surface: "playbooks",
    objective: "Completar secuencia 00 a 07 con validacion y aprendizaje.",
    playbook: "05-promover-aprendizaje",
    status: "Versionado",
    owner: "Codex local",
    output: "playbooks/00 a 07 agregados y enlazados.",
    milestone: "hitos/20260615-cierre-workbench-v1",
    notes: "El conocimiento operativo queda promovible a canon, hito, tool o playbook.",
  },
  {
    id: "DELTA-003",
    date: todayIso(),
    surface: "tools",
    objective: "Validar el workbench sin tocar superficies live.",
    playbook: "04-validar-delta",
    status: "Activo",
    owner: "Codex local",
    output: "tools/validate_proj_cdx_workbench.ps1",
    milestone: "hitos/20260615-cierre-workbench-v1",
    notes: "Validador read-only: archivos requeridos, mapas, links, xlsx y formulas.",
  },
  {
    id: "DELTA-004",
    date: todayIso(),
    surface: "workbooks",
    objective: "Convertir control_operativo.xlsx en tablero real.",
    playbook: "04-validar-delta",
    status: "Activo",
    owner: "Codex local",
    output: "workbooks/control_operativo.xlsx y outputs/control_operativo_20260615",
    milestone: "hitos/20260615-cierre-workbench-v1",
    notes: "Incluye Resumen, Registro, Alertas y Listas.",
  },
  {
    id: "DELTA-005",
    date: todayIso(),
    surface: "dataverse",
    objective: "Mantener Dataverse en carril local/metadata-only hasta orden explicita.",
    playbook: "06-dataverse-gobernado",
    status: "Preparado",
    owner: "Codex local",
    output: "dataverse/GATE.md y READBACK_EXCEL_BLOCKER_FRONTIER.md",
    milestone: "hitos/20260615-cierre-workbench-v1",
    notes: oneLine(sources.dataverseGate, "No autoriza live writes."),
    dataverseEstado: "metadata_only",
    ambiente: "local",
    targetExacto: "NO_APLICA",
    gateLive: "cerrado",
    postcheck: "pendiente",
  },
  {
    id: "DELTA-006",
    date: todayIso(),
    surface: "dataverse",
    objective: oneLine(sources.dataverseRegister, "Registrar bloqueos, decisiones y escaladas humanas."),
    playbook: "07-dataverse-fronteras",
    status: "Versionado",
    owner: "Codex local",
    output: "dataverse/REGISTRO_BLOQUEOS.md y playbooks/07-dataverse-fronteras.md",
    milestone: "hitos/20260615-hilo-origen-v1",
    notes: oneLine(sources.dataverseRegister, "Dataverse se usa como registro de bloqueos y decisiones."),
    dataverseEstado: "prepared_not_executed",
    ambiente: "local",
    targetExacto: "NO_APLICA",
    gateLive: "cerrado",
    postcheck: "pendiente",
  },
  {
    id: "DELTA-007",
    date: todayIso(),
    surface: "hitos",
    objective: oneLine(sources.hiloOrigen, "Trackear el hilo de origen en un hito padre versionado."),
    playbook: "05-promover-aprendizaje",
    status: "Versionado",
    owner: "Codex local",
    output: "hitos/20260615-hilo-origen-v1",
    milestone: "hitos/20260615-hilo-origen-v1",
    notes: "El hilo queda navegable por capas, con detalle en hitos hijos.",
  },
  {
    id: "DELTA-008",
    date: todayIso(),
    surface: "hitos",
    objective: "Cerrar la cadena CodexLocal, Documents GitHub y Auditar con acta y TODO visible.",
    playbook: "03-cerrar-delta",
    status: "Versionado",
    owner: "Codex local",
    output: "operativa/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md y operativa/TODO_20260615.md",
    milestone: "hitos/20260615-cierre-cadena-github-auditar-v1",
    notes: oneLine(sources.todo, "El siguiente movimiento natural es clasificar hijos de Auditar."),
  },
  {
    id: "DELTA-009",
    date: todayIso(),
    surface: "github",
    objective: "Cerrar semaforo historico con revision live-read-only de repos canonicos.",
    playbook: "08-github-readonly-cierre",
    status: "Cerrado",
    owner: "Rey repo cartographer",
    output: "outputs/live_repo_review_20260615 y operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md",
    milestone: "hitos/20260615-semaforo-verde-historicos-v1",
    notes: oneLine(sources.liveRepoReview, "13 repos revisados, 4 PRs abiertos observados y 0 writes remotos."),
  },
];

const alertRows = [
  {
    id: "ALR-001",
    severity: hasActiveBlocker ? "Alta" : "Info",
    surface: "operativa",
    condition: hasActiveBlocker ? "blocker_active" : "no_active_blocker",
    action: hasActiveBlocker ? "Resolver BLOCKERS antes de cerrar." : "Mantener BLOCKERS actualizado.",
    evidence: "operativa/BLOCKERS.md",
  },
  {
    id: "ALR-002",
    severity: "Alta",
    surface: "dataverse",
    condition: "live_surface_requires_order",
    action: "No ejecutar live sin ambiente, target, owner, rollback, postcheck y evidencia.",
    evidence: "dataverse/GATE.md",
  },
  {
    id: "ALR-003",
    severity: "Media",
    surface: "outputs",
    condition: "retention_requires_explicit_order",
    action: "No compactar ni borrar outputs sin orden y manifest.",
    evidence: "outputs/RETENCION.md",
  },
  {
    id: "ALR-004",
    severity: "Media",
    surface: "hitos",
    condition: "durable_closeout_requires_version",
    action: "Cerrar esta ronda en hito versionado.",
    evidence: "hitos/20260615-cierre-workbench-v1",
  },
  {
    id: "ALR-005",
    severity: "Media",
    surface: "dataverse",
    condition: "blocker_register_required",
    action: "Registrar bloqueos y decisiones en dataverse/REGISTRO_BLOQUEOS.md antes de inventariar de mas.",
    evidence: "dataverse/REGISTRO_BLOQUEOS.md",
  },
  {
    id: "ALR-008",
    severity: "Alta",
    surface: "dataverse",
    condition: "metadata_only_requires_postcheck",
    action: "No cerrar metadata_only sin postcheck visible y evidencia local suficiente.",
    evidence: "dataverse/PLAN_SEGUNDA_PASADA.md",
  },
  {
    id: "ALR-009",
    severity: "Alta",
    surface: "dataverse",
    condition: "prepared_not_executed_requires_owner",
    action: "No dejar prepared_not_executed sin owner asignado y target no ambiguo.",
    evidence: "dataverse/PLAN_SEGUNDA_PASADA.md",
  },
  {
    id: "ALR-006",
    severity: "Media",
    surface: "hitos",
    condition: "auditar_child_classification_pending",
    action: "Clasificar hijos de Auditar antes de mover, borrar, promover o escribir.",
    evidence: "operativa/TODO_20260615.md",
  },
  {
    id: "ALR-007",
    severity: "Media",
    surface: "github",
    condition: "github_write_requires_atomic_order",
    action: "No mergear, comentar, pushear ni modificar PRs sin target exacto, owner, rollback, postcheck y evidencia.",
    evidence: "outputs/live_repo_review_20260615/READBACK.md",
  },
];

const wb = Workbook.create();
const resumen = wb.worksheets.add("Resumen");
const registro = wb.worksheets.add("Registro");
const alertas = wb.worksheets.add("Alertas");
const listas = wb.worksheets.add("Listas");

function styleTitle(range, fill) {
  range.format = {
    fill,
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: fill },
  };
}

function styleHeader(range) {
  range.format = {
    fill: "#0F766E",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#0F766E" },
  };
}

function styleBody(range) {
  range.format = {
    fill: "#FFFFFF",
    borders: { preset: "all", style: "thin", color: "#E2E8F0" },
    wrapText: true,
  };
}

function stylePanel(range) {
  range.format = {
    fill: "#F8FAFC",
    font: { color: "#0F172A" },
    borders: { preset: "all", style: "thin", color: "#CBD5E1" },
    wrapText: true,
  };
}

resumen.showGridLines = false;
resumen.getRange("A1:H1").merge();
resumen.getRange("A1").values = [["Control operativo PROJEC CDX"]];
styleTitle(resumen.getRange("A1:H1"), "#0F766E");
resumen.getRange("A1:H1").format.rowHeightPx = 36;

resumen.getRange("A2:H3").merge();
resumen.getRange("A2").values = [[
  "Tablero local para seguir deltas, alertas, evidencia y cierre. Fuente documental: operativa/CONTROL.md.",
]];
stylePanel(resumen.getRange("A2:H3"));

resumen.getRange("A5:B5").values = [["Metrica", "Valor"]];
styleHeader(resumen.getRange("A5:B5"));
resumen.getRange("A6:A12").values = [
  ["Total deltas"],
  ["Activos"],
  ["Bloqueados"],
  ["Cerrados"],
  ["Versionados"],
  ["Alertas altas"],
  ["Sin hito"],
];
resumen.getRange("B6:B12").formulas = [
  ["=COUNTA(Registro!$A$6:$A$65)"],
  ['=COUNTIF(Registro!$F$6:$F$65,"Activo")'],
  ['=COUNTIF(Registro!$F$6:$F$65,"Bloqueado")'],
  ['=COUNTIF(Registro!$F$6:$F$65,"Cerrado")'],
  ['=COUNTIF(Registro!$F$6:$F$65,"Versionado")'],
  ['=COUNTIF(Alertas!$B$6:$B$35,"Alta")'],
  ['=COUNTIF(Registro!$I$6:$I$65,"")'],
];
styleBody(resumen.getRange("A6:B12"));

resumen.getRange("D5:H5").merge();
resumen.getRange("D5").values = [["Control desde aca"]];
styleHeader(resumen.getRange("D5:H5"));
resumen.getRange("D6:H12").merge();
resumen.getRange("D6").values = [[
  "1. Entrar por START_HERE.\n2. Declarar un delta en NEXT.\n3. Ejecutar playbook.\n4. Registrar evidencia y alertas.\n5. Validar con tools/validate_proj_cdx_workbench.ps1.\n6. Versionar hito si el cierre es durable.",
]];
stylePanel(resumen.getRange("D6:H12"));

registro.showGridLines = false;
registro.getRange("A1:O1").merge();
registro.getRange("A1").values = [["Registro de deltas"]];
styleTitle(registro.getRange("A1:O1"), "#155E75");

registro.getRange("A3:O3").merge();
registro.getRange("A3").values = [["Una fila por unidad atomica de trabajo."]];
stylePanel(registro.getRange("A3:O3"));

registro.getRange("A5:O5").values = [[
  "Delta",
  "Fecha",
  "Superficie",
  "Objetivo",
  "Playbook",
  "Estado",
  "Owner",
  "Salida",
  "Hito",
  "Notas",
  "Dataverse estado",
  "Ambiente",
  "Target exacto",
  "Gate live",
  "Postcheck",
]];
styleHeader(registro.getRange("A5:O5"));

const registroRows = Array.from({ length: 60 }, (_, index) => {
  const row = deltas[index];
  return row
    ? [
        row.id,
        row.date,
        row.surface,
        row.objective,
        row.playbook,
        row.status,
        row.owner,
        row.output,
        row.milestone,
        row.notes,
        row.dataverseEstado ?? "NO_APLICA",
        row.ambiente ?? "NO_APLICA",
        row.targetExacto ?? "NO_APLICA",
        row.gateLive ?? "NO_APLICA",
        row.postcheck ?? "NO_APLICA",
      ]
    : [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null];
});
registro.getRange("A6:O65").values = registroRows;
styleBody(registro.getRange("A6:O65"));
registro.tables.add("A5:O65", true, "DeltasTable");
registro.getRange("B6:B65").format.numberFormat = "yyyy-mm-dd";
registro.dataValidations.add({ range: "C6:C65", rule: { type: "list", formula1: "Listas!$A$3:$A$15" } });
registro.dataValidations.add({ range: "E6:E65", rule: { type: "list", formula1: "Listas!$B$3:$B$11" } });
registro.dataValidations.add({ range: "F6:F65", rule: { type: "list", formula1: "Listas!$C$3:$C$8" } });
registro.dataValidations.add({ range: "K6:K65", rule: { type: "list", formula1: "Listas!$E$3:$E$7" } });
registro.dataValidations.add({ range: "L6:L65", rule: { type: "list", formula1: "Listas!$F$3:$F$6" } });
registro.dataValidations.add({ range: "N6:N65", rule: { type: "list", formula1: "Listas!$G$3:$G$6" } });
registro.dataValidations.add({ range: "O6:O65", rule: { type: "list", formula1: "Listas!$H$3:$H$6" } });
registro.freezePanes.freezeRows(5);

for (const col of ["A", "B", "C", "E", "F", "G", "K", "L", "N", "O"]) {
  registro.getRange(`${col}:${col}`).format.columnWidthPx = 130;
}
registro.getRange("D:D").format.columnWidthPx = 300;
registro.getRange("H:H").format.columnWidthPx = 300;
registro.getRange("I:I").format.columnWidthPx = 240;
registro.getRange("J:J").format.columnWidthPx = 300;
registro.getRange("M:M").format.columnWidthPx = 220;

alertas.showGridLines = false;
alertas.getRange("A1:F1").merge();
alertas.getRange("A1").values = [["Alertas y fronteras"]];
styleTitle(alertas.getRange("A1:F1"), "#9A3412");
alertas.getRange("A3:F3").merge();
alertas.getRange("A3").values = [["Alertas derivadas de guardrails, retencion y Dataverse. No reemplazan el gate humano para live writes."]];
stylePanel(alertas.getRange("A3:F3"));
alertas.getRange("A5:F5").values = [["Alerta", "Severidad", "Superficie", "Condicion", "Accion", "Evidencia"]];
styleHeader(alertas.getRange("A5:F5"));
const alertTableRows = Array.from({ length: 30 }, (_, index) => {
  const row = alertRows[index];
  return row ? [row.id, row.severity, row.surface, row.condition, row.action, row.evidence] : [null, null, null, null, null, null];
});
alertas.getRange("A6:F35").values = alertTableRows;
styleBody(alertas.getRange("A6:F35"));
alertas.tables.add("A5:F35", true, "AlertasTable");
alertas.dataValidations.add({ range: "B6:B35", rule: { type: "list", formula1: "Listas!$D$3:$D$6" } });
alertas.freezePanes.freezeRows(5);
for (const col of ["A", "B", "C"]) {
  alertas.getRange(`${col}:${col}`).format.columnWidthPx = 130;
}
alertas.getRange("D:D").format.columnWidthPx = 240;
alertas.getRange("E:E").format.columnWidthPx = 360;
alertas.getRange("F:F").format.columnWidthPx = 280;

listas.showGridLines = false;
listas.getRange("A1:D1").merge();
listas.getRange("A1").values = [["Listas"]];
styleTitle(listas.getRange("A1:D1"), "#0F766E");
listas.getRange("A2:H2").values = [["Superficies", "Playbooks", "Estados", "Severidades", "Dataverse estados", "Ambientes", "Gate live", "Postcheck"]];
styleHeader(listas.getRange("A2:H2"));
listas.getRange("A3:A15").values = [
  ["operativa"],
  ["playbooks"],
  ["workbooks"],
  ["outputs"],
  ["hitos"],
  ["docs"],
  ["inventarios"],
  ["tools"],
  ["packages"],
  ["atomic"],
  ["dataverse"],
  ["root"],
  ["github"],
];
listas.getRange("B3:B11").values = [
  ["00-preflight-gobernado"],
  ["01-iniciar-delta"],
  ["02-ejecutar-delta"],
  ["03-cerrar-delta"],
  ["04-validar-delta"],
  ["05-promover-aprendizaje"],
  ["06-dataverse-gobernado"],
  ["07-dataverse-fronteras"],
  ["08-github-readonly-cierre"],
];
listas.getRange("C3:C8").values = [
  ["Nuevo"],
  ["Activo"],
  ["Preparado"],
  ["Bloqueado"],
  ["Cerrado"],
  ["Versionado"],
];
listas.getRange("D3:D6").values = [["Info"], ["Baja"], ["Media"], ["Alta"]];
listas.getRange("E3:E7").values = [
  ["local_evidence"],
  ["metadata_only"],
  ["prepared_not_executed"],
  ["live_rows_confirmed"],
  ["blocked"],
];
listas.getRange("F3:F6").values = [
  ["local"],
  ["metadata_only"],
  ["live"],
  ["NO_APLICA"],
];
listas.getRange("G3:G6").values = [
  ["cerrado"],
  ["abierto"],
  ["n/a"],
  ["NO_APLICA"],
];
listas.getRange("H3:H6").values = [
  ["pendiente"],
  ["ok"],
  ["n/a"],
  ["NO_APLICA"],
];
styleBody(listas.getRange("A3:H15"));
for (const col of ["A", "B", "C", "D", "E", "F", "G", "H"]) {
  listas.getRange(`${col}:${col}`).format.columnWidthPx = 180;
}

const scans = [
  ["inspect_resumen.ndjson", "Resumen!A1:H14"],
  ["inspect_registro.ndjson", "Registro!A1:O14"],
  ["inspect_alertas.ndjson", "Alertas!A1:F14"],
  ["inspect_listas.ndjson", "Listas!A1:H15"],
];
let combinedInspect = "";
for (const [file, range] of scans) {
  const result = await wb.inspect({ kind: "table", range, include: "values,formulas", tableMaxRows: 20, tableMaxCols: 12 });
  const ndjson = result.ndjson ?? "";
  combinedInspect += ndjson;
  await fs.writeFile(path.join(outputDir, file), ndjson, "utf8");
}
await fs.writeFile(path.join(workbookDir, "control_operativo.xlsx.inspect.ndjson"), combinedInspect, "utf8");

const errorScan = await wb.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 200 },
  summary: "formula error scan",
});
await fs.writeFile(path.join(outputDir, "formula_errors.ndjson"), errorScan.ndjson ?? "", "utf8");

for (const sheetName of ["Resumen", "Registro", "Alertas", "Listas"]) {
  const blob = await wb.render({ sheetName, autoCrop: "all", scale: 1, format: "png" });
  await fs.writeFile(path.join(outputDir, `${sheetName.toLowerCase()}.png`), new Uint8Array(await blob.arrayBuffer()));
}

const manifest = {
  id: "control_operativo_20260615",
  generated_at: new Date().toISOString(),
  root,
  source_files: [
    "operativa/CURRENT.md",
    "operativa/NEXT.md",
    "operativa/BLOCKERS.md",
    "operativa/TRACE.md",
    "operativa/TODO_20260615.md",
    "operativa/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md",
    "operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md",
    "operativa/ACTA_REPOS_SURFACE_GITHUB_20260615.md",
    "outputs/live_repo_review_20260615/READBACK.md",
    "dataverse/GATE.md",
    "dataverse/REGISTRO_BLOQUEOS.md",
    "dataverse/PLAN_SEGUNDA_PASADA.md",
    "dataverse/README.md",
    "dataverse/MAPA.md",
    "playbooks/07-dataverse-fronteras.md",
    "hitos/20260615-hilo-origen-v1/README.md",
    "operativa/MANIFESTS.md",
    "operativa/RETENCION.md",
  ],
  outputs: [
    "workbooks/control_operativo.xlsx",
    "outputs/control_operativo_20260615/control_operativo.xlsx",
    "outputs/control_operativo_20260615/resumen.png",
    "outputs/control_operativo_20260615/registro.png",
    "outputs/control_operativo_20260615/alertas.png",
    "outputs/control_operativo_20260615/listas.png",
  ],
  status: "verified_local_generation",
  live_writes: false,
};
await fs.writeFile(path.join(outputDir, "MANIFEST.json"), `${JSON.stringify(manifest, null, 2)}\n`, "utf8");

const xlsx = await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(path.join(workbookDir, "control_operativo.xlsx"));
await xlsx.save(path.join(outputDir, "control_operativo.xlsx"));
