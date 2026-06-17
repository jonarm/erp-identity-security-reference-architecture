# terraform/conditional-access.tf
# Deploys all 6 Conditional Access policies via Terraform

# ----------------------------------------
# CA001 - Require MFA for All Users
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca001_mfa_all_users" {
  display_name = "CA001 - Require MFA for All Users"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
      excluded_roles = ["62e90394-69f5-4237-9190-012177145e10"] # Global Admin excluded — managed by CA005
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# ----------------------------------------
# CA002 - Block Legacy Authentication
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca002_block_legacy_auth" {
  display_name = "CA002 - Block Legacy Authentication"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["exchangeActiveSync", "other"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ----------------------------------------
# CA003 - Require Compliant Device for ERP
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca003_compliant_device_erp" {
  display_name = "CA003 - Require Compliant Device for ERP Access"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    platforms {
      included_platforms = ["all"]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["compliantDevice", "domainJoinedDevice"]
  }
}

# ----------------------------------------
# CA004 - Sign-in Risk Step-Up Auth
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca004_signin_risk" {
  display_name = "CA004 - Sign-in Risk Step-Up Authentication"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    user_risk_levels = ["medium", "high"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# ----------------------------------------
# CA005 - ERP Admin PIM Role Protection
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca005_erp_admin_protection" {
  display_name = "CA005 - ERP Admin PIM Role Protection"
  state        = "enabled"

  conditions {
    users {
      included_roles = [
        "62e90394-69f5-4237-9190-012177145e10", # Global Administrator
      ]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "compliantDevice"]
  }

  session_controls {
    sign_in_frequency        = 1
    sign_in_frequency_period = "hours"
  }
}

# ----------------------------------------
# CA006 - MCAS Session Control Unmanaged Devices
# ----------------------------------------
resource "azuread_conditional_access_policy" "ca006_mcas_session" {
  display_name = "CA006 - MCAS Session Control for Unmanaged Devices"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    devices {
      filter {
        mode = "exclude"
        rule = "device.isCompliant -eq True -or device.trustType -eq \"ServerAD\""
      }
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    cloud_app_security_policy = "mcasConfigured"
  }
}