# Versions de Terraform et des providers (verrouillees dans .terraform.lock.hcl)
terraform {
  required_version = ">= 1.7" # 1.7 minimum pour mock_provider dans terraform test

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  # Aller plus loin : etat partage dans Azure Storage (voir backend.tf.exemple)
}
