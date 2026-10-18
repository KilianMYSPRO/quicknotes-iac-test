# Jonction Terraform -> Ansible : meme principe que sur Azure.
# Ecrit a cote de inventories/<env>/group_vars/ : vars et vault de l'env s'appliquent.
# TODO 4 : supprimez les deux lignes /* et */ pour activer ce bloc.
/*
resource "local_file" "inventaire" {
  filename        = "${path.module}/../ansible/inventories/${var.environment}/hosts-local.yml"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/hosts.yml.tftpl", {
    environment    = var.environment
    admin_username = "student"
    web_public_ip  = module.web.ip_address # joignable depuis la VM (reseau Docker)
    web_private_ip = module.web.ip_address
    db_private_ip  = module.db.ip_address
  })
}
*/
