param(
  [string]$Verilator = "C:\Tools\oss-cad-suite\bin\verilator_bin.exe",
  [string]$VerilatorRoot = "C:\Tools\oss-cad-suite\share\verilator",
  [string]$Cxx = "C:\Users\PC\Tools\msys64\ucrt64\bin\g++.exe",
  [string]$BuildRoot = "C:\HQuan\.test_tmp\riscv_coh_tile_array"
)

$ErrorActionPreference = "Stop"
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}
$Top = "tb_m_vlsit_riscv_coh_tile_array"
$RuntimeInclude = Join-Path $VerilatorRoot "include"
$ReportDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\reports\full_integration"))
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null
$env:VERILATOR_ROOT = $VerilatorRoot

foreach ($HartCount in @(2, 4)) {
  # A fresh Mdir avoids compiling stale generated C++ when the hart parameter changes.
  $BuildDir = [System.IO.Path]::GetFullPath("${BuildRoot}_${HartCount}_$(Get-Date -Format 'yyyyMMddHHmmssfff')")
  $LintLog = Join-Path $ReportDir "coh_tile_array_${HartCount}h_lint.log"
  $BuildLog = Join-Path $ReportDir "coh_tile_array_${HartCount}h_build.log"
  $SimulationLog = Join-Path $ReportDir "coh_tile_array_${HartCount}h_sim.log"
  New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
  foreach ($LogPath in @($LintLog, $BuildLog, $SimulationLog)) {
    Set-Content -LiteralPath $LogPath -Value ""
  }

  & $Verilator --lint-only --timing -Wall -Wno-fatal --top-module $Top `
    "-GPARA_CPU_NUM=$HartCount" -f filelist.f "${Top}.sv" 2>&1 |
    Tee-Object -FilePath $LintLog -Append
  if ($LASTEXITCODE -ne 0) { throw "$HartCount-hart testbench lint failed" }

  & $Verilator --cc --main --timing -Wall -Wno-fatal --CFLAGS "-DVL_TIME_CONTEXT" `
    --top-module $Top "-GPARA_CPU_NUM=$HartCount" -f filelist.f "${Top}.sv" `
    --Mdir $BuildDir 2>&1 | Tee-Object -FilePath $BuildLog -Append
  if ($LASTEXITCODE -ne 0) { throw "$HartCount-hart Verilator generation failed" }

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
  $ExePath = Join-Path $BuildDir "$Top.exe"
  $PreviousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & $Cxx -std=c++20 -O2 -DVL_TIME_CONTEXT "-I$BuildDir" "-I$RuntimeInclude" `
    "-I$(Join-Path $RuntimeInclude 'vltstd')" @HeaderArgs @CppSources -o $ExePath 2>&1 |
    Tee-Object -FilePath $BuildLog -Append
  $ToolExit = $LASTEXITCODE
  $ErrorActionPreference = $PreviousErrorActionPreference
  if ($ToolExit -ne 0) { throw "$HartCount-hart C++ compile failed: $ToolExit" }

  $ErrorActionPreference = "Continue"
  & $ExePath 2>&1 | Tee-Object -FilePath $SimulationLog -Append
  $ToolExit = $LASTEXITCODE
  $ErrorActionPreference = $PreviousErrorActionPreference
  if ($ToolExit -ne 0) { throw "$HartCount-hart simulation failed: $ToolExit" }
}

# Keep tool logs readable as UTF-8 regardless of the PowerShell host default.
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
foreach ($HartCount in @(2, 4)) {
  foreach ($LogName in @("lint", "build", "sim")) {
    $LogPath = Join-Path $ReportDir "coh_tile_array_${HartCount}h_${LogName}.log"
    $LogBytes = [System.IO.File]::ReadAllBytes($LogPath)
    if ($LogBytes.Length -ge 2 -and $LogBytes[0] -eq 0xFF -and $LogBytes[1] -eq 0xFE) {
      $LogText = [System.Text.Encoding]::Unicode.GetString($LogBytes, 2, $LogBytes.Length - 2)
    } elseif ([Array]::IndexOf($LogBytes, [byte]0) -ge 0) {
      $LogText = [System.Text.Encoding]::Unicode.GetString($LogBytes)
    } else {
      $LogText = [System.Text.Encoding]::UTF8.GetString($LogBytes)
    }
    if ($LogText.Length -gt 0 -and [int][char]$LogText[0] -eq 0x0A0D) {
      $LogText = $LogText.Substring(1)
    }
    [System.IO.File]::WriteAllText($LogPath, $LogText, $Utf8NoBom)
  }
}
