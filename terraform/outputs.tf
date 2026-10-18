output "resource_group_name" {
  description = "Groupe de ressources (a supprimer en fin de journee : terraform destroy)"
  value       = azurerm_resource_group.main.name
}

# TODO (etape 1) : supprimez /* et */ quand storage.tf est ecrit
/*
output "storage_account_name" {
  value = azurerm_storage_account.main.name
}
*/

# TODO (etape 3) : supprimez /* et */ quand les modules web et db sont appeles
/*
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
  value = "http://${module.web.public_ip_address}"
}

output "ssh_web" {
  value = "ssh ${var.admin_username}@${module.web.public_ip_address}"
}

output "ssh_db" {
  description = "Rebond par web1 : db1 n'a pas d'IP publique"
  value       = "ssh -J ${var.admin_username}@${module.web.public_ip_address} ${var.admin_username}@${module.db.private_ip_address}"
}
*/

# TODO (etape 4) : supprimez /* et */ en meme temps que dans inventory.tf
/*
output "inventaire_ansible" {
  value = abspath(local_file.inventaire.filename)
}
*/
