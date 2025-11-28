# Outputs for Ansible integration
# These values are used by scripts/generate_inventory.sh

output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "vm_ip" {
  description = "The IP address of the created VM (from QEMU agent)"
  value       = try(proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0], "pending")
}

output "vm_user" {
  description = "The SSH user for the VM (from cloud-init)"
  value       = var.cloudinit_user
}

output "vm_node" {
  description = "The Proxmox node where the VM is running"
  value       = proxmox_virtual_environment_vm.vm.node_name
}

