output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "null si la VM n'a pas d'IP publique"
  value       = var.public_ip ? azurerm_public_ip.this[0].ip_address : null
}
