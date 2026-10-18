# Module : un "serveur" Ubuntu 24.04 (conteneur systemd + SSH), equivalent de linux_vm
resource "docker_container" "this" {
  name     = var.name
  hostname = var.hostname
  image    = var.image_id

  # systemd dans un conteneur (comme le lab du jour 1)
  privileged    = true
  cgroupns_mode = "private"
  tmpfs = {
    "/run"      = ""
    "/run/lock" = ""
  }

  # La cle publique est deposee AVANT le demarrage ; l'entrypoint de l'image
  # la copie dans ~student/.ssh/authorized_keys (equivalent de admin_ssh_key)
  upload {
    file    = "/lab-ssh/id_ed25519.pub"
    content = var.ssh_public_key
  }

  networks_advanced {
    name    = var.network_name
    aliases = [var.hostname]
  }

  dynamic "ports" {
    for_each = var.published_port == null ? [] : [var.published_port]
    content {
      internal = 80
      external = ports.value
    }
  }

  dynamic "volumes" {
    for_each = var.backup_volume == null ? [] : [var.backup_volume]
    content {
      volume_name    = volumes.value
      container_path = "/var/backups/quicknotes"
    }
  }

  dynamic "labels" {
    for_each = merge(var.labels, { role = var.role })
    content {
      label = labels.key
      value = labels.value
    }
  }

  restart = "unless-stopped"
}
