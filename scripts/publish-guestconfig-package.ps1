param(
  [Parameter(Mandatory = $true)]
  [string]$StorageAccountName,

  [Parameter(Mandatory = $true)]
  [string]$ContainerName,

  [Parameter(Mandatory = $true)]
  [string]$PackagePath,

  [string]$BlobName = "WindowsFileServerRole.zip",
  [string]$ResourceGroupName = ""
)

$ErrorActionPreference = "Stop"

function Invoke-AzChecked {
  param(
    [string]$Command
  )

  Invoke-Expression $Command | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI command failed: $Command"
  }
}

if (-not (Test-Path $PackagePath)) {
  throw "Package file not found: $PackagePath"
}

if (-not [string]::IsNullOrWhiteSpace($ResourceGroupName)) {
  Invoke-AzChecked -Command "az storage container create --account-name $StorageAccountName --name $ContainerName --auth-mode login --public-access off --resource-group $ResourceGroupName"
}
else {
  Invoke-AzChecked -Command "az storage container create --account-name $StorageAccountName --name $ContainerName --auth-mode login --public-access off"
}

Invoke-AzChecked -Command "az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name $BlobName --file $PackagePath --auth-mode login --overwrite true"

$hash = (Get-FileHash -Path $PackagePath -Algorithm SHA256).Hash
$uri = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/$BlobName"

# Emit in pipeline output stream so GitHub workflow can capture and parse values.
Write-Output "GC_PACKAGE_CONTENT_URI=$uri"
Write-Output "GC_PACKAGE_CONTENT_HASH=$hash"
