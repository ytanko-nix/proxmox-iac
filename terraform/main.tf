terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.87.0"

    }
  }
  required_version = ">= 1.3.0"
}

provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = var.pm_api_token_id != null && var.pm_api_token_secret != null ? "${var.pm_api_token_id}=${var.pm_api_token_secret}" : null
  username  = var.pm_api_token_id == null ? var.pm_user : null
  password  = var.pm_api_token_id == null ? var.pm_password : null
  insecure  = var.pm_tls_insecure
}

locals {
  vm_hostname    = var.vm_hostname != null ? var.vm_hostname : var.vm_name
  ssh_keys       = length(var.cloudinit_ssh_keys) > 0 ? var.cloudinit_ssh_keys : (var.ssh_public_key_path != "" ? [file(var.ssh_public_key_path)] : [])
  template_found = length(data.proxmox_virtual_environment_vms.templates.vms) > 0
  template_vm_id = local.template_found ? parseint(regex("^(\\d+)", data.proxmox_virtual_environment_vms.templates.vms[0].vm_id)[0], 10) : -1
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.target_node
  machine   = "pc"

  clone {
    vm_id = local.template_vm_id
    full  = true
  }

  lifecycle {
    precondition {
      condition     = local.template_found
      error_message = "Template '${var.template}' not found on node '${var.target_node}'. Please verify the template exists and the name matches exactly (case-sensitive)."
    }
  }

  cpu {
    sockets = var.cpu_sockets
    cores   = var.cpu_cores_per_socket
    type    = "max" # Maximum CPU features for better compatibility without KVM
  }

  vga {
    type = "std"
  }

  memory {
    dedicated = var.memory_mb
  }

  network_device {
    model  = var.network_model
    bridge = var.network_bridge
  }

  agent {
    enabled = var.qemu_agent
  }

  initialization {
    user_account {
      username = var.cloudinit_user
      keys     = local.ssh_keys
    }

    ip_config {
      ipv4 {
        address = var.ip_config == "ip=dhcp" ? "dhcp" : null
      }
    }
  }

  on_boot = true
  started = true
  tags    = var.tags != "" ? split(",", var.tags) : []
}

data "proxmox_virtual_environment_vms" "templates" {
  node_name = var.target_node
  tags      = []
  filter {
    name   = "name"
    values = [var.template]
  }
}
