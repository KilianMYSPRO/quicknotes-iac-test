# TODO 3 et 4 : supprimez /* et */ quand les modules et l'inventaire sont ecrits
/*
output "web_ip" {
  value = module.web.ip_address
}

output "db_ip" {
  value = module.db.ip_address
}

output "url" {
  description = "Depuis le navigateur : http://<IP de votre VM>:<web_port>"
  value       = "http://localhost:${var.web_port}"
}

output "ssh_db" {
  description = "Rebond par web1, comme sur Azure"
  value       = "ssh -J student@${module.web.ip_address} student@${module.db.ip_address}"
}

output "inventaire_ansible" {
  value = abspath(local_file.inventaire.filename)
}
*/
