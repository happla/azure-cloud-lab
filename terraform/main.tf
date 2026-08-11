terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-azure-cloud-lab"
  location = "Sweden Central"
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-azure-cloud-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "lab" {
  name                 = "subnet-azure-cloud-lab"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "lab" {
  name                = "pip-azure-cloud-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "lab" {
  name                = "nic-azure-cloud-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}

resource "azurerm_network_security_group" "lab" {
  name                = "nsg-azure-cloud-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_linux_virtual_machine" "lab" {
  name                = "vm-azure-cloud-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_B2s_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.lab.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
