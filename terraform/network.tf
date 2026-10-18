# ---------- Etape 2 : reseau ----------
# TODO 2.1 : resource "azurerm_virtual_network" "main"
#   name = "vnet-${local.name}", address_space = [var.address_space]
#   + resource_group_name, location, tags

# TODO 2.2 : resource "azurerm_subnet" "main"
#   name = "snet-app", virtual_network_name = (nom du VNet), address_prefixes = [local.subnet_prefix]
#   default_outbound_access_enabled = true   # db1 (sans IP publique) doit pouvoir faire apt install

# TODO 2.3 : resource "azurerm_network_security_group" "main"   name = "nsg-${local.name}"
#   Deux blocs security_rule (direction "Inbound", access "Allow", protocol "Tcp",
#   source_port_range "*", destination_address_prefix "*") :
#     - "SSH-depuis-ecole"     priority 100, port 22, source = var.allowed_ssh_cidr
#     - "HTTP-depuis-Internet" priority 110, port 80, source = "Internet"

# TODO 2.4 : resource "azurerm_subnet_network_security_group_association" "main"
#   subnet_id, network_security_group_id
