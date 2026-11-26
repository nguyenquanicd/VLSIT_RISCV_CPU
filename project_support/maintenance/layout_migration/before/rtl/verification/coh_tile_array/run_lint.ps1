param(
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}
$Top = "tb_m_vlsit_riscv_coh_tile_array"
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\full_integration"))
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

foreach ($HartCount in @(2, 4)) {
  $LogPath = Join-Path $ReportDir "coh_tile_array_${HartCount}h_lint.log"
  Set-Content -LiteralPath $LogPath -Value ""
  $PreviousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & $Verilator --lint-only --timing -Wall -Wno-fatal --top-module $Top `
    "-GPARA_CPU_NUM=$HartCount" -f filelist.f "${Top}.sv" 2>&1 |
    Tee-Object -FilePath $LogPath -Append
  $ToolExit = $LASTEXITCODE
  $ErrorActionPreference = $PreviousErrorActionPreference
  if ($ToolExit -ne 0) { throw "$HartCount-hart lint failed: $ToolExit" }
}
