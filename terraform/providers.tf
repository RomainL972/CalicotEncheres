terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg-calicot-web-dev-10"
    storage_account_name  = "team10storage"
    container_name        = "state"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "34c6c373-ad28-45b2-a866-de1d853f2812"
  features {}
}
