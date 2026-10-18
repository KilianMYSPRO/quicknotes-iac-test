resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnet_prefix]

  # Depuis le 31/03/2026, les nouveaux sous-reseaux Azure sont "prives" par defaut :
  # db1 (sans IP publique) n'aurait plus acces a Internet (apt install impossible).
  # En entreprise : NAT Gateway (payante). Ici : acces sortant par defaut, explicite.
  default_outbound_access_enabled = true
}

resource "azurerm_network_security_group" "main" {
  #checkov:skip=CKV_AZURE_160:HTTP 80 ouvert volontairement (site public) ; HTTPS = aller plus loin
  name                = "nsg-${local.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  security_rule {
    name                       = "SSH-depuis-ecole"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr # jamais 0.0.0.0/0
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP-depuis-Internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  # Le reste est refuse par les regles par defaut d'Azure (DenyAllInBound),
  # sauf le trafic interne au VNet (AllowVnetInBound) : web1 -> db1:5432 fonctionne.
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
