terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Resource group for networking

resource "azurerm_resource_group" "networking" {
  name     = "rg-varsha"
  location = "East US"

  tags = {
    Environment = "production"
    Purpose     = "networking"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-varsha"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name

  # Address space for the entire VNet
  address_space = ["10.0.0.0/16"]

  # Optional DNS servers (defaults to Azure-provided DNS)
  dns_servers = []

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Subnet for web tier
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  # Enable service endpoints for web tier
  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
}

# Subnet for application tier
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Sql", "Microsoft.KeyVault"]
}

# Subnet for database tier
resource "azurerm_subnet" "db" {
  name                 = "snet-db"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]

  # Delegate this subnet to a specific service
  delegation {
    name = "mysql-delegation"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
