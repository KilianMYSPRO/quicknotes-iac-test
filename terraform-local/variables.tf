variable "environment" {
  description = "Environnement : dev, test ou prod (doit correspondre au workspace)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "prefix" {
  description = "Prefixe des noms de conteneurs et reseaux"
  type        = string
  default     = "qn"
}

variable "subnet" {
  description = "Plage du reseau Docker (differente par environnement)"
  type        = string
  default     = "172.31.10.0/24"
}

variable "web_port" {
  description = "Port de la VM qui publie le port 80 de web1"
  type        = number
  default     = 8081
}

variable "ssh_public_key_path" {
  description = "Cle publique SSH installee sur les serveurs"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
