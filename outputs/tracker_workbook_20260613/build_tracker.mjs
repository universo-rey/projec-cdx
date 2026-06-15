import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.join(process.cwd(), "outputs", "tracker_workbook_20260613");
await fs.mkdir(outputDir, { recursive: true });

const wb = Workbook.create();
const resumen = wb.worksheets.add("Resumen");
const registro = wb.worksheets.add("Registro");
const listas = wb.worksheets.add("Listas");

function styleTitle(range, fill) {
  range.format = {
    fill,
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: fill },
  };
}

function styleSection(range) {
  range.format = {
    fill: "#0F766E",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#0F766E" },
  };
}

function styleCardLabel(range) {
  range.format = {
    fill: "#155E75",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#155E75" },
  };
}

function styleCardValue(range) {
  range.format = {
    fill: "#ECFEFF",
    font: { bold: true, color: "#0F172A" },
    borders: { preset: "all", style: "thin", color: "#7DD3FC" },
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
  };
}

resumen.showGridLines = false;
resumen.getRange("A1:H1").merge();
resumen.getRange("A1").values = [["Tracker de tareas"]];
styleTitle(resumen.getRange("A1:H1"), "#0F766E");
resumen.getRange("A1:H1").format.rowHeightPx = 36;

resumen.getRange("A2:H2").merge();
resumen.getRange("A2").values = [[
  "Plantilla de seguimiento con resumen, tabla editable y listas desplegables para usar desde el primer dia.",
]];
stylePanel(resumen.getRange("A2:H2"));
resumen.getRange("A2:H2").format.rowHeightPx = 30;

resumen.getRange("A4:H4").merge();
resumen.getRange("A4").values = [["Indicadores"]];
styleSection(resumen.getRange("A4:H4"));

const cards = [
  { label: "Total tareas", formula: "=COUNTA(Registro!$B$6:$B$35)" },
  { label: "Pendientes", formula: '=COUNTIF(Registro!$E$6:$E$35,"Pendiente")' },
  { label: "En progreso", formula: '=COUNTIF(Registro!$E$6:$E$35,"En progreso")' },
  { label: "Bloqueadas", formula: '=COUNTIF(Registro!$E$6:$E$35,"Bloqueado")' },
  { label: "Completadas", formula: '=COUNTIF(Registro!$E$6:$E$35,"Completado")' },
];
const cardSlots = [
  ["A5:B5", "A6:B8"],
  ["C5:D5", "C6:D8"],
  ["E5:F5", "E6:F8"],
  ["G5:H5", "G6:H8"],
  ["A9:B9", "A10:B12"],
];

for (let i = 0; i < cards.length; i += 1) {
  const [labelRange, valueRange] = cardSlots[i];
  resumen.getRange(labelRange).merge();
  resumen.getRange(labelRange.split(":")[0]).values = [[cards[i].label]];
  styleCardLabel(resumen.getRange(labelRange));

  resumen.getRange(valueRange).merge();
  resumen.getRange(valueRange.split(":")[0]).formulas = [[cards[i].formula]];
  styleCardValue(resumen.getRange(valueRange));
  resumen.getRange(valueRange).format.rowHeightPx = 32;
}

resumen.getRange("J4:K4").merge();
resumen.getRange("J4").values = [["Estado", "Cantidad"]];
styleHeader(resumen.getRange("J4:K4"));
resumen.getRange("J5:J8").values = [
  ["Pendiente"],
  ["En progreso"],
  ["Bloqueado"],
  ["Completado"],
];
resumen.getRange("K5:K8").formulas = [
  ['=COUNTIF(Registro!$E$6:$E$35,J5)'],
  ['=COUNTIF(Registro!$E$6:$E$35,J6)'],
  ['=COUNTIF(Registro!$E$6:$E$35,J7)'],
  ['=COUNTIF(Registro!$E$6:$E$35,J8)'],
];
styleBody(resumen.getRange("J5:K8"));
resumen.getRange("K5:K8").format.numberFormat = "0";

const statusChart = resumen.charts.add("bar", resumen.getRange("J4:K8"));
statusChart.title = "Tareas por estado";
statusChart.hasLegend = false;
statusChart.setPosition("J10", "P24");
statusChart.xAxis = { axisType: "textAxis" };
statusChart.yAxis = { numberFormatCode: "0" };

resumen.getRange("A11:H11").merge();
resumen.getRange("A11").values = [["Uso rapido"]];
styleSection(resumen.getRange("A11:H11"));

resumen.getRange("A12:H14").merge();
resumen.getRange("A12").values = [[
  "Cargue una tarea por fila en Registro.\nUse Estado y Prioridad con las listas desplegables.\nEl resumen se actualiza solo.",
]];
stylePanel(resumen.getRange("A12:H14"));
resumen.getRange("A12:H14").format.rowHeightPx = 44;

resumen.getRange("A16:H16").merge();
resumen.getRange("A16").values = [["Sugerencia"]];
styleSection(resumen.getRange("A16:H16"));

resumen.getRange("A17:H18").merge();
resumen.getRange("A17").values = [[
  "Si queres, esta misma base se puede convertir despues en seguimiento de ventas, incidencias o proyectos con cambios minimos.",
]];
stylePanel(resumen.getRange("A17:H18"));
resumen.getRange("A17:H18").format.rowHeightPx = 32;

