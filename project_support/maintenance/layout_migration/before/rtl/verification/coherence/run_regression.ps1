param(
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe",
  [string]$VerilatorRoot = "C:\Tools\oss-cad-suite\share\verilator",
  [string]$Cxx = "C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe",
  [string]$BuildDir = "C:\HQuan\.test_tmp\riscv_coh_fabric_event"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$Top = "tb_m_vlsit_riscv_coh_fabric"
$RuntimeInclude = Join-Path $VerilatorRoot "include"
$BuildDir = [System.IO.Path]::GetFullPath($BuildDir)
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\full_integration"))
$LintLog = Join-Path $ReportDir "coh_fabric_event_lint.log"
$ModelLog = Join-Path $ReportDir "coh_fabric_event_model.log"
$BuildLog = Join-Path $ReportDir "coh_fabric_event_build.log"
$SimulationLog = Join-Path $ReportDir "coh_fabric_event_sim.log"
$ExePath = Join-Path $BuildDir "$Top.exe"

New-Item -ItemType Directory -Force -Path $BuildDir, $ReportDir | Out-Null
$env:VERILATOR_ROOT = $VerilatorRoot

& $Verilator --lint-only --timing -Wall -Wno-fatal --top-module $Top -f filelist.f *> $LintLog
if ($LASTEXITCODE -ne 0) { throw "Coherence-fabric testbench lint failed" }

& $Verilator --cc --main --timing -Wall -Wno-fatal --CFLAGS "-DVL_TIME_CONTEXT" `
  --top-module $Top -f filelist.f --Mdir $BuildDir *> $ModelLog
if ($LASTEXITCODE -ne 0) { throw "Verilator model generation failed" }

$CppSources = @(
  Get-ChildItem -LiteralPath $BuildDir -Filter "*.cpp" -File |
    ForEach-Object { $_.FullName }
)
$CppSources += @(
  (Join-Path $RuntimeInclude "verilated.cpp"),
  (Join-Path $RuntimeInclude "verilated_timing.cpp"),
  (Join-Path $RuntimeInclude "verilated_threads.cpp")
)
$CompilerArguments = @(
  "-std=c++20", "-O2", "-DVL_TIME_CONTEXT",
  "-I$BuildDir", "-I$RuntimeInclude", "-I$(Join-Path $RuntimeInclude 'vltstd')"
) + $CppSources + @("-pthread", "-latomic", "-o", $ExePath)

& $Cxx @CompilerArguments *> $BuildLog
if ($LASTEXITCODE -ne 0) { throw "C++ simulation build failed" }

& $ExePath *> $SimulationLog
if ($LASTEXITCODE -ne 0) { throw "Coherence-fabric simulation failed" }

Get-Content -LiteralPath $SimulationLog
