param(
  [string]$SubscriptionId = "113f91f0-83f2-4b50-8e5a-111f1d89e1e1",
  [string]$ResourceGroupName = "Nestle2",
  [string]$Location = "northeurope",
  [string]$MaintenanceConfigurationName = "mc-nestle2-allmachines-monthly"
)

$ErrorActionPreference = "Stop"

Write-Host "Setting Azure subscription context..."
az account set --subscription $SubscriptionId | Out-Null

Write-Host "Registering required resource providers..."
az provider register --namespace Microsoft.Maintenance | Out-Null
az provider register --namespace Microsoft.Compute | Out-Null
az provider register --namespace Microsoft.HybridCompute | Out-Null

Write-Host "Creating or updating Azure Update Manager maintenance configuration..."
az maintenance configuration create `
  --resource-group $ResourceGroupName `
  --resource-name $MaintenanceConfigurationName `
  --location $Location `
  --maintenance-scope InGuestPatch `
  --maintenance-window-duration "03:00" `
  --maintenance-window-recur-every "Month Second Tuesday" `
  --maintenance-window-start-date-time "2026-07-14 02:00" `
  --maintenance-window-time-zone "UTC" `
  --install-patches-reboot-setting IfRequired `
  --windows-classifications-to-include Critical Security UpdateRollup | Out-Null

$maintenanceConfigId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Maintenance/maintenanceConfigurations/$MaintenanceConfigurationName"

Write-Host "Discovering Azure VMs in $ResourceGroupName..."
$vmNames = az vm list --resource-group $ResourceGroupName --query "[].name" -o tsv

foreach ($vmName in $vmNames) {
  $assignmentName = "aum-vm-$vmName"
  Write-Host "Assigning maintenance configuration to Azure VM: $vmName"

  az maintenance assignment create `
    --resource-group $ResourceGroupName `
    --resource-name $vmName `
    --resource-type virtualMachines `
    --provider-name Microsoft.Compute `
    --location $Location `
    --configuration-assignment-name $assignmentName `
    --maintenance-configuration-id $maintenanceConfigId | Out-Null
}

Write-Host "Discovering Arc-enabled machines in $ResourceGroupName..."
$arcMachineNames = az resource list `
  --resource-group $ResourceGroupName `
  --resource-type Microsoft.HybridCompute/machines `
  --query "[].name" -o tsv

foreach ($arcName in $arcMachineNames) {
  $assignmentName = "aum-arc-$arcName"
  Write-Host "Assigning maintenance configuration to Arc machine: $arcName"

  az maintenance assignment create `
    --resource-group $ResourceGroupName `
    --resource-name $arcName `
    --resource-type machines `
    --provider-name Microsoft.HybridCompute `
    --location $Location `
    --configuration-assignment-name $assignmentName `
    --maintenance-configuration-id $maintenanceConfigId | Out-Null
}

Write-Host "Completed. Listing assignments for verification..."
az maintenance assignment list `
  --resource-group $ResourceGroupName `
  --provider-name Microsoft.Compute `
  --resource-type virtualMachines `
  --resource-name "*" -o table

az maintenance assignment list `
  --resource-group $ResourceGroupName `
  --provider-name Microsoft.HybridCompute `
  --resource-type machines `
  --resource-name "*" -o table
