param(
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe",
  [string]$VerilatorRoot = "C:\Tools\oss-cad-suite\share\verilator",
  [string]$Cxx = "C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe",
  [string]$BuildRoot = "C:\HQuan\.test_tmp\riscv_cmo_controller_mutation"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$Top = "tb_m_vlsit_riscv_cmo_controller"
$RunTag = "$(Get-Date -Format 'yyyyMMddHHmmssfff')"
$BuildDir = [System.IO.Path]::GetFullPath("${BuildRoot}_${RunTag}")
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\cmo_controller"))
$RtlSource = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\vlsit\m_vlsit_riscv_cmo_controller.sv"))
$TbSource = Join-Path $PSScriptRoot "tb_m_vlsit_riscv_cmo_controller.sv"
$MutantRtl = Join-Path $BuildDir "m_vlsit_riscv_cmo_controller.sv"
$TbCopy = Join-Path $BuildDir "tb_m_vlsit_riscv_cmo_controller.sv"
$RuntimeInclude = Join-Path $VerilatorRoot "include"
$LintLog = Join-Path $ReportDir "cmo_controller_mutation_lint.log"
$ModelLog = Join-Path $ReportDir "cmo_controller_mutation_model.log"
$BuildLog = Join-Path $ReportDir "cmo_controller_mutation_build.log"
$SimulationLog = Join-Path $ReportDir "cmo_controller_mutation_sim.log"
$ExePath = Join-Path $BuildDir "$Top.exe"

New-Item -ItemType Directory -Force -Path $BuildDir, $ReportDir | Out-Null
$env:VERILATOR_ROOT = $VerilatorRoot
$RtlText = [System.IO.File]::ReadAllText($RtlSource)
$ExpectedLine = "o_ccu_begin_wback_en = (32'(reg_cmo_op) != LPARA_CMO_INVAL);"
if (-not $RtlText.Contains($ExpectedLine)) {
  throw "Mutation anchor not found; refusing to alter a different RTL expression"
}
$MutantText = $RtlText.Replace($ExpectedLine, "o_ccu_begin_wback_en = 1'b1; // injected mutation")
[System.IO.File]::WriteAllText($MutantRtl, $MutantText, [System.Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath $TbSource -Destination $TbCopy

& $Verilator --lint-only --timing -Wall -Wno-fatal --top-module $Top `
  -GPARA_CPU_NUM=2 $MutantRtl $TbCopy *> $LintLog
if ($LASTEXITCODE -ne 0) { throw "Mutated CMO testbench lint failed before simulation" }

& $Verilator --cc --main --timing -Wall -Wno-fatal --CFLAGS "-DVL_TIME_CONTEXT" `
  --top-module $Top -GPARA_CPU_NUM=2 $MutantRtl $TbCopy --Mdir $BuildDir *> $ModelLog
if ($LASTEXITCODE -ne 0) { throw "Mutated CMO model generation failed" }

$CppSources = @(
  Get-ChildItem -LiteralPath $BuildDir -Filter "*.cpp" -File |
    ForEach-Object { $_.FullName }
)
$CppSources += @(
  (Join-Path $RuntimeInclude "verilated.cpp"),
  (Join-Path $RuntimeInclude "verilated_timing.cpp"),
  (Join-Path $RuntimeInclude "verilated_threads.cpp")
)
$ModuleHeaders = @(
  Get-ChildItem -LiteralPath $BuildDir -Filter "V${Top}_m_vlsit_*.h" -File |
    ForEach-Object { $_.FullName }
)
$HeaderArgs = @()
foreach ($ModuleHeader in $ModuleHeaders) {
  $HeaderArgs += @("-include", $ModuleHeader)
}
$CompilerArguments = @(
  "-std=c++20", "-O2", "-DVL_TIME_CONTEXT",
  "-I$BuildDir", "-I$RuntimeInclude", "-I$(Join-Path $RuntimeInclude 'vltstd')"
) + $HeaderArgs + $CppSources + @("-pthread", "-latomic", "-o", $ExePath)

$PreviousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $Cxx @CompilerArguments *> $BuildLog
$ToolExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
if ($ToolExit -ne 0) { throw "Mutated CMO testbench C++ build failed: $ToolExit" }

$ErrorActionPreference = "Continue"
& $ExePath *> $SimulationLog
$MutationExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
$SimulationText = Get-Content -LiteralPath $SimulationLog -Raw
if ($MutationExit -eq 0 -or $SimulationText -notmatch "CMO controller check failed") {
  throw "Mutation was not detected by the expected CMO writeback-policy check"
}

Write-Output "PASS: testbench caught injected bug (INVAL incorrectly enables owner writeback)"
Write-Output "Simulation evidence: $SimulationLog"
