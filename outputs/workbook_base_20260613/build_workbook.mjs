import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.join(process.cwd(), "outputs", "workbook_base_20260613");
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

function styleTableHeader(range) {
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

// Resumen sheet
resumen.showGridLines = false;
resumen.getRange("A1:H1").merge();
resumen.getRange("A1").values = [["Workbook base"]];
styleTitle(resumen.getRange("A1:H1"), "#0F766E");
resumen.getRange("A1:H1").format.rowHeightPx = 36;

resumen.getRange("A2:H2").merge();
resumen.getRange("A2").values = [[
  "Plantilla general para capturar datos, usar listas desplegables y ver un resumen simple sin tener que empezar desde cero.",
]];
stylePanel(resumen.getRange("A2:H2"));
resumen.getRange("A2:H2").format.rowHeightPx = 32;

resumen.getRange("A4:H4").merge();
resumen.getRange("A4").values = [["Indicadores"]];
styleSection(resumen.getRange("A4:H4"));
resumen.getRange("A4:H4").format.rowHeightPx = 24;

const cardDefs = [
  { label: "Total de registros", valueFormula: "=COUNTA(Registro!$A$6:$A$30)" },
  { label: "Pendientes", valueFormula: '=COUNTIF(Registro!$E$6:$E$30,"Pendiente")' },
  { label: "En progreso", valueFormula: '=COUNTIF(Registro!$E$6:$E$30,"En progreso")' },
  { label: "Completados", valueFormula: '=COUNTIF(Registro!$E$6:$E$30,"Completado")' },
];
const cardRanges = [
  ["A5:B5", "A6:B8"],
  ["C5:D5", "C6:D8"],
  ["E5:F5", "E6:F8"],
  ["G5:H5", "G6:H8"],
];

for (let i = 0; i < cardDefs.length; i += 1) {
  const [labelRange, valueRange] = cardRanges[i];
  resumen.getRange(labelRange).merge();
  resumen.getRange(labelRange.split(":")[0]).values = [[cardDefs[i].label]];
  styleCardLabel(resumen.getRange(labelRange));
  resumen.getRange(labelRange).format.rowHeightPx = 24;

  resumen.getRange(valueRange).merge();
  resumen.getRange(valueRange.split(":")[0]).formulas = [[cardDefs[i].valueFormula]];
  styleCardValue(resumen.getRange(valueRange));
  resumen.getRange(valueRange).format.rowHeightPx = 32;
}

resumen.getRange("A10:H10").merge();
resumen.getRange("A10").values = [["Uso rapido"]];
styleSection(resumen.getRange("A10:H10"));
resumen.getRange("A10:H10").format.rowHeightPx = 24;

resumen.getRange("A11:H12").merge();
resumen.getRange("A11").values = [[
  "Cargue datos en Registro.\nUse Estado, Prioridad y Categoria.\nEl resumen se actualiza solo.",
]];
stylePanel(resumen.getRange("A11:H12"));
resumen.getRange("A11:H12").format.rowHeightPx = 44;

resumen.getRange("A16:H16").merge();
resumen.getRange("A16").values = [["Sugerencia"]];
styleSection(resumen.getRange("A16:H16"));
resumen.getRange("A16:H16").format.rowHeightPx = 24;

resumen.getRange("A17:H17").merge();
resumen.getRange("A17").values = [[
  "Si luego queres adaptarlo a otro uso, puedo convertirlo en tracker, presupuesto o control de tareas sin perder la estructura.",
]];
stylePanel(resumen.getRange("A17:H17"));
resumen.getRange("A17:H17").format.rowHeightPx = 24;

resumen.getRange("A:A").format.columnWidthPx = 140;
resumen.getRange("B:B").format.columnWidthPx = 140;
resumen.getRange("C:C").format.columnWidthPx = 140;
resumen.getRange("D:D").format.columnWidthPx = 140;
resumen.getRange("E:E").format.columnWidthPx = 140;
resumen.getRange("F:F").format.columnWidthPx = 140;
resumen.getRange("G:G").format.columnWidthPx = 140;
resumen.getRange("H:H").format.columnWidthPx = 140;

// Registro sheet
registro.showGridLines = false;
registro.getRange("A1:H1").merge();
registro.getRange("A1").values = [["Registro de datos"]];
styleTitle(registro.getRange("A1:H1"), "#155E75");
registro.getRange("A1:H1").format.rowHeightPx = 36;

registro.getRange("A2:H2").merge();
registro.getRange("A2").values = [[
  "Complete una fila por elemento. Los campos con lista desplegable ya vienen preparados para acelerar la carga.",
]];
stylePanel(registro.getRange("A2:H2"));
registro.getRange("A2:H2").format.rowHeightPx = 32;

registro.getRange("A4:H4").merge();
registro.getRange("A4").values = [["Tabla de trabajo"]];
styleSection(registro.getRange("A4:H4"));
registro.getRange("A4:H4").format.rowHeightPx = 24;

const headerValues = [[
  "Fecha",
  "Categoria",
  "Elemento",
  "Responsable",
  "Estado",
  "Prioridad",
  "Monto",
  "Notas",
]];
registro.getRange("A5:H5").values = headerValues;
styleTableHeader(registro.getRange("A5:H5"));

const blankRows = Array.from({ length: 25 }, () => [null, null, null, null, null, null, null, null]);
registro.getRange("A6:H30").values = blankRows;
styleBody(registro.getRange("A6:H30"));

const table = registro.tables.add("A5:H30", true, "RegistroTable");
table.showFilterButton = true;

registro.getRange("A6:A30").format.numberFormat = "yyyy-mm-dd";
registro.getRange("G6:G30").format.numberFormat = "#,##0.00";

registro.dataValidations.add({
  range: "B6:B30",
  rule: { type: "list", formula1: "Listas!$C$3:$C$7" },
});
registro.dataValidations.add({
  range: "E6:E30",
  rule: { type: "list", formula1: "Listas!$A$3:$A$6" },
});
registro.dataValidations.add({
  range: "F6:F30",
  rule: { type: "list", formula1: "Listas!$B$3:$B$5" },
});

registro.freezePanes.freezeRows(5);
registro.getRange("A:A").format.columnWidthPx = 110;
registro.getRange("B:B").format.columnWidthPx = 120;
registro.getRange("C:C").format.columnWidthPx = 180;
registro.getRange("D:D").format.columnWidthPx = 140;
registro.getRange("E:E").format.columnWidthPx = 120;
registro.getRange("F:F").format.columnWidthPx = 110;
registro.getRange("G:G").format.columnWidthPx = 120;
registro.getRange("H:H").format.columnWidthPx = 240;

// Listas sheet
listas.showGridLines = false;
listas.getRange("A1:C1").merge();
listas.getRange("A1").values = [["Listas de apoyo"]];
styleTitle(listas.getRange("A1:C1"), "#0F766E");
listas.getRange("A1:C1").format.rowHeightPx = 32;

listas.getRange("A2").values = [["Estados"]];
listas.getRange("B2").values = [["Prioridades"]];
listas.getRange("C2").values = [["Categorias"]];
styleSection(listas.getRange("A2:C2"));

listas.getRange("A3:A6").values = [
  ["Pendiente"],
  ["En progreso"],
  ["Completado"],
  ["Bloqueado"],
];
listas.getRange("B3:B5").values = [
  ["Alta"],
  ["Media"],
  ["Baja"],
];
listas.getRange("C3:C7").values = [
  ["General"],
  ["Proyecto"],
  ["Soporte"],
  ["Operacion"],
  ["Otro"],
];

styleBody(listas.getRange("A3:C7"));
listas.getRange("A1:C7").format.rowHeightPx = 24;
listas.getRange("A:A").format.columnWidthPx = 150;
listas.getRange("B:B").format.columnWidthPx = 150;
listas.getRange("C:C").format.columnWidthPx = 150;

// Verification and export
const summaryInspect = await wb.inspect({
  kind: "table",
  range: "Resumen!A1:H20",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
});
await fs.writeFile(path.join(outputDir, "inspect_resumen.ndjson"), summaryInspect.ndjson ?? "", "utf8");

const registroInspect = await wb.inspect({
  kind: "table",
  range: "Registro!A1:H12",
  include: "values,formulas",
  tableMaxRows: 12,
  tableMaxCols: 12,
});
await fs.writeFile(path.join(outputDir, "inspect_registro.ndjson"), registroInspect.ndjson ?? "", "utf8");

const listasInspect = await wb.inspect({
  kind: "table",
  range: "Listas!A1:C10",
  include: "values,formulas",
  tableMaxRows: 10,
  tableMaxCols: 6,
});
await fs.writeFile(path.join(outputDir, "inspect_listas.ndjson"), listasInspect.ndjson ?? "", "utf8");

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
await xlsx.save(path.join(outputDir, "workbook_base.xlsx"));
