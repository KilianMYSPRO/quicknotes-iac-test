# Tests de la PARTIE 2 (stockage et reseau), SANS compte Azure : providers simules.
# Lancement : terraform test   (tous les fichiers de tests/ sont executes)

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

variables {
  environment         = "dev"
  allowed_ssh_cidr    = "203.0.113.10/32"
  ssh_public_key_path = "tests/fixtures/id_test.pub"
  owner               = "test"
}

run "noms_et_tags" {
  command = plan

  assert {
    condition     = azurerm_resource_group.main.name == "rg-quicknotes-dev"
    error_message = "Le groupe de ressources doit etre suffixe par l'environnement."
  }
  assert {
    condition     = azurerm_resource_group.main.tags["environment"] == "dev" && azurerm_resource_group.main.tags["projet"] == "quicknotes"
    error_message = "Tags environment/projet manquants."
  }
  assert {
    condition     = azurerm_storage_account.main.name == "stqndevabc123"
    error_message = "Nom du compte de stockage inattendu : ${azurerm_storage_account.main.name}"
  }
}

run "securite_reseau" {
  command = plan

  assert {
    condition = anytrue([
      for r in azurerm_network_security_group.main.security_rule :
      r.destination_port_range == "80" && r.access == "Allow"
    ])
    error_message = "Le port 80 doit etre ouvert (site web)."
  }
  assert {
    condition = alltrue([
      for r in azurerm_network_security_group.main.security_rule :
      r.source_address_prefix == "203.0.113.10/32" if r.destination_port_range == "22"
    ])
    error_message = "SSH doit etre limite a allowed_ssh_cidr."
  }
  assert {
    condition     = azurerm_storage_account.main.https_traffic_only_enabled && azurerm_storage_account.main.min_tls_version == "TLS1_2"
    error_message = "Le stockage doit imposer HTTPS et TLS 1.2."
  }
}

run "ssh_ouvert_au_monde_refuse" {
  command = plan
  variables {
    allowed_ssh_cidr = "0.0.0.0/0"
  }
  expect_failures = [var.allowed_ssh_cidr]
}

run "environnement_inconnu_refuse" {
  command = plan
  variables {
    environment = "recette"
  }
  expect_failures = [var.environment]
}

run "environnement_test" {
  command = plan
  variables {
    environment   = "test"
    address_space = "10.20.0.0/16"
  }

  assert {
    condition     = azurerm_resource_group.main.name == "rg-quicknotes-test"
    error_message = "Nom du groupe de ressources test incorrect."
  }
  assert {
    condition     = azurerm_subnet.main.address_prefixes[0] == "10.20.1.0/24"
    error_message = "Le sous-reseau doit decouler de la plage de l'environnement."
  }
}
