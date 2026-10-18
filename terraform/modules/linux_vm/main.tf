# Module : une VM Linux Ubuntu 24.04 + sa carte reseau (+ IP publique optionnelle)
resource "azurerm_public_ip" "this" {
  count               = var.public_ip ? 1 : 0
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

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = merge(var.tags, { role = var.role })


  # Connexion par cle SSH uniquement : aucun mot de passe
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
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

  # Diagnostics de demarrage (capture de la console) : stockage gere par Azure
  boot_diagnostics {}
}
