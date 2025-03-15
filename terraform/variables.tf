variable "suffix" {
  description = "Code d'identification"
  default    = "69420"
}

variable "location" {
  type        = string
  default     = "canadacentral"
  description = "Location of the resource group."
}

variable "web_resource_group_name" {
  type        = string
  default     = "rg-calicot-web-dev-10"
  description = ""
}

variable "common_resource_group_name" {
  type        = string
  default     = "rg-calicot-commun-001"
  description = ""
}

variable "sql_admin_user" {
  type        = string
  default     = "sqladmin"
  description = "SQL Server admin username"
}

variable "sql_admin_password" {
  type        = string
  default     = "P@ssw0rd1234!"
  description = "SQL Server admin password"
  sensitive = true
}

variable "tenant_id" {
  type        = string
  description = "The Azure tenant ID"
  default = "4dbda3f1-592e-4847-a01c-1671d0cc077f"
}

variable "object_id" {
  type        = string
  description = "The Azure object ID"
  default = "34c6c373-ad28-45b2-a866-de1d853f2812"
}
