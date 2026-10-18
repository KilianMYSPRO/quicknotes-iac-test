# Jonction Terraform -> Ansible : l'inventaire est GENERE a partir des ressources creees.
# Il est ecrit a cote de inventories/<env>/group_vars/ : les variables (et le vault)
# de l'environnement s'appliquent donc automatiquement.
resource "local_file" "inventaire" {
  filename        = "${path.module}/../ansible/inventories/${var.environment}/hosts-azure.yml"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/hosts.yml.tftpl", {
    environment    = var.environment
    admin_username = var.admin_username
    web_public_ip  = module.web.public_ip_address
    web_private_ip = module.web.private_ip_address
    db_private_ip  = module.db.private_ip_address
  })
}
