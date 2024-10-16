resource "azurerm_subscription_policy_assignment" "mcsb-assignment" {
  name                 = "mcsb"
  display_name         = "Microsoft Cloud Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  subscription_id      = data.azurerm_subscription.current.id
}

resource "azurerm_security_center_subscription_pricing" "mdc-servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}

resource "azurerm_security_center_subscription_pricing" "mdc-storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"

  extension {
    name = "SensitiveDataDiscovery"
  }
}

resource "azurerm_log_analytics_workspace" "la-workspace" {
  name                = "wslaw"
  location            = azurerm_resource_group.security-rg.location
  resource_group_name = azurerm_resource_group.security-rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_security_center_workspace" "la-workspace" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.la-workspace.id
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "la-onboarding" {
  workspace_id                 = azurerm_log_analytics_workspace.la-workspace.id
  customer_managed_key_enabled = false
}

resource "azuread_application" "waynestock-prod" {
  display_name = "waynestock-prod"
}

resource "azuread_service_principal" "waynestock-prod-sp" {
  client_id = azuread_application.waynestock-prod.client_id
}

resource "azuread_group" "waynestock-prod-admins" {
  display_name     = "WayneStock Prod Admins"
  security_enabled = true
  members = [
    azuread_service_principal.waynestock-prod-sp.object_id
  ]
}

resource "azurerm_monitor_data_collection_endpoint" "monitor-endpoint" {
  name                = "waynestock-logs"
  location            = azurerm_resource_group.security-rg.location
  resource_group_name = azurerm_resource_group.security-rg.name
}

resource "azapi_resource" "data_collection_logs_table" {
  name      = "Apache2_CL"
  parent_id = azurerm_log_analytics_workspace.la-workspace.id
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  body = jsonencode(
    {
      "properties" : {
        "schema" : {
          "name" : "Apache2_CL",
          "columns" : [
            {
              "name" : "TimeGenerated",
              "type" : "datetime",
              "description" : "The time at which the data was generated"
            },
            {
              "name" : "RawData",
              "type" : "string",
              "description" : "Raw log data"
            }
          ]
        },
        "retentionInDays" : 30,
        "totalRetentionInDays" : 30
      }
    }
  )
}
