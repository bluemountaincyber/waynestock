terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.110.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.53.1"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "talent-rg" {
  name     = "WS-TALENT-RG"
  location = var.region
}

resource "azurerm_resource_group" "homepage-rg" {
  name     = "WS-HOMEPAGE-RG"
  location = var.region
}

resource "azurerm_resource_group" "security-rg" {
  name     = "WS-SECURITY-RG"
  location = var.region
}
