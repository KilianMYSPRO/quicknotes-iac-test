resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "main" {
  #checkov:skip=CKV_AZURE_206:LRS suffit pour un TP (GRS double le cout)
  #checkov:skip=CKV2_AZURE_1:cle geree par le client (Key Vault) hors programme
  #checkov:skip=CKV2_AZURE_33:point de terminaison prive payant, hors programme
  #checkov:skip=CKV_AZURE_59:acces public garde pour administrer depuis la VM de l'ecole
  #checkov:skip=CKV2_AZURE_40:cles partagees gardees (le provider en a besoin)
  #checkov:skip=CKV_AZURE_33:aucune file (queue) utilisee
  name                            = "stqn${var.environment}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # CKV2_AZURE_38 : corbeille, un blob supprime reste recuperable 7 jours
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # CKV2_AZURE_41 : les jetons SAS expirent au bout d'un jour
  shared_access_key_enabled = true
  sas_policy {
    expiration_period = "01.00:00:00"
  }
  tags = local.tags
}

resource "azurerm_storage_container" "sauvegardes" {
  #checkov:skip=CKV2_AZURE_21:journalisation des lectures (Log Analytics) hors programme
  name                  = "sauvegardes"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
