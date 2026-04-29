provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "varsha-rg"
  location = "Central India"
}