for (const col of ["A", "B", "C", "D", "E", "F", "G", "H"]) {
  resumen.getRange(`${col}:${col}`).format.columnWidthPx = 140;
}
resumen.getRange("A:A").format.columnWidthPx = 120;
resumen.getRange("B:B").format.columnWidthPx = 200;
resumen.getRange("C:C").format.columnWidthPx = 140;
resumen.getRange("D:D").format.columnWidthPx = 160;
resumen.getRange("E:E").format.columnWidthPx = 130;
resumen.getRange("F:F").format.columnWidthPx = 110;
resumen.getRange("G:G").format.columnWidthPx = 100;
resumen.getRange("H:H").format.columnWidthPx = 220;

registro.showGridLines = false;
registro.getRange("A1:H1").merge();
registro.getRange("A1").values = [["Registro de tareas"]];
styleTitle(registro.getRange("A1:H1"), "#155E75");
registro.getRange("A1:H1").format.rowHeightPx = 36;

registro.getRange("A2:H2").merge();
registro.getRange("A2").values = [[
  "Una fila por tarea. El rango queda listo para filtrar, ordenar y completar sin rearmar la planilla.",
]];
stylePanel(registro.getRange("A2:H2"));
registro.getRange("A2:H2").format.rowHeightPx = 30;

registro.getRange("A4:H4").merge();
registro.getRange("A4").values = [["Tabla principal"]];
styleSection(registro.getRange("A4:H4"));

registro.getRange("A5:H5").values = [[
  "Fecha",
  "Tarea",
  "Responsable",
  "Proyecto",
  "Estado",
  "Prioridad",
  "Vencimiento",
  "Notas",
]];
styleHeader(registro.getRange("A5:H5"));

registro.getRange("A6:H35").values = Array.from({ length: 30 }, () => [null, null, null, null, null, null, null, null]);
styleBody(registro.getRange("A6:H35"));

registro.tables.add("A5:H35", true, "TareasTable");

registro.getRange("A6:A35").format.numberFormat = "yyyy-mm-dd";
registro.getRange("G6:G35").format.numberFormat = "yyyy-mm-dd";

registro.dataValidations.add({
  range: "E6:E35",
  rule: { type: "list", formula1: "Listas!$A$3:$A$6" },
});
registro.dataValidations.add({
  range: "F6:F35",
  rule: { type: "list", formula1: "Listas!$B$3:$B$5" },
});

registro.freezePanes.freezeRows(5);
registro.getRange("A:A").format.columnWidthPx = 110;
registro.getRange("B:B").format.columnWidthPx = 220;
registro.getRange("C:C").format.columnWidthPx = 140;
registro.getRange("D:D").format.columnWidthPx = 140;
registro.getRange("E:E").format.columnWidthPx = 120;
registro.getRange("F:F").format.columnWidthPx = 110;
registro.getRange("G:G").format.columnWidthPx = 110;
registro.getRange("H:H").format.columnWidthPx = 240;

listas.showGridLines = false;
listas.getRange("A1:C1").merge();
listas.getRange("A1").values = [["Listas de apoyo"]];
styleTitle(listas.getRange("A1:C1"), "#0F766E");

listas.getRange("A2:C2").values = [["Estados", "Prioridades", "Proyectos"]];
styleSection(listas.getRange("A2:C2"));

listas.getRange("A3:A6").values = [
  ["Pendiente"],
  ["En progreso"],
  ["Bloqueado"],
  ["Completado"],
];
listas.getRange("B3:B5").values = [
  ["Alta"],
  ["Media"],
  ["Baja"],
];
listas.getRange("C3:C7").values = [
  ["General"],
  ["Proyecto A"],
  ["Proyecto B"],
  ["Soporte"],
  ["Otro"],
];
styleBody(listas.getRange("A3:C7"));

listas.getRange("A:A").format.columnWidthPx = 150;
listas.getRange("B:B").format.columnWidthPx = 150;
listas.getRange("C:C").format.columnWidthPx = 150;

const inspectResumen = await wb.inspect({
  kind: "table",
  range: "Resumen!A1:P24",
  include: "values,formulas",
  tableMaxRows: 24,
  tableMaxCols: 16,
});
await fs.writeFile(path.join(outputDir, "inspect_resumen.ndjson"), inspectResumen.ndjson ?? "", "utf8");

const inspectRegistro = await wb.inspect({
  kind: "table",
  range: "Registro!A1:H12",
  include: "values,formulas",
  tableMaxRows: 12,
  tableMaxCols: 12,
});
await fs.writeFile(path.join(outputDir, "inspect_registro.ndjson"), inspectRegistro.ndjson ?? "", "utf8");

const inspectListas = await wb.inspect({
  kind: "table",
  range: "Listas!A1:C10",
  include: "values,formulas",
  tableMaxRows: 10,
  tableMaxCols: 6,
});
await fs.writeFile(path.join(outputDir, "inspect_listas.ndjson"), inspectListas.ndjson ?? "", "utf8");

const errorScan = await wb.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 200 },
  summary: "formula error scan",
});
await fs.writeFile(path.join(outputDir, "formula_errors.ndjson"), errorScan.ndjson ?? "", "utf8");

for (const sheetName of ["Resumen", "Registro", "Listas"]) {
  const blob = await wb.render({
    sheetName,
    autoCrop: "all",
    scale: 1,
    format: "png",
  });
  await fs.writeFile(path.join(outputDir, `${sheetName.toLowerCase()}.png`), new Uint8Array(await blob.arrayBuffer()));
}

const xlsx = await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(path.join(outputDir, "tracker_workbook.xlsx"));
