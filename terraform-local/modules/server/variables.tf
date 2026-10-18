variable "name" {
  description = "Nom du conteneur (ex. qn-dev-web1)"
  type        = string
}

variable "hostname" {
  type = string
}

variable "role" {
  type = string
}

variable "image_id" {
  type = string
}

variable "network_name" {
  type = string
}

variable "ssh_public_key" {
  description = "Contenu de la cle publique SSH"
  type        = string
}

variable "published_port" {
  description = "Port de l'hote qui publie le port 80 (null = non expose)"
  type        = number
  default     = null
}

variable "backup_volume" {
  description = "Volume monte sur /var/backups/quicknotes (null = aucun)"
  type        = string
  default     = null
}

variable "labels" {
  type    = map(string)
  default = {}
}
