param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "test", "prod")]
  [string]$Environment,

  [ValidateSet("plan", "apply")]
  [string]$Action = "plan"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$terraformDir = Join-Path $repoRoot "terraform"
$backendFile = Join-Path $terraformDir "backends/$Environment.hcl"
$tfvarsFile = Join-Path $terraformDir "environments/$Environment.tfvars"

if (-not (Test-Path $backendFile)) {
  throw "Missing backend file: $backendFile"
}

if (-not (Test-Path $tfvarsFile)) {
  throw "Missing tfvars file: $tfvarsFile"
}

Push-Location $terraformDir
try {
  terraform init -backend-config=$backendFile
  terraform plan -var-file=$tfvarsFile

  if ($Action -eq "apply") {
    terraform apply -var-file=$tfvarsFile -auto-approve
  }
}
finally {
  Pop-Location
}
