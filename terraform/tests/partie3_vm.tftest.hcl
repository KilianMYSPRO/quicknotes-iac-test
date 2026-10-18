# Tests de la PARTIE 3 (VM via le module). Ils echouent tant que le module n'est pas appele.

mock_provider "azurerm" {
  override_during = plan # valeurs simulees disponibles des le plan

  # azurerm verifie le FORMAT des identifiants : on fournit des ID plausibles
  mock_resource "azurerm_resource_group" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test" }
  }
  mock_resource "azurerm_subnet" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet" }
  }
  mock_resource "azurerm_network_security_group" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg" }
  }
  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip"
      ip_address = "20.50.60.70"
    }
  }
  mock_resource "azurerm_network_interface" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic" }
  }
  mock_resource "azurerm_linux_virtual_machine" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/vm" }
  }
  mock_resource "azurerm_storage_account" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/stqn" }
  }
  mock_resource "azurerm_nat_gateway" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/natGateways/nat" }
  }
  mock_resource "azurerm_monitor_action_group" {
    defaults = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/ag" }
  }
}

mock_provider "random" {
  override_during = plan
  mock_resource "random_string" {
    defaults = { result = "abc123" }
  }
}

mock_provider "local" {} # n'ecrit aucun fichier pendant les tests

# IP privees differentes pour web1 et db1
override_resource {
  target          = module.web.azurerm_network_interface.this
  override_during = plan
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic-web"
    private_ip_address = "10.10.1.4"
  }
}
override_resource {
  target          = module.db.azurerm_network_interface.this
  override_during = plan
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic-db"
    private_ip_address = "10.10.1.5"
  }
}

variables {
  environment         = "dev"
  allowed_ssh_cidr    = "203.0.113.10/32"
  ssh_public_key_path = "tests/fixtures/id_test.pub"
  owner               = "test"
}

run "vm_web_publique_db_privee" {
  command = plan

  assert {
    condition     = module.db.public_ip_address == null
    error_message = "db1 ne doit PAS avoir d'IP publique."
  }
  assert {
    condition     = module.web.public_ip_address == "20.50.60.70"
    error_message = "web1 doit avoir une IP publique."
  }
}
