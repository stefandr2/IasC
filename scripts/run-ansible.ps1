param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "test", "prod")]
  [string]$Environment,

  [ValidateSet("baseline", "arc")]
  [string]$Playbook = "baseline"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$ansibleDir = Join-Path $repoRoot "ansible"
$inventory = "inventories/$Environment/hosts.yml"

switch ($Playbook) {
  "baseline" { $playbookFile = "playbooks/baseline-windows.yml" }
  "arc" { $playbookFile = "playbooks/onboard-arc.yml" }
}

Push-Location $ansibleDir
try {
  ansible-playbook -i $inventory $playbookFile
}
finally {
  Pop-Location
}
