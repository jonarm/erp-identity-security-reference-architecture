# terraform/main.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

# Azure AD provider — uses same credentials as azurerm
provider "azuread" {
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

# Azure Resource Manager provider
provider "azurerm" {
  features {}
  tenant_id               = var.tenant_id
  subscription_id         = var.subscription_id
  client_id               = var.client_id
  client_secret           = var.client_secret
  skip_provider_registration = true
}

# Resource group for all Sentinel and monitoring resources
resource "azurerm_resource_group" "erp_security" {
  name     = "rg-erp-security-lab"
  location = "australiaeast"

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = "erp-identity-security"
  }
}