import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.join(process.cwd(), "outputs", "inicio_workbook_20260613");
await fs.mkdir(outputDir, { recursive: true });

const wb = Workbook.create();
const inicio = wb.worksheets.add("Inicio");
const registro = wb.worksheets.add("Registro");
const listas = wb.worksheets.add("Listas");

function styleTitle(range, fill) {
  range.format = {
    fill,
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: fill },
  };
}

function styleBand(range) {
  range.format = {
    fill: "#0F766E",
    font: { bold: true, color: "#FFFFFF" },
    borders: { preset: "all", style: "thin", color: "#0F766E" },
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

inicio.showGridLines = false;
inicio.getRange("A1:H1").merge();
inicio.getRange("A1").values = [["Excel de inicio"]];
styleTitle(inicio.getRange("A1:H1"), "#0F766E");
inicio.getRange("A1:H1").format.rowHeightPx = 36;

inicio.getRange("A2:H2").merge();
inicio.getRange("A2").values = [[
  "Base simple para arrancar rapido: hoja de inicio, tabla editable y listas desplegables.",
]];
stylePanel(inicio.getRange("A2:H2"));
inicio.getRange("A2:H2").format.rowHeightPx = 30;

inicio.getRange("A4:H4").merge();
inicio.getRange("A4").values = [["Indicadores"]];
styleBand(inicio.getRange("A4:H4"));

const cards = [
  { label: "Registros", formula: "=COUNTA(Registro!$B$6:$B$35)" },
  { label: "Pendientes", formula: '=COUNTIF(Registro!$E$6:$E$35,"Pendiente")' },
  { label: "En progreso", formula: '=COUNTIF(Registro!$E$6:$E$35,"En progreso")' },
  { label: "Completados", formula: '=COUNTIF(Registro!$E$6:$E$35,"Completado")' },
];
const slots = [
  ["A5:B5", "A6:B8"],
  ["C5:D5", "C6:D8"],
  ["E5:F5", "E6:F8"],
  ["G5:H5", "G6:H8"],
];

for (let i = 0; i < cards.length; i += 1) {
  const [labelRange, valueRange] = slots[i];
  inicio.getRange(labelRange).merge();
  inicio.getRange(labelRange.split(":")[0]).values = [[cards[i].label]];
  styleCardLabel(inicio.getRange(labelRange));

  inicio.getRange(valueRange).merge();
  inicio.getRange(valueRange.split(":")[0]).formulas = [[cards[i].formula]];
  styleCardValue(inicio.getRange(valueRange));
  inicio.getRange(valueRange).format.rowHeightPx = 32;
}

inicio.getRange("A10:H10").merge();
inicio.getRange("A10").values = [["Como usarlo"]];
styleBand(inicio.getRange("A10:H10"));

inicio.getRange("A11:H13").merge();
inicio.getRange("A11").values = [[
  "1. Cargue cada fila en Registro.\n2. Use las listas desplegables para Estado y Prioridad.\n3. El resumen se actualiza solo.",
]];
stylePanel(inicio.getRange("A11:H13"));
inicio.getRange("A11:H13").format.rowHeightPx = 44;

inicio.getRange("A15:H15").merge();
inicio.getRange("A15").values = [["Sugerencia"]];
styleBand(inicio.getRange("A15:H15"));

inicio.getRange("A16:H17").merge();
inicio.getRange("A16").values = [[
  "Si despues queres, esta misma base la convierto en tracker, inventario, control operativo o presupuesto.",
]];
stylePanel(inicio.getRange("A16:H17"));
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

registro.showGridLines = false;
registro.getRange("A1:H1").merge();
registro.getRange("A1").values = [["Registro"]];
styleTitle(registro.getRange("A1:H1"), "#155E75");

registro.getRange("A2:H2").merge();
registro.getRange("A2").values = [[
  "Una fila por elemento. Esta tabla queda lista para filtrar, ordenar y completar.",
]];
stylePanel(registro.getRange("A2:H2"));

registro.getRange("A4:H4").merge();
registro.getRange("A4").values = [["Tabla"]];
styleBand(registro.getRange("A4:H4"));

registro.getRange("A5:H5").values = [[
  "Fecha",
  "Item",
  "Categoria",
  "Responsable",
  "Estado",
  "Prioridad",
  "Monto",
  "Notas",
]];
styleHeader(registro.getRange("A5:H5"));

registro.getRange("A6:H35").values = Array.from({ length: 30 }, () => [null, null, null, null, null, null, null, null]);
styleBody(registro.getRange("A6:H35"));

registro.tables.add("A5:H35", true, "RegistroBase");
registro.getRange("A6:A35").format.numberFormat = "yyyy-mm-dd";
registro.getRange("G6:G35").format.numberFormat = "#,##0.00";

registro.dataValidations.add({
  range: "D6:D35",
  rule: { type: "list", formula1: "Listas!$B$3:$B$5" },
});
registro.dataValidations.add({
  range: "E6:E35",
  rule: { type: "list", formula1: "Listas!$A$3:$A$6" },
});
registro.dataValidations.add({
  range: "F6:F35",
  rule: { type: "list", formula1: "Listas!$C$3:$C$5" },
});

registro.freezePanes.freezeRows(5);
registro.getRange("A:A").format.columnWidthPx = 110;
registro.getRange("B:B").format.columnWidthPx = 220;
registro.getRange("C:C").format.columnWidthPx = 140;
registro.getRange("D:D").format.columnWidthPx = 140;
registro.getRange("E:E").format.columnWidthPx = 120;
registro.getRange("F:F").format.columnWidthPx = 110;
registro.getRange("G:G").format.columnWidthPx = 110;
registro.getRange("H:H").format.columnWidthPx = 220;

listas.showGridLines = false;
listas.getRange("A1:C1").merge();
listas.getRange("A1").values = [["Listas"]];
styleTitle(listas.getRange("A1:C1"), "#0F766E");

listas.getRange("A2:C2").values = [["Estados", "Responsables", "Prioridades"]];
styleBand(listas.getRange("A2:C2"));

listas.getRange("A3:A6").values = [
  ["Pendiente"],
  ["En progreso"],
  ["Bloqueado"],
  ["Completado"],
];
listas.getRange("B3:B5").values = [
  ["Persona 1"],
  ["Persona 2"],
  ["Persona 3"],
];
listas.getRange("C3:C5").values = [
  ["Alta"],
  ["Media"],
  ["Baja"],
];
styleBody(listas.getRange("A3:C6"));

listas.getRange("A:A").format.columnWidthPx = 150;
listas.getRange("B:B").format.columnWidthPx = 150;
listas.getRange("C:C").format.columnWidthPx = 150;

const inspectInicio = await wb.inspect({
  kind: "table",
  range: "Inicio!A1:H18",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
});
await fs.writeFile(path.join(outputDir, "inspect_inicio.ndjson"), inspectInicio.ndjson ?? "", "utf8");

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
  range: "Listas!A1:C8",
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
await xlsx.save(path.join(outputDir, "excel_inicio.xlsx"));
