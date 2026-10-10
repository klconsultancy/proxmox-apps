output "vm_id" {
  value = proxmox_virtual_environment_container.this.vm_id
}

output "ipv4_address" {
  description = "Static IPv4 address without prefix length, or null with `dhcp`."
  value       = var.ipv4_address == "dhcp" ? null : split("/", var.ipv4_address)[0]
}
