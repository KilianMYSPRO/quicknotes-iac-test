# =====================================================================
#  TP3 : infrastructure QuickNotes sur Azure
#  Fichiers FOURNIS : versions.tf, providers.tf, variables.tf, envs/, templates/
#  A ECRIRE : les blocs marques TODO (main.tf, storage.tf, network.tf,
#             modules/linux_vm/main.tf), puis decommenter outputs.tf et inventory.tf
#  Les noms de ressources sont IMPOSES : terraform test les verifie.
# =====================================================================

locals {
  name = "quicknotes-${var.environment}" # ex. quicknotes-dev
  tags = {
    environment = var.environment
    projet      = "quicknotes"
    owner       = var.owner
    managed_by  = "terraform"
  }
  # Sous-reseau : premier /24 de la plage du VNet (10.10.0.0/16 -> 10.10.1.0/24)
  subnet_prefix = cidrsubnet(var.address_space, 8, 1)
}

# ---------- Etape 1 : groupe de ressources (FOURNI : c'est votre modele) ----------
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags

  lifecycle {
    # Garde-fou : test.tfvars applique dans le workspace dev DETRUIRAIT dev.
    precondition {
      condition     = contains(["default", var.environment], terraform.workspace)
      error_message = "Workspace '${terraform.workspace}' different de environment='${var.environment}' : faites terraform workspace select ${var.environment}."
    }
  }
}

# ---------- Etape 3 : les deux VM, avec le module modules/linux_vm ----------
# TODO 3.1 : appeler le module pour la VM web
#   module "web" {
#     source = "./modules/linux_vm"
#     arguments a donner (voir modules/linux_vm/variables.tf) :
#       name                = "web1-${var.environment}"
#       role                = "web"
#       resource_group_name = (nom du groupe de ressources ci-dessus)
#       location            = (region du groupe de ressources)
#       subnet_id           = (id du sous-reseau, network.tf)
#       vm_size, admin_username : les variables du meme nom
#       ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
#       public_ip           = true
#       tags                = local.tags
#     depends_on = [azurerm_subnet_network_security_group_association.main]
#   }
#
# TODO 3.2 : appeler le module une 2e fois pour "db" (name db1-..., role db, public_ip = false)
