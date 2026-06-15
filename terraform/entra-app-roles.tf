# terraform/entra-app-roles.tf
# Defines all ERP role IDs as locals — referenced by entra-enterprise-app.tf

locals {

  # Unique IDs for each app role — generated once, never change
  role_finance_user         = "00000001-0000-0000-0000-000000000001"
  role_finance_manager      = "00000001-0000-0000-0000-000000000002"
  role_ap_officer           = "00000001-0000-0000-0000-000000000003"
  role_payment_processor    = "00000001-0000-0000-0000-000000000004"
  role_procurement_officer  = "00000001-0000-0000-0000-000000000005"
  role_procurement_approver = "00000001-0000-0000-0000-000000000006"
  role_vendor_maintainer    = "00000001-0000-0000-0000-000000000007"
  role_risk_auditor         = "00000001-0000-0000-0000-000000000008"
  role_erp_admin            = "00000001-0000-0000-0000-000000000009"

  app_roles = [
    {
      id                   = local.role_finance_user
      display_name         = "Finance User"
      description          = "View and enter journal entries and run standard reports"
      value                = "D365.Finance.User"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_finance_manager
      display_name         = "Finance Manager"
      description          = "Approve journal entries and access financial statements"
      value                = "D365.Finance.Manager"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_ap_officer
      display_name         = "Accounts Payable Officer"
      description          = "Create and manage vendor invoices"
      value                = "D365.AP.Officer"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_payment_processor
      display_name         = "Payment Processor"
      description          = "Process and release supplier payments"
      value                = "D365.AP.PaymentProcessor"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_procurement_officer
      display_name         = "Procurement Officer"
      description          = "Create purchase requisitions and orders"
      value                = "D365.Procurement.Officer"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_procurement_approver
      display_name         = "Procurement Approver"
      description          = "Approve purchase orders above threshold"
      value                = "D365.Procurement.Approver"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_vendor_maintainer
      display_name         = "Vendor Master Maintainer"
      description          = "Create and modify vendor records"
      value                = "D365.Vendor.Maintainer"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_risk_auditor
      display_name         = "Risk Auditor"
      description          = "Read-only access to all modules for audit purposes"
      value                = "D365.Risk.Auditor"
      allowed_member_types = ["User"]
      enabled              = true
    },
    {
      id                   = local.role_erp_admin
      display_name         = "ERP System Admin"
      description          = "Full system configuration access — JIT via PIM only"
      value                = "D365.System.Admin"
      allowed_member_types = ["User"]
      enabled              = true
    }
  ]
}