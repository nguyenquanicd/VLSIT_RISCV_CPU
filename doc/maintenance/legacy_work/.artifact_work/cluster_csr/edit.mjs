import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const workbookPath = "C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx";
const outputPath = "C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/.artifact_work/cluster_csr/CSR_reviewed.xlsx";
const outputDir = "C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/.artifact_work/cluster_csr";
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
const originalAxilValues = JSON.stringify(
  workbook.worksheets.getItem("AXIL_QUEUED").getRange("A1:K34").values,
);

const addressMap = workbook.worksheets.getItem("Address_Map");
addressMap.getRange("A5:E12").values = [
  ["CSR defined and reserved offsets", "Defined registers: 0x0000–0x000C, 0x0100–0x017C, 0x0200–0x027C, 0x0300–0x037C", "Approved", "CSR block", "All other offsets in the 4 KiB window are reserved. Reads return zero with DECERR; writes have no register side effect."],
  ["CSR local window", "0x0000–0x0FFF (4 KiB)", "Approved", "Cluster local AXI4-Lite decoder", "The register offsets remain those defined in AXIL_QUEUED."],
  ["LLC service local window", "0x1000–0x1FFF (4 KiB)", "Approved", "Cluster local AXI4-Lite decoder", "Unused offsets are reserved: reads return zero with DECERR and writes have no side effect. Defined offsets follow the pinned axi_llc map."],
  ["Cluster aperture base address", "TBD", "Integration input", "SoC", "The SoC selects the absolute base; map the cluster-local 8 KiB aperture at this base."],
  ["Cluster aperture size", "0x2000 bytes (8 KiB)", "Approved local map", "Cluster / SoC integration", "CSR and LLC service use adjacent 4 KiB windows; the cluster base is 4 KiB aligned."],
  ["CSR / LLC overlap", "Prohibited", "Requirement", "Cluster local decoder", "CSR is at local offset 0x0000; LLC service is at local offset 0x1000."],
  ["LLC scratchpad controls", "Disabled", "Approved", "Cluster", "Runtime SPM mode is excluded; LLC capacity is synthesis-time configuration."],
  ["AXI4-Lite address ownership", "Cluster local decode", "Approved", "Cluster / SoC integration", "The cluster routes CSR and LLC service; the SoC maps the cluster aperture and decodes peripheral MMIO."],
];

const reviewNotes = workbook.worksheets.getItem("Review_Notes");
reviewNotes.getRange("A11:D13").values = [
  ["SoC and cluster address windows", "Local map approved; absolute base TBD", "One cluster AXI4-Lite aperture is 8 KiB, with CSR at 0x0000–0x0FFF and LLC service at 0x1000–0x1FFF. Unused offsets in either window are reserved and return DECERR with zero read data; writes have no side effect.", "User decision; absolute base remains a SoC integration input."],
  ["CCU concurrency decision", "Approved", "Independent 8,192-entry directory; eight tagged transaction contexts by default (configurable 2–16); four directory banks; one probe is serviced per cache at a time; probe uses prepare/commit/abort.", "User decisions recorded 2026-11-07; details in HDS."],
  ["Workbook readiness", "CSR layout approved; event sources pending", "CSR offsets and 4 KiB local windows are approved. Unknown event IDs count zero until source revisions and event wires are audited. The CSR generator may use this workbook.", "User decision; pin and audit CVA6, HPDcache, axi_llc, and CSR generator revisions before event mapping."],
];

workbook.recalculate();

for (const [sheetName, range] of [
  ["Address_Map", "A1:E12"],
  ["Review_Notes", "A1:D13"],
]) {
  const result = await workbook.inspect({
    kind: "table",
    range: `${sheetName}!${range}`,
    include: "values,formulas",
    maxChars: 9000,
    tableMaxRows: 20,
    tableMaxCols: 6,
  });
  console.log(`${sheetName}:\n${result.ndjson}`);
  const preview = await workbook.render({
    sheetName,
    range,
    scale: 1,
    format: "png",
  });
  await fs.writeFile(
    `${outputDir}/${sheetName}_after.png`,
    new Uint8Array(await preview.arrayBuffer()),
  );
}

const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(outputPath);
console.log(`EXPORTED:${outputPath}`);

const savedWorkbook = await SpreadsheetFile.importXlsx(await FileBlob.load(outputPath));
const savedAxilValues = JSON.stringify(
  savedWorkbook.worksheets.getItem("AXIL_QUEUED").getRange("A1:K34").values,
);
if (savedAxilValues !== originalAxilValues) {
  throw new Error("The AXIL_QUEUED register definition changed unexpectedly.");
}
const savedMap = savedWorkbook.worksheets.getItem("Address_Map").getRange("A5:E12").values;
if (savedMap[1][1] !== "0x0000–0x0FFF (4 KiB)" || savedMap[2][1] !== "0x1000–0x1FFF (4 KiB)") {
  throw new Error("The two approved 4 KiB local windows did not survive XLSX export.");
}
const formulaErrors = await savedWorkbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 100 },
  summary: "CSR workbook formula error scan",
});
console.log(`SAVED_WORKBOOK_CHECK:${formulaErrors.ndjson}`);
