param(
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe",
  [string]$VerilatorRoot = "C:\Tools\oss-cad-suite\share\verilator",
  [string]$Cxx = "C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe",
  [string]$BuildRoot = "C:\HQuan\.test_tmp\riscv_cmo_controller"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$Top = "tb_m_vlsit_riscv_cmo_controller"
$RuntimeInclude = Join-Path $VerilatorRoot "include"
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\cmo_controller"))
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null
$env:VERILATOR_ROOT = $VerilatorRoot

foreach ($HartCount in @(2, 4)) {
  $RunTag = "${HartCount}h_$(Get-Date -Format 'yyyyMMddHHmmssfff')"
  $BuildDir = [System.IO.Path]::GetFullPath("${BuildRoot}_${RunTag}")
  $LintLog = Join-Path $ReportDir "cmo_controller_${HartCount}h_lint.log"
  $ModelLog = Join-Path $ReportDir "cmo_controller_${HartCount}h_model.log"
  $BuildLog = Join-Path $ReportDir "cmo_controller_${HartCount}h_build.log"
  $SimulationLog = Join-Path $ReportDir "cmo_controller_${HartCount}h_sim.log"
  $ExePath = Join-Path $BuildDir "$Top.exe"

  New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
  & $Verilator --lint-only --timing -Wall -Wno-fatal --top-module $Top `
    "-GPARA_CPU_NUM=$HartCount" -f filelist.f *> $LintLog
  if ($LASTEXITCODE -ne 0) { throw "$HartCount-hart CMO-controller testbench lint failed" }

  & $Verilator --cc --main --timing -Wall -Wno-fatal --CFLAGS "-DVL_TIME_CONTEXT" `
    --top-module $Top "-GPARA_CPU_NUM=$HartCount" -f filelist.f --Mdir $BuildDir *> $ModelLog
  if ($LASTEXITCODE -ne 0) { throw "$HartCount-hart CMO-controller model generation failed" }

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
  if ($ToolExit -ne 0) { throw "$HartCount-hart CMO-controller C++ simulation build failed: $ToolExit" }

$ErrorActionPreference = "Continue"
& $ExePath *> $SimulationLog
$ToolExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
  if ($ToolExit -ne 0) { throw "$HartCount-hart CMO-controller simulation failed: $ToolExit" }

  Get-Content -LiteralPath $SimulationLog
}
