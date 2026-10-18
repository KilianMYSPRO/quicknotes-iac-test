# =====================================================================
#  PLAN B (sans Azure) : meme TP3, avec des conteneurs Docker comme "VM"
#  FOURNI : versions.tf, variables.tf, envs/, templates/, modules/server (complet)
#  A ECRIRE : les TODO ci-dessous, puis activer outputs.tf et inventory.tf
#  Correspondance Azure -> local :
#    resource group -> (rien)   VNet + subnet -> docker_network
#    storage account -> docker_volume   VM -> module server (conteneur systemd + SSH)
#    IP publique -> port publie sur la VM (web_port)
# =====================================================================

locals {
  name = "${var.prefix}-${var.environment}" # ex. qn-dev
  labels = {
    environment = var.environment
    projet      = "quicknotes"
    managed_by  = "terraform"
  }
}

# Image des "serveurs" : celle du lab du jour 1, deja construite sur la VM.
# "data" = Terraform LIT une ressource existante sans la gerer.
data "docker_image" "server" {
  name = "lab-server:1"
}

# TODO 2 : resource "docker_network" "main"
#   name = "net-${local.name}"
#   bloc ipam_config { subnet = var.subnet, gateway = cidrhost(var.subnet, 1) }
#   bloc lifecycle { precondition { ... } } : recopier celui de terraform/main.tf (Azure)
#     condition = contains(["default", var.environment], terraform.workspace)

# TODO 1 : resource "docker_volume" "sauvegardes"   name = "vol-${local.name}-sauvegardes"

# TODO 3.1 : module "web" { source = "./modules/server" ... }
#   name = "${local.name}-web1", hostname = "web1", role = "web"
#   image_id       = data.docker_image.server.id
#   network_name   = (nom du reseau ci-dessus)
#   ssh_public_key = file(pathexpand(var.ssh_public_key_path))
#   published_port = var.web_port
#   labels         = local.labels
#
# TODO 3.2 : module "db" : name "${local.name}-db1", hostname "db1", role "db",
#   published_port = null, backup_volume = (nom du volume)
