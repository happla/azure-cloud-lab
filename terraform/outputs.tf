output "vm_public_ip" {
  description = "public IP address of the Azure VM"
  value       = azurerm_public_ip.lab.ip_address
}

output "vm_admin_username" {
  description = "admin username for the Azure VM"
  value       = azurerm_linux_virtual_machine.lab.admin_username
}
