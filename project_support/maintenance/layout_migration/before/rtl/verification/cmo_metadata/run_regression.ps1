param([switch]$StoreUnit, [switch]$Ccu, [switch]$Retirement, [switch]$ExternalStore, [switch]$Arbiter, [switch]$LlcTag, [switch]$LlcPending, [switch]$NormalEvict, [switch]$WriteError, [ValidateSet(2,4)][int]$Harts=4)
$ErrorActionPreference = 'Stop'

$TestDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Resolve-Path (Join-Path $TestDir '..\..\..')).Path
$Verilator = 'C:\Users\PC\Tools\oss-cad-suite\bin\verilator_bin.exe'
$Gxx = 'C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe'
$VerilatorInclude = 'C:\Users\PC\Tools\oss-cad-suite\share\verilator\include'
$Top = if ($StoreUnit) { 'tb_store_unit_cmo_metadata' } else { 'tb_store_buffer_cmo_metadata' }
$Filelist = if ($StoreUnit) { 'filelist_store_unit.f' } else { 'filelist.f' }
if ($Arbiter) {
  $Top = 'tb_cmo_arbiter'
  $Filelist = 'filelist_arbiter.f'
}
if ($LlcTag) {
  $Top = 'tb_llc_flush_tag'
  $Filelist = 'filelist_llc_tag.f'
}
if ($LlcPending) { $Top = 'tb_llc_pending'; $Filelist = 'filelist_llc_pending.f' }
if ($Retirement) { $Top = 'tb_cmo_retirement'; $Filelist = 'filelist_retirement.f' }
if ($Ccu) { $Top = 'tb_cmo_ccu'; $Filelist = 'filelist_ccu.f' }
$BuildStamp = Get-Date -Format 'yyyyMMdd_HHmmss_ffff'
$BuildDir = Join-Path 'C:\HQuan\.test_tmp' "${Top}_${BuildStamp}"
$Executable = Join-Path $BuildDir "V${Top}.exe"

foreach ($RequiredTool in @($Verilator, $Gxx, (Join-Path $VerilatorInclude 'verilated.cpp'))) {
  if (-not (Test-Path -LiteralPath $RequiredTool)) {
    throw "Required tool or runtime source was not found: $RequiredTool"
  }
}

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

$PreviousVerilatorRoot = $env:VERILATOR_ROOT
$env:VERILATOR_ROOT = Split-Path -Parent $VerilatorInclude
Push-Location $TestDir
try {
  $ParamArgs = @()
  if ($ExternalStore) { $ParamArgs += "-GEXTERNAL_CMO=1" }
  if ($Arbiter -or $Ccu) { $ParamArgs = @("-GHARTS=$Harts") }
  if ($NormalEvict) { $ParamArgs += "-GNORMAL_EVICT=1" }
  if ($WriteError) { $ParamArgs += "-GWRITE_ERROR=1" }
  & $Verilator --cc --exe --main --timing --assert --timescale 1ns/1ps --top-module $Top `
    --Mdir $BuildDir -f $Filelist @ParamArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Verilator code generation failed with exit code $LASTEXITCODE"
  }

  $CppSources = @(
    Get-ChildItem -LiteralPath $BuildDir -Filter '*.cpp' | ForEach-Object { $_.FullName }
    (Join-Path $VerilatorInclude 'verilated.cpp')
    (Join-Path $VerilatorInclude 'verilated_timing.cpp')
    (Join-Path $VerilatorInclude 'verilated_threads.cpp')
  )
  $CompileArgs = @(
    '-std=gnu++20', '-fcoroutines', '-O2', '-DVL_TIME_CONTEXT', '-DVM_TIMING=1',
    '-DVM_COVERAGE=0', '-DVM_TRACE=0', '-DVM_SC=0', '-DVM_VPI=0',
    "-I$BuildDir", "-I$VerilatorInclude", "-I$(Join-Path $VerilatorInclude 'vltstd')"
  ) + $CppSources + @('-pthread', '-latomic', '-o', $Executable)
  & $Gxx @CompileArgs
  if ($LASTEXITCODE -ne 0) {
    throw "C++ model build failed with exit code $LASTEXITCODE"
  }

  & $Executable
  if ($LASTEXITCODE -ne 0) {
    throw "Store-buffer CMO metadata simulation failed with exit code $LASTEXITCODE"
  }
}
finally {
  Pop-Location
  $env:VERILATOR_ROOT = $PreviousVerilatorRoot
}
