locals {
  effective_enabled = var.enabled && var.guest_configuration_content_uri != "" && var.guest_configuration_content_hash != ""
}

data "azurerm_resource_group" "scope" {
  count = local.effective_enabled ? 1 : 0
  name  = var.target_resource_group_name
}

resource "azurerm_policy_definition" "gc_package" {
  count        = local.effective_enabled ? 1 : 0
  name         = var.policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = var.policy_display_name
  description  = "Deploys and enforces a Guest Configuration package for Arc Windows machines selected by tag."

  metadata = jsonencode({
    category = "Guest Configuration"
    guestConfiguration = {
      name                      = var.guest_configuration_name
      version                   = var.guest_configuration_version
      contentType               = "Custom"
      contentUri                = var.guest_configuration_content_uri
      contentHash               = var.guest_configuration_content_hash
      assignmentType            = var.assignment_type
      assignmentHash            = var.guest_configuration_content_hash
      configurationParameter    = []
      assignmentParameter       = []
      enableAutoRemediation     = "true"
      autoRemediationAssignmentType = var.assignment_type
    }
  })

  parameters = jsonencode({
    effect = {
      type          = "String"
      defaultValue  = var.enforcement_effect
      allowedValues = ["DeployIfNotExists", "AuditIfNotExists", "Disabled"]
    }
    tagName = {
      type         = "String"
      defaultValue = var.tag_name
    }
    tagValue = {
      type         = "String"
      defaultValue = var.tag_value
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
        type = "Microsoft.GuestConfiguration/guestConfigurationAssignments"
        name = var.guest_configuration_name
        roleDefinitionIds = [
          "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
          "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        ]
        existenceCondition = {
          field  = "Microsoft.GuestConfiguration/guestConfigurationAssignments/complianceStatus"
          in     = ["Compliant", "Pending"]
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
                guestConfigurationName = {
                  type = "string"
                }
                guestConfigurationContentUri = {
                  type = "string"
                }
                guestConfigurationContentHash = {
                  type = "string"
                }
                guestConfigurationVersion = {
                  type = "string"
                }
                assignmentType = {
                  type = "string"
                }
              }
              resources = [
                {
                  type       = "Microsoft.HybridCompute/machines/providers/guestConfigurationAssignments"
                  apiVersion = "2024-05-20-preview"
                  name       = "[concat(parameters('machineName'), '/Microsoft.GuestConfiguration/', parameters('guestConfigurationName'))]"
                  location   = "[parameters('location')]"
                  properties = {
                    context = "AzurePolicy"
                    guestConfiguration = {
                      name                = "[parameters('guestConfigurationName')]"
                      version             = "[parameters('guestConfigurationVersion')]"
                      contentType         = "Custom"
                      contentUri          = "[parameters('guestConfigurationContentUri')]"
                      contentHash         = "[parameters('guestConfigurationContentHash')]"
                      assignmentType      = "[parameters('assignmentType')]"
                      configurationParameter = []
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
              guestConfigurationName = {
                value = var.guest_configuration_name
              }
              guestConfigurationContentUri = {
                value = var.guest_configuration_content_uri
              }
              guestConfigurationContentHash = {
                value = var.guest_configuration_content_hash
              }
              guestConfigurationVersion = {
                value = var.guest_configuration_version
              }
              assignmentType = {
                value = var.assignment_type
              }
            }
          }
        }
      }
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "gc_package" {
  count                = local.effective_enabled ? 1 : 0
  name                 = var.assignment_name
  resource_group_id    = data.azurerm_resource_group.scope[0].id
  policy_definition_id = azurerm_policy_definition.gc_package[0].id
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

resource "azurerm_resource_group_policy_remediation" "gc_package" {
  count                = local.effective_enabled ? 1 : 0
  name                 = "remediate-${var.assignment_name}"
  resource_group_id    = data.azurerm_resource_group.scope[0].id
  policy_assignment_id = azurerm_resource_group_policy_assignment.gc_package[0].id
}
