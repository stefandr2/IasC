param(
  [string]$OutputPath = "artifacts/guestconfig/WindowsFileServerRole.zip"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$outFile       = Join-Path $root $OutputPath
$outDir        = Split-Path -Parent $outFile
$packageName   = "WindowsFileServerRole"
$workDir       = Join-Path $root "artifacts/guestconfig/work"
$packageOutDir = Join-Path $root "artifacts/guestconfig/package"
$configScript  = Join-Path $root "policies/guestconfig/packages/windows-fileserver/WindowsFileServerRole.ps1"

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

New-Item -ItemType Directory -Path $workDir -Force | Out-Null
New-Item -ItemType Directory -Path $packageOutDir -Force | Out-Null

if (-not (Test-Path $configScript)) {
  throw "Guest Configuration DSC script not found: $configScript"
}

Install-Module -Name GuestConfiguration -Force -Scope CurrentUser -AllowClobber
Install-Module -Name PSDscResources -Force -Scope CurrentUser -AllowClobber

Import-Module GuestConfiguration -Force
. $configScript

WindowsFileServerRole -OutputPath $workDir

$mofPath = Join-Path $workDir "localhost.mof"
if (-not (Test-Path $mofPath)) {
  throw "MOF not generated: $mofPath"
}

New-GuestConfigurationPackage -Name $packageName -Configuration $mofPath -Type AuditAndSet -Path $packageOutDir -Force

$builtPackage = Join-Path $packageOutDir "$packageName.zip"
if (-not (Test-Path $builtPackage)) {
  throw "Guest Configuration package not generated: $builtPackage"
}

Copy-Item -Path $builtPackage -Destination $outFile -Force

$hash = (Get-FileHash -Path $outFile -Algorithm SHA256).Hash
Write-Host "Package created: $outFile"
Write-Host "SHA256: $hash"
