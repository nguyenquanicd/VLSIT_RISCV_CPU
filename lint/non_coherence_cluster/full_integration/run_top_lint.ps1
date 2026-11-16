param(
  [ValidateSet(2, 4)]
  [int]$HartCount = 4,
  [string]$Python = "python",
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\.."))
$Runner = Join-Path $ProjectRoot "scripts\run_cluster_top_lint.py"
& $Python $Runner --hart-count $HartCount --verilator $Verilator
exit $LASTEXITCODE
