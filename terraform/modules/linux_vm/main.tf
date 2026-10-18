# Module : une VM Linux Ubuntu 24.04 + sa carte reseau (+ IP publique optionnelle)
# L'IP publique et la carte reseau sont FOURNIES. A vous d'ecrire la VM.

resource "azurerm_public_ip" "this" {
  count               = var.public_ip ? 1 : 0 # 1 ressource si public_ip = true, 0 sinon
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.tags, { role = var.role })
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { role = var.role })

  ip_configuration {
    name                          = "interne"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# TODO 3.0 : resource "azurerm_linux_virtual_machine" "this"
#   name, location, resource_group_name : les variables du module
#   size                  = var.vm_size
#   admin_username        = var.admin_username
#   network_interface_ids = [azurerm_network_interface.this.id]
#   tags                  = merge(var.tags, { role = var.role })
#   disable_password_authentication = true      # cle SSH uniquement
#   bloc admin_ssh_key { username = var.admin_username, public_key = var.ssh_public_key }
#   bloc os_disk { caching = "ReadWrite", storage_account_type = "Standard_LRS" }
#   bloc source_image_reference : publisher "Canonical", offer "ubuntu-24_04-lts",
#                                 sku "server", version "latest"
#   bloc boot_diagnostics {}                    # vide : capture de console geree par Azure
