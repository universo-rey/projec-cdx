import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.join(process.cwd(), "outputs", "tracker_general_20260613");
await fs.mkdir(outputDir, { recursive: true });

const wb = Workbook.create();
const inicio = wb.worksheets.add("Inicio");
const registro = wb.worksheets.add("Registro");
const listas = wb.worksheets.add("Listas");

function title(range, fill) {
  range.format = {
    fill,
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: fill },
  };
}

function section(range) {
  range.format = {
    fill: "#0F766E",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#0F766E" },
  };
}

function panel(range) {
  range.format = {
    fill: "#F8FAFC",
    font: { color: "#0F172A" },
    borders: { preset: "all", style: "thin", color: "#CBD5E1" },
    wrapText: true,
  };
}

function cardLabel(range) {
  range.format = {
    fill: "#155E75",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#155E75" },
  };
}

function cardValue(range) {
  range.format = {
    fill: "#ECFEFF",
    font: { bold: true, color: "#0F172A" },
    borders: { preset: "all", style: "thin", color: "#7DD3FC" },
  };
}

function header(range) {
  range.format = {
    fill: "#0F766E",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#0F766E" },
  };
}

function body(range) {
  range.format = {
    fill: "#FFFFFF",
    borders: { preset: "all", style: "thin", color: "#E2E8F0" },
  };
}

inicio.showGridLines = false;
inicio.getRange("A1:H1").merge();
inicio.getRange("A1").values = [["Tracker general"]];
title(inicio.getRange("A1:H1"), "#0F766E");
inicio.getRange("A1:H1").format.rowHeightPx = 36;

inicio.getRange("A2:H2").merge();
inicio.getRange("A2").values = [[
  "Plantilla base para seguimiento operativo, tareas, incidencias o pendientes, lista para usar y adaptar.",
]];
panel(inicio.getRange("A2:H2"));
inicio.getRange("A2:H2").format.rowHeightPx = 30;

inicio.getRange("A4:H4").merge();
inicio.getRange("A4").values = [["Resumen"]];
section(inicio.getRange("A4:H4"));

const metrics = [
  { label: "Total", formula: "=COUNTA(Registro!$B$6:$B$40)" },
  { label: "Pendientes", formula: '=COUNTIF(Registro!$E$6:$E$40,"Pendiente")' },
  { label: "En progreso", formula: '=COUNTIF(Registro!$E$6:$E$40,"En progreso")' },
  { label: "Bloqueados", formula: '=COUNTIF(Registro!$E$6:$E$40,"Bloqueado")' },
];
const positions = [
  ["A5:B5", "A6:B8"],
  ["C5:D5", "C6:D8"],
  ["E5:F5", "E6:F8"],
  ["G5:H5", "G6:H8"],
];

for (let i = 0; i < metrics.length; i += 1) {
  const [labelRange, valueRange] = positions[i];
  inicio.getRange(labelRange).merge();
  inicio.getRange(labelRange.split(":")[0]).values = [[metrics[i].label]];
  cardLabel(inicio.getRange(labelRange));

  inicio.getRange(valueRange).merge();
  inicio.getRange(valueRange.split(":")[0]).formulas = [[metrics[i].formula]];
  cardValue(inicio.getRange(valueRange));
  inicio.getRange(valueRange).format.rowHeightPx = 32;
}

inicio.getRange("J4:K4").merge();
inicio.getRange("J4").values = [["Estado", "Cantidad"]];
header(inicio.getRange("J4:K4"));
inicio.getRange("J5:J8").values = [
  ["Pendiente"],
  ["En progreso"],
  ["Bloqueado"],
  ["Completado"],
];
inicio.getRange("K5:K8").formulas = [
  ['=COUNTIF(Registro!$E$6:$E$40,J5)'],
  ['=COUNTIF(Registro!$E$6:$E$40,J6)'],
  ['=COUNTIF(Registro!$E$6:$E$40,J7)'],
  ['=COUNTIF(Registro!$E$6:$E$40,J8)'],
];
body(inicio.getRange("J5:K8"));
inicio.getRange("K5:K8").format.numberFormat = "0";

const statusChart = inicio.charts.add("bar", inicio.getRange("J4:K8"));
statusChart.title = "Tareas por estado";
statusChart.hasLegend = false;
statusChart.setPosition("J10", "P24");
statusChart.xAxis = { axisType: "textAxis" };
statusChart.yAxis = { numberFormatCode: "0" };

inicio.getRange("A10:H10").merge();
inicio.getRange("A10").values = [["Uso rapido"]];
section(inicio.getRange("A10:H10"));

inicio.getRange("A11:H13").merge();
inicio.getRange("A11").values = [[
  "1. Complete una fila por caso en Registro.\n2. Use las listas para Area, Estado y Prioridad.\n3. El resumen se actualiza solo.",
]];
panel(inicio.getRange("A11:H13"));
inicio.getRange("A11:H13").format.rowHeightPx = 44;

inicio.getRange("A15:H15").merge();
inicio.getRange("A15").values = [["Sugerencia"]];
section(inicio.getRange("A15:H15"));

