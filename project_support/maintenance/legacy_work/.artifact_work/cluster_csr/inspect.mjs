import fs from "node:fs/promises";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const workbookPath = "C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx";
const outputDir = "C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/.artifact_work/cluster_csr";
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));

const summary = await workbook.inspect({
  kind: "workbook,sheet,table",
  maxChars: 5000,
  tableMaxRows: 8,
  tableMaxCols: 8,
});
console.log(summary.ndjson);

for (const [sheetName, range] of [
  ["AXIL_QUEUED", "A1:K34"],
  ["Address_Map", "A1:E12"],
  ["Review_Notes", "A1:D13"],
]) {
  const inspect = await workbook.inspect({
    kind: "table",
    range: `${sheetName}!${range}`,
    include: "values,formulas",
    maxChars: 8000,
    tableMaxRows: 40,
    tableMaxCols: 12,
  });
  console.log(`${sheetName}:\n${inspect.ndjson}`);
  const preview = await workbook.render({
    sheetName,
    range,
    scale: 1,
    format: "png",
  });
  await fs.writeFile(
    `${outputDir}/${sheetName}_before.png`,
    new Uint8Array(await preview.arrayBuffer()),
  );
}
