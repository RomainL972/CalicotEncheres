terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "34c6c373-ad28-45b2-a866-de1d853f2812"
  features {}
}
