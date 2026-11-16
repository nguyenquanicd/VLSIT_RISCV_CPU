param(
  [string]$BuildDir = "C:\HQuan\.test_tmp\riscv_tile_coh_adapter",
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe",
  [string]$VerilatorRoot = "C:\Tools\oss-cad-suite\share\verilator",
  [string]$Cxx = "C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}
$Top = "tb_m_vlsit_riscv_tile_coh_adapter"
$BuildDir = [System.IO.Path]::GetFullPath($BuildDir)
$RuntimeInclude = Join-Path $VerilatorRoot "include"
$ExePath = Join-Path $BuildDir "$Top.exe"
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\full_integration"))
$BuildLog = Join-Path $ReportDir "tile_coh_adapter_build.log"
$SimulationLog = Join-Path $ReportDir "tile_coh_adapter_sim.log"

foreach ($RequiredPath in @($Verilator, $RuntimeInclude, $Cxx)) {
  if (-not (Test-Path -LiteralPath $RequiredPath)) {
    throw "Required tool path does not exist: $RequiredPath"
  }
}
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null
Set-Content -LiteralPath $BuildLog -Value ""
Set-Content -LiteralPath $SimulationLog -Value ""
$env:VERILATOR_ROOT = $VerilatorRoot

$PreviousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $Verilator --cc --exe --main --timing -Wall -Wno-fatal `
  --CFLAGS "-DVL_TIME_CONTEXT" --top-module $Top -f filelist.f `
  --Mdir $BuildDir 2>&1 | Tee-Object -FilePath $BuildLog -Append
$ToolExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
if ($ToolExit -ne 0) { throw "Verilator C++ generation failed: $ToolExit" }

$CppSources = @(
  Get-ChildItem -LiteralPath $BuildDir -Filter "*.cpp" -File |
    ForEach-Object { $_.FullName }
)
$CppSources += @(
  (Join-Path $RuntimeInclude "verilated.cpp"),
  (Join-Path $RuntimeInclude "verilated_timing.cpp"),
  (Join-Path $RuntimeInclude "verilated_threads.cpp")
)

$ErrorActionPreference = "Continue"
& $Cxx -std=c++20 -O2 -DVL_TIME_CONTEXT `
  "-I$BuildDir" "-I$RuntimeInclude" @CppSources -o $ExePath 2>&1 |
  Tee-Object -FilePath $BuildLog -Append
$ToolExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
if ($ToolExit -ne 0) { throw "C++ simulation build failed: $ToolExit" }

$ErrorActionPreference = "Continue"
& $ExePath 2>&1 | Tee-Object -FilePath $SimulationLog -Append
$ToolExit = $LASTEXITCODE
$ErrorActionPreference = $PreviousErrorActionPreference
if ($ToolExit -ne 0) { throw "Simulation failed: $ToolExit" }

# Store text logs as UTF-8 without a UTF-16 PowerShell redirection encoding.
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
foreach ($LogPath in @($BuildLog, $SimulationLog)) {
  $LogBytes = [System.IO.File]::ReadAllBytes($LogPath)
  $FirstNul = [Array]::IndexOf($LogBytes, [byte]0)
  if ($FirstNul -ge 1) {
    $Utf16Start = $FirstNul - 1
    $Prefix = [System.Text.Encoding]::ASCII.GetString($LogBytes, 0, $Utf16Start)
    $Suffix = [System.Text.Encoding]::Unicode.GetString(
      $LogBytes, $Utf16Start, $LogBytes.Length - $Utf16Start
    )
    $LogText = $Prefix + $Suffix
  } else {
    $LogText = [System.Text.Encoding]::UTF8.GetString($LogBytes)
  }
  [System.IO.File]::WriteAllText($LogPath, $LogText, $Utf8NoBom)
}
