data "azurerm_resource_group" "scope" {
  count = var.enabled ? 1 : 0
  name  = var.target_resource_group_name
}

resource "azurerm_policy_definition" "arc_fileserver" {
  count        = var.enabled ? 1 : 0
  name         = var.policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = var.policy_display_name
  description  = "Deploys an Arc extension that installs FS-FileServer on Windows Arc machines tagged for File role."

  metadata = jsonencode({
    category = "Guest Configuration"
  })

  parameters = jsonencode({
    effect = {
      type          = "String"
      defaultValue  = var.enforcement_effect
      allowedValues = ["DeployIfNotExists", "AuditIfNotExists", "Disabled"]
      metadata = {
        displayName = "Effect"
      }
    }
    tagName = {
      type         = "String"
      defaultValue = var.tag_name
      metadata = {
        displayName = "Tag Name"
      }
    }
    tagValue = {
      type         = "String"
      defaultValue = var.tag_value
      metadata = {
        displayName = "Tag Value"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.HybridCompute/machines"
        },
        {
          field  = "Microsoft.HybridCompute/machines/osName"
          equals = "windows"
        },
        {
          field  = "[concat('tags[', parameters('tagName'), ']')]"
          equals = "[parameters('tagValue')]"
        }
      ]
    }
    then = {
      effect = "[parameters('effect')]"
      details = {
        type = "Microsoft.HybridCompute/machines/extensions"
        name = "[concat(field('name'), '/install-fileserver-role')]"
        roleDefinitionIds = [
          "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        ]
        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.HybridCompute/machines/extensions/publisher"
              equals = "Microsoft.Compute"
            },
            {
              field  = "Microsoft.HybridCompute/machines/extensions/type"
              equals = "CustomScriptExtension"
            },
            {
              field  = "Microsoft.HybridCompute/machines/extensions/provisioningState"
              equals = "Succeeded"
            }
          ]
        }
        deployment = {
          properties = {
            mode = "incremental"
            template = {
              "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
              contentVersion = "1.0.0.0"
              parameters = {
                machineName = {
                  type = "string"
                }
                location = {
                  type = "string"
                }
              }
              resources = [
                {
                  type       = "Microsoft.HybridCompute/machines/extensions"
                  apiVersion = "2023-10-03-preview"
                  name       = "[concat(parameters('machineName'), '/install-fileserver-role')]"
                  location   = "[parameters('location')]"
                  properties = {
                    publisher               = "Microsoft.Compute"
                    type                    = "CustomScriptExtension"
                    typeHandlerVersion      = "1.10"
                    autoUpgradeMinorVersion = true
                    settings = {
                      commandToExecute = "powershell -ExecutionPolicy Bypass -Command \"Install-WindowsFeature -Name FS-FileServer -IncludeManagementTools\""
                    }
                  }
                }
              ]
            }
            parameters = {
              machineName = {
                value = "[field('name')]"
              }
              location = {
                value = "[field('location')]"
              }
            }
          }
        }
      }
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "arc_fileserver" {
  count                = var.enabled ? 1 : 0
  name                 = "assign-arc-fileserver-role-by-tag"
  resource_group_id    = data.azurerm_resource_group.scope[0].id
  policy_definition_id = azurerm_policy_definition.arc_fileserver[0].id
  location             = var.location
  enforce              = true

  parameters = jsonencode({
    effect = {
      value = var.enforcement_effect
    }
    tagName = {
      value = var.tag_name
    }
    tagValue = {
      value = var.tag_value
    }
  })

  identity {
    type = "SystemAssigned"
  }
}
