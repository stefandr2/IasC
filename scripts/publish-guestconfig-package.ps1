param(
  [Parameter(Mandatory = $true)]
  [string]$StorageAccountName,

  [Parameter(Mandatory = $true)]
  [string]$ContainerName,

  [Parameter(Mandatory = $true)]
  [string]$PackagePath,

  [string]$BlobName = "guestconfig/WindowsFileServerRole.zip",
  [string]$ResourceGroupName = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $PackagePath)) {
  throw "Package file not found: $PackagePath"
}

if (-not [string]::IsNullOrWhiteSpace($ResourceGroupName)) {
  az storage container create --account-name $StorageAccountName --name $ContainerName --auth-mode login --public-access off --resource-group $ResourceGroupName | Out-Null
}
else {
  az storage container create --account-name $StorageAccountName --name $ContainerName --auth-mode login --public-access off | Out-Null
}

az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name $BlobName --file $PackagePath --auth-mode login --overwrite true | Out-Null

$hash = (Get-FileHash -Path $PackagePath -Algorithm SHA256).Hash
$uri = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/$BlobName"

Write-Host "GC_PACKAGE_CONTENT_URI=$uri"
Write-Host "GC_PACKAGE_CONTENT_HASH=$hash"
