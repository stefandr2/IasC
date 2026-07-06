param(
  [string]$Repository = "",
  [string[]]$Environments = @("dev", "test", "prod"),
  [string[]]$RequiredReviewerUsernames = @(),
  [string]$AzureAppDisplayName = "iac-github-oidc-iasc",
  [string]$AzureClientId = "",
  [string]$AzureTenantId = "",
  [string]$AzureSubscriptionId = "",
  [switch]$SkipRequiredReviewers
)

$ErrorActionPreference = "Stop"

function Get-PlainTextFromSecureString {
  param([Security.SecureString]$SecureValue)
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

function Resolve-Repository {
  param([string]$Repo)

  if (-not [string]::IsNullOrWhiteSpace($Repo)) {
    return $Repo
  }

  $remoteUrl = (git remote get-url origin).Trim()
  if ($remoteUrl -match "github.com[:/](.+?/.+?)(\.git)?$") {
    return $matches[1]
  }

  throw "Could not resolve GitHub owner/repo from git remote. Pass -Repository owner/repo."
}

function Ensure-GhAuth {
  $null = gh auth status 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run: gh auth login"
  }
}

function Ensure-AzureContext {
  $account = az account show --query "{subscriptionId:id, tenantId:tenantId}" -o json | ConvertFrom-Json

  if ([string]::IsNullOrWhiteSpace($script:AzureTenantId)) {
    $script:AzureTenantId = $account.tenantId
  }

  if ([string]::IsNullOrWhiteSpace($script:AzureSubscriptionId)) {
    $script:AzureSubscriptionId = $account.subscriptionId
  }
}

function Ensure-AzureApp {
  if (-not [string]::IsNullOrWhiteSpace($script:AzureClientId)) {
    $app = az ad app list --filter "appId eq '$($script:AzureClientId)'" --query "[0].{appId:appId,id:id}" -o json | ConvertFrom-Json
    if (-not $app) {
      throw "Azure app with client ID $($script:AzureClientId) not found."
    }
    return $app
  }

  $existing = az ad app list --display-name $AzureAppDisplayName --query "[0].{appId:appId,id:id}" -o json | ConvertFrom-Json
  if ($existing) {
    return $existing
  }

  $created = az ad app create --display-name $AzureAppDisplayName --query "{appId:appId,id:id}" -o json | ConvertFrom-Json
  az ad sp create --id $created.appId 1>$null
  return $created
}

function Ensure-GitHubEnvironment {
  param(
    [string]$Repo,
    [string]$EnvironmentName,
    [bool]$RequireReview,
    [array]$Reviewers
  )

  $payload = @{
    wait_timer               = 0
    prevent_self_review      = $false
    deployment_branch_policy = $null
  }

  if ($RequireReview -and $Reviewers.Count -gt 0) {
    $payload.reviewers = $Reviewers
  }

  $json = $payload | ConvertTo-Json -Depth 8 -Compress
  $tempFile = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $tempFile -Value $json -Encoding ascii

  try {
    $null = gh api --method PUT "repos/$Repo/environments/$EnvironmentName" --input $tempFile
  }
  finally {
    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
  }
}

function Ensure-FederatedCredential {
  param(
    [string]$AppObjectId,
    [string]$Repo,
    [string]$EnvironmentName
  )

  $credentialName = "github-$($Repo.Replace('/','-'))-$EnvironmentName"
  $tempFile = [System.IO.Path]::GetTempFileName()

  $fc = @{
    name      = $credentialName
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = "repo:$Repo:environment:$EnvironmentName"
    audiences = @("api://AzureADTokenExchange")
  } | ConvertTo-Json -Depth 5

  Set-Content -Path $tempFile -Value $fc -Encoding ascii

  try {
    $existing = az ad app federated-credential list --id $AppObjectId --query "[?name=='$credentialName'] | length(@)" -o tsv
    if ($existing -eq "0") {
      $null = az ad app federated-credential create --id $AppObjectId --parameters $tempFile
    }
  }
  finally {
    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
  }
}

$repo = Resolve-Repository -Repo $Repository
Ensure-GhAuth
Ensure-AzureContext
$app = Ensure-AzureApp

if ($RequiredReviewerUsernames.Count -eq 0 -and -not $SkipRequiredReviewers) {
  $owner = $repo.Split('/')[0]
  $RequiredReviewerUsernames = @($owner)
}

$reviewers = @()
if (-not $SkipRequiredReviewers) {
  foreach ($username in $RequiredReviewerUsernames) {
    $user = gh api "users/$username" --jq "{type:\"User\",id:.id}" | ConvertFrom-Json
    $reviewers += $user
  }
}

$securePassword = Read-Host "Enter TF_ADMIN_PASSWORD for GitHub environment secrets" -AsSecureString
$tfAdminPassword = Get-PlainTextFromSecureString -SecureValue $securePassword

foreach ($envName in $Environments) {
  $requireReview = ($envName -in @("test", "prod")) -and (-not $SkipRequiredReviewers)
  Ensure-GitHubEnvironment -Repo $repo -EnvironmentName $envName -RequireReview:$requireReview -Reviewers $reviewers

  Ensure-FederatedCredential -AppObjectId $app.id -Repo $repo -EnvironmentName $envName

  $null = $script:AzureTenantId | gh secret set AZURE_TENANT_ID --repo $repo --env $envName
  $null = $script:AzureSubscriptionId | gh secret set AZURE_SUBSCRIPTION_ID --repo $repo --env $envName
  $null = $app.appId | gh secret set AZURE_CLIENT_ID --repo $repo --env $envName
  $null = $tfAdminPassword | gh secret set TF_ADMIN_PASSWORD --repo $repo --env $envName

  Write-Host "Configured GitHub environment and secrets for: $envName"
}

Write-Host "Done."
Write-Host "Repository: $repo"
Write-Host "Azure Client ID: $($app.appId)"
Write-Host "Azure Tenant ID: $AzureTenantId"
Write-Host "Azure Subscription ID: $AzureSubscriptionId"
