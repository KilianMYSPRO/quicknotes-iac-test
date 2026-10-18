# Authentification : az login (Azure CLI), rien a ecrire ici.
# azurerm v4 exige l'ID d'abonnement : export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
provider "azurerm" {
  features {}

  # "core" : enregistre seulement Compute, Network, Storage... (plus rapide que l'ancien mode)
  resource_provider_registrations = "core"
}
