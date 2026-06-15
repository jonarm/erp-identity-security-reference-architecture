# terraform/entra-enterprise-app.tf
# Registers the Dynamics 365 ERP app in Entra ID with SAML SSO and app roles

# App registration
resource "azuread_application" "d365_erp" {
  display_name            = var.erp_app_display_name
  identifier_uris         = [var.erp_app_identifier_uri]
  sign_in_audience        = "AzureADMyOrg"

  # App roles — maps to SoD role definitions
  dynamic "app_role" {
    for_each = local.app_roles
    content {
      id                   = app_role.value.id
      display_name         = app_role.value.display_name
      description          = app_role.value.description
      value                = app_role.value.value
      allowed_member_types = app_role.value.allowed_member_types
      enabled              = app_role.value.enabled
    }
  }

  # Required resource access — Microsoft Graph
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }

  tags = [
    "erp",
    "dynamics365",
    "financial-services",
    var.environment
  ]
}

# Enterprise application (service principal) — makes app available to users
resource "azuread_service_principal" "d365_erp" {
  client_id                    = azuread_application.d365_erp.client_id
  app_role_assignment_required = true  # Users must be explicitly assigned

  tags = [
    "erp",
    "dynamics365",
    var.environment
  ]
}

# Output the app registration details for reference
output "erp_app_client_id" {
  description = "Client ID of the D365 ERP app registration"
  value       = azuread_application.d365_erp.client_id
}

output "erp_app_object_id" {
  description = "Object ID of the D365 ERP app registration"
  value       = azuread_application.d365_erp.object_id
}

output "erp_service_principal_id" {
  description = "Object ID of the D365 ERP service principal"
  value       = azuread_service_principal.d365_erp.object_id
}