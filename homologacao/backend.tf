terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "treinamenttos"
    container_name       = "tfstate"
    key                  = "homolog/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
