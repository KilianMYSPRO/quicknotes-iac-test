locals {
  name = "quicknotes-${var.environment}"
  tags = {
    environment = var.environment
    projet      = "quicknotes"
    owner       = var.owner
    managed_by  = "terraform"
  }
  # Sous-reseau : premier /24 de la plage du VNet (ex. 10.10.1.0/24)
  subnet_prefix = cidrsubnet(var.address_space, 8, 1)
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags

  lifecycle {
    # Garde-fou : test.tfvars applique dans le workspace dev DETRUIRAIT dev.
    # Le workspace "default" reste accepte (terraform test, CI).
    precondition {
      condition     = contains(["default", var.environment], terraform.workspace)
      error_message = "Workspace '${terraform.workspace}' different de environment='${var.environment}' : faites terraform workspace select ${var.environment}."
    }
  }
}

# ---------- Machines virtuelles (module reutilise 2 fois : exercice 4) ----------
module "web" {
  source = "./modules/linux_vm"

  name                = "web1-${var.environment}"
  role                = "web"
  resource_group_name = azurerm_resource_group.main.name # dependance implicite
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
  public_ip           = true # seule VM exposee sur Internet
  tags                = local.tags

  # Dependance EXPLICITE : rien dans le module ne reference l'association NSG.
  # Sans elle, la VM pourrait etre creee avant que le pare-feu soit attache :
  # IP publique Standard = tout est ferme -> Ansible echouerait (timeout SSH).
  depends_on = [azurerm_subnet_network_security_group_association.main]
}

module "db" {
  source = "./modules/linux_vm"

  name                = "db1-${var.environment}"
  role                = "db"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
  public_ip           = false # base de donnees : PAS d'IP publique (acces via web1)
  tags                = local.tags

  depends_on = [azurerm_subnet_network_security_group_association.main]
}
