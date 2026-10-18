variable "name" {
  description = "Nom de la VM (ex. web1-dev)"
  type        = string
}

variable "role" {
  description = "Role fonctionnel (tag) : web, db..."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "Contenu de la cle publique SSH"
  type        = string
}

variable "public_ip" {
  description = "Creer une IP publique pour cette VM ?"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
