terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.3.0"
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_user             = var.pm_user
  pm_password         = var.pm_password
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

locals {
  vm_hostname = var.vm_hostname != null ? var.vm_hostname : var.vm_name
  ssh_keys    = length(var.cloudinit_ssh_keys) > 0 ? join("\n", var.cloudinit_ssh_keys) : (var.ssh_public_key_path != "" ? file(var.ssh_public_key_path) : "")
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template
  full_clone  = true
  onboot      = true

  # Resources
  sockets = var.cpu_sockets
  cores   = var.cpu_cores_per_socket
  memory  = var.memory_mb
  cpu     = "host"

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = var.qemu_agent ? 1 : 0
  tags     = var.tags != "" ? var.tags : null

  disk {
    type    = "scsi"
    storage = var.disk_storage
    size    = "${var.disk_gb}G"
  }

  network {
    model  = var.network_model
    bridge = var.network_bridge
  }

  # Cloud-Init
  ciuser    = var.cloudinit_user
  sshkeys   = local.ssh_keys != "" ? local.ssh_keys : null
  ipconfig0 = var.ip_config
}
