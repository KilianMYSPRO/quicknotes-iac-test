# ---------- Etape 1 : stockage (sauvegardes de la base) ----------
# Le nom d'un compte de stockage est UNIQUE dans tout Azure (3 a 24 caracteres,
# minuscules et chiffres) : on ajoute un suffixe aleatoire.

# TODO 1.1 : resource "random_string" "suffix" : length = 6, upper = false, special = false

# TODO 1.2 : resource "azurerm_storage_account" "main"
#   name                     = "stqn${var.environment}${random_string.suffix.result}"
#   resource_group_name, location : ceux du groupe de ressources (references !)
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   https_traffic_only_enabled      = true
#   min_tls_version                 = "TLS1_2"
#   allow_nested_items_to_be_public = false
#   tags                     = local.tags

# TODO 1.3 : resource "azurerm_storage_container" "sauvegardes"
#   name = "sauvegardes", storage_account_id = (id du compte), container_access_type = "private"
