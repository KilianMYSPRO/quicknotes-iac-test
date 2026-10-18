variable "environment" {
  description = "Environnement : dev, test ou prod (doit correspondre au workspace)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "location" {
  description = "Region Azure (Azure for Students : seules certaines regions sont autorisees)"
  type        = string
  default     = "francecentral"
}

variable "vm_size" {
  description = "Taille des VM (Standard_B1s = 1 vCPU, 1 Go)"
  type        = string
  default     = "Standard_B1s"
}

variable "address_space" {
  description = "Plage d'adresses du reseau virtuel (differente par environnement)"
  type        = string
  default     = "10.10.0.0/16"
}

variable "allowed_ssh_cidr" {
  description = "Seule adresse autorisee en SSH, ex. IP publique de l'ecole : 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "allowed_ssh_cidr doit etre un CIDR valide (ex. 203.0.113.10/32), jamais 0.0.0.0/0."
  }
}

variable "admin_username" {
  description = "Utilisateur administrateur des VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Cle publique SSH installee sur les VM"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "owner" {
  description = "Proprietaire des ressources (tag), ex. votre login GitHub"
  type        = string
  default     = "etudiant"
}

variable "enable_nat_gateway" {
  description = "Plan de secours si db1 n'a pas acces a Internet (apt) : NAT Gateway (~1 $/jour)"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Bonus : alerte CPU > 80 % sur web1 (necessite Microsoft.Insights)"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Bonus : adresse qui recoit l'alerte (vide = pas d'e-mail)"
  type        = string
  default     = ""
}
