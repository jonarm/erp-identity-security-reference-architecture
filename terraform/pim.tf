# terraform/pim.tf
# Configures PIM eligible role assignments for ERP admin roles

# Data source — current service principal (Terraform itself)
data "azuread_client_config" "current" {}

# Data source — ERP System Admin user
data "azuread_user" "erp_admin" {
  user_principal_name = var.erp_admin_upn
}

# ----------------------------------------
# PIM — Global Administrator (eligible only)
# ----------------------------------------
resource "azuread_directory_role" "global_admin" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_eligibility_schedule_request" "global_admin_eligible" {
  role_definition_id = azuread_directory_role.global_admin.template_id
  principal_id       = data.azuread_user.erp_admin.object_id
  directory_scope_id = "/"
  justification      = "ERP lab — Global Admin eligible assignment for PIM JIT demonstration"
}

# ----------------------------------------
# PIM — Application Administrator (eligible only)
# ----------------------------------------
resource "azuread_directory_role" "app_admin" {
  display_name = "Application Administrator"
}

resource "azuread_directory_role_eligibility_schedule_request" "app_admin_eligible" {
  role_definition_id = azuread_directory_role.app_admin.template_id
  principal_id       = data.azuread_user.erp_admin.object_id
  directory_scope_id = "/"
  justification      = "ERP lab — Application Admin eligible assignment for PIM JIT demonstration"
}