inicio.getRange("A16:H17").merge();
inicio.getRange("A16").values = [[
  "Si despues queres, esta base se puede convertir en tracker de proyectos, soporte, ventas o inventario sin rehacer la estructura.",
]];
panel(inicio.getRange("A16:H17"));
inicio.getRange("A16:H17").format.rowHeightPx = 32;

for (const col of ["A", "B", "C", "D", "E", "F", "G", "H"]) {
  inicio.getRange(`${col}:${col}`).format.columnWidthPx = 140;
}
inicio.getRange("A:A").format.columnWidthPx = 120;
inicio.getRange("B:B").format.columnWidthPx = 120;
inicio.getRange("C:C").format.columnWidthPx = 120;
inicio.getRange("D:D").format.columnWidthPx = 120;
inicio.getRange("E:E").format.columnWidthPx = 120;
inicio.getRange("F:F").format.columnWidthPx = 120;
inicio.getRange("G:G").format.columnWidthPx = 120;
inicio.getRange("H:H").format.columnWidthPx = 120;
inicio.getRange("J:J").format.columnWidthPx = 140;
inicio.getRange("K:K").format.columnWidthPx = 100;

registro.showGridLines = false;
registro.getRange("A1:I1").merge();
registro.getRange("A1").values = [["Registro"]];
title(registro.getRange("A1:I1"), "#155E75");
registro.getRange("A1:I1").format.rowHeightPx = 36;

registro.getRange("A2:I2").merge();
registro.getRange("A2").values = [[
  "Una fila por item. La tabla está preparada para filtrar, ordenar, completar y revisar rápido.",
]];
panel(registro.getRange("A2:I2"));
registro.getRange("A2:I2").format.rowHeightPx = 30;

registro.getRange("A4:I4").merge();
registro.getRange("A4").values = [["Tabla de seguimiento"]];
section(registro.getRange("A4:I4"));

registro.getRange("A5:I5").values = [[
  "Fecha",
  "Item",
  "Area",
  "Responsable",
  "Estado",
  "Prioridad",
  "Vencimiento",
  "Avance",
  "Notas",
]];
header(registro.getRange("A5:I5"));

registro.getRange("A6:I40").values = Array.from({ length: 35 }, () => [null, null, null, null, null, null, null, null, null]);
body(registro.getRange("A6:I40"));

registro.tables.add("A5:I40", true, "TrackerTable");

registro.getRange("A6:A40").format.numberFormat = "yyyy-mm-dd";
registro.getRange("G6:G40").format.numberFormat = "yyyy-mm-dd";
registro.getRange("H6:H40").format.numberFormat = "0";

registro.dataValidations.add({
  range: "C6:C40",
  rule: { type: "list", formula1: "Listas!$C$3:$C$8" },
});
registro.dataValidations.add({
  range: "E6:E40",
  rule: { type: "list", formula1: "Listas!$A$3:$A$6" },
});
registro.dataValidations.add({
  range: "F6:F40",
  rule: { type: "list", formula1: "Listas!$B$3:$B$5" },
});
registro.dataValidations.add({
  range: "H6:H40",
  rule: { type: "whole", operator: "between", formula1: 0, formula2: 100 },
});

registro.freezePanes.freezeRows(5);
registro.getRange("A:A").format.columnWidthPx = 110;
registro.getRange("B:B").format.columnWidthPx = 230;
registro.getRange("C:C").format.columnWidthPx = 150;
registro.getRange("D:D").format.columnWidthPx = 150;
registro.getRange("E:E").format.columnWidthPx = 120;
registro.getRange("F:F").format.columnWidthPx = 110;
registro.getRange("G:G").format.columnWidthPx = 110;
registro.getRange("H:H").format.columnWidthPx = 100;
registro.getRange("I:I").format.columnWidthPx = 220;

listas.showGridLines = false;
listas.getRange("A1:C1").merge();
listas.getRange("A1").values = [["Listas de apoyo"]];
title(listas.getRange("A1:C1"), "#0F766E");

listas.getRange("A2:C2").values = [["Estados", "Prioridades", "Areas"]];
section(listas.getRange("A2:C2"));

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
listas.getRange("C3:C8").values = [
  ["General"],
  ["Operaciones"],
  ["Soporte"],
  ["Proyecto"],
  ["Comercial"],
  ["Otro"],
];
body(listas.getRange("A3:C8"));
listas.getRange("A:A").format.columnWidthPx = 150;
listas.getRange("B:B").format.columnWidthPx = 150;
listas.getRange("C:C").format.columnWidthPx = 150;

const inspectInicio = await wb.inspect({
  kind: "table",
  range: "Inicio!A1:H17",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
});
await fs.writeFile(path.join(outputDir, "inspect_inicio.ndjson"), inspectInicio.ndjson ?? "", "utf8");

const inspectRegistro = await wb.inspect({
  kind: "table",
  range: "Registro!A1:I14",
  include: "values,formulas",
  tableMaxRows: 14,
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

for (const sheetName of ["Inicio", "Registro", "Listas"]) {
  const blob = await wb.render({
    sheetName,
    autoCrop: "all",
    scale: 1,
    format: "png",
  });
  await fs.writeFile(path.join(outputDir, `${sheetName.toLowerCase()}.png`), new Uint8Array(await blob.arrayBuffer()));
}

const xlsx = await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(path.join(outputDir, "tracker.xlsx"));
