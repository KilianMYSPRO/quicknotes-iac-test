# Tests de la PARTIE 4 (inventaire Ansible genere par Terraform).

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

run "inventaire_ansible" {
  command = plan

  assert {
    condition     = endswith(local_file.inventaire.filename, "ansible/inventories/dev/hosts-azure.yml")
    error_message = "Chemin d'inventaire inattendu : ${local_file.inventaire.filename}"
  }
  assert {
    condition     = strcontains(local_file.inventaire.content, "ansible_host: 20.50.60.70")
    error_message = "web1 doit etre joint par son IP publique."
  }
  assert {
    condition     = strcontains(local_file.inventaire.content, "ansible_host: 10.10.1.5") && strcontains(local_file.inventaire.content, "/dev/null azureuser@20.50.60.70")
    error_message = "db1 doit etre joint par son IP privee, en rebond par web1."
  }
  assert {
    condition     = yamldecode(local_file.inventaire.content).all.children.web.hosts.web1.private_ip == "10.10.1.4"
    error_message = "private_ip de web1 attendu dans l'inventaire (utilise par le template nginx)."
  }
}
