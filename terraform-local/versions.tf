# PLAN B sans cloud : memes principes que terraform/ (Azure), avec Docker.
# Les "serveurs" sont des conteneurs Ubuntu 24.04 avec systemd + SSH (image du lab du jour 1).
terraform {
  required_version = ">= 1.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "docker" {} # socket Docker local : aucun compte, aucun cout
