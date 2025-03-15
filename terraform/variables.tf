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
