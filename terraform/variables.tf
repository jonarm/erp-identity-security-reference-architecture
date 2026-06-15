# terraform/variables.tf

variable "tenant_id" {
  description = "Microsoft Entra ID Tenant ID"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Service Principal Client ID for Terraform"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Service Principal Client Secret for Terraform"
  type        = string
  sensitive   = true
}

variable "erp_app_display_name" {
  description = "Display name for the Dynamics 365 ERP enterprise application"
  type        = string
  default     = "Contoso Financial Services - Dynamics 365"
}

variable "erp_app_identifier_uri" {
  description = "Identifier URI for the ERP application"
  type        = string
  default     = "https://d365.jonarmarzan.onmicrosoft.com"
}

variable "environment" {
  description = "Environment tag for all resources"
  type        = string
  default     = "lab"
}

variable "owner" {
  description = "Owner tag for all resources"
  type        = string
  default     = "Jonar"
}