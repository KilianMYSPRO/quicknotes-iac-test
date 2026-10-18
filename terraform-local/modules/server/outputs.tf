output "ip_address" {
  value = docker_container.this.network_data[0].ip_address
}

output "id" {
  value = docker_container.this.id
}
