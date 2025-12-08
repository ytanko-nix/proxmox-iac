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

  provisioner "remote-exec" {
    inline = [
      "echo '=== Stage 1: Waiting for cloud-init (max 5 min) ==='",
      "START_TIME=$(date +%s)",
      "timeout 300 cloud-init status --wait || echo 'cloud-init timeout or not available, continuing...'",
      "echo \"Cloud-init completed in $(($(date +%s) - START_TIME)) seconds\"",
      "echo '=== Stage 2: Checking network and mirrors ==='",
      "echo 'Testing DNS resolution...'",
      "host google.com > /dev/null 2>&1 && echo 'DNS: OK' || echo 'DNS: FAILED'",
      "echo 'Testing mirror accessibility...'",
      "if which dnf > /dev/null 2>&1; then curl -s --connect-timeout 10 --max-time 30 -o /dev/null -w 'Mirror response: %%{http_code}, time: %%{time_total}s\n' https://dl.rockylinux.org/pub/rocky/ || echo 'Rocky mirror: SLOW or UNREACHABLE'; else curl -s --connect-timeout 10 --max-time 30 -o /dev/null -w 'Mirror response: %%{http_code}, time: %%{time_total}s\n' http://archive.ubuntu.com/ubuntu/ || echo 'Ubuntu mirror: SLOW or UNREACHABLE'; fi",
      "echo '=== Stage 3: Installing Python3 for Ansible ==='",
      "START_TIME=$(date +%s)",
      "if which dnf > /dev/null 2>&1; then sudo dnf install -y python3 --setopt=timeout=60; else sudo apt-get update && sudo apt-get install -y python3; fi",
      "echo \"Python3 installed in $(($(date +%s) - START_TIME)) seconds\""
    ]

    connection {
      type        = "ssh"
      user        = var.cloudinit_user
      agent       = true
      host        = self.ipv4_addresses[1][0]
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.ipv4_addresses[1][0]},' -u ${var.cloudinit_user} ../ansible/java_tomcat.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ''",
      "echo '╔══════════════════════════════════════════════════════════════════╗'",
      "echo '║              DEPLOYMENT COMPLETED SUCCESSFULLY                   ║'",
      "echo '╚══════════════════════════════════════════════════════════════════╝'",
      "echo ''",
      "echo '=== Verification Results ==='",
      "echo ''",
      "JAVA_VER=$(java -version 2>&1 | head -1)",
      "TOMCAT_STATUS=$(systemctl is-active tomcat)",
      "HTTP_CODE=$(curl -s -o /dev/null -w '%%{http_code}' http://localhost:8080)",
      "echo \"  Java:    $JAVA_VER\"",
      "echo \"  Tomcat:  $TOMCAT_STATUS (HTTP $HTTP_CODE)\"",
      "echo ''",
      "echo '=== Access Information ==='",
      "echo ''",
      "echo '  VM Name:     ${var.vm_name}'",
      "echo '  IP Address:  ${self.ipv4_addresses[1][0]}'",
      "echo '  SSH User:    ${var.cloudinit_user}'",
      "echo ''",
      "echo '  Tomcat URL:  http://${self.ipv4_addresses[1][0]}:8080'",
      "echo ''",
      "echo '  SSH Login:   ssh ${var.cloudinit_user}@${self.ipv4_addresses[1][0]}'",
      "echo '  Check Java:  ssh ${var.cloudinit_user}@${self.ipv4_addresses[1][0]} java -version'",
      "echo ''",
      "echo '══════════════════════════════════════════════════════════════════════'"
    ]

    connection {
      type        = "ssh"
      user        = var.cloudinit_user
      agent       = true
      host        = self.ipv4_addresses[1][0]
    }
  }
}

data "proxmox_virtual_environment_vms" "templates" {
  node_name = var.target_node
  tags      = []
  filter {
    name   = "name"
    values = [var.template]
  }
}
