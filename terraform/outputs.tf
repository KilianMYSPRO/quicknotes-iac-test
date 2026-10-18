output "resource_group_name" {
  description = "Groupe de ressources (a supprimer en fin de journee : terraform destroy)"
  value       = azurerm_resource_group.main.name
}

output "web_public_ip" {
  description = "IP publique de web1"
  value       = module.web.public_ip_address
}

output "web_private_ip" {
  value = module.web.private_ip_address
}

output "db_private_ip" {
  description = "IP privee de db1 (pas d'IP publique)"
  value       = module.db.private_ip_address
}

output "url" {
  description = "Adresse du site une fois Ansible passe"
  value       = "http://${module.web.public_ip_address}"
}

output "ssh_web" {
  value = "ssh ${var.admin_username}@${module.web.public_ip_address}"
}

output "ssh_db" {
  description = "Rebond par web1 (ProxyJump) : db1 n'est pas joignable directement"
  value       = "ssh -J ${var.admin_username}@${module.web.public_ip_address} ${var.admin_username}@${module.db.private_ip_address}"
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "inventaire_ansible" {
  value = abspath(local_file.inventaire.filename)
}
