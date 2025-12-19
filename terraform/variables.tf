variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox username (e.g., root@pam)"
  type        = string
  default     = null
}

variable "pm_password" {
  description = "Proxmox password (if not using API token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (recommended)"
  type        = string
  default     = null
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node to place the VM"
  type        = string
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "vm_hostname" {
  description = "Hostname for the VM (defaults to vm_name if not set)"
  type        = string
  default     = null
}

variable "vm_os_family" {
  description = "OS family for the VM. Controls defaults for cloud-init and provisioning. Allowed: linux, windows."
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.vm_os_family)
    error_message = "vm_os_family must be one of: linux, windows."
  }
}

variable "cloudinit_enabled" {
  description = "Whether to configure Cloud-Init initialization on the VM. If null, defaults to true for linux and false for windows."
  type        = bool
  default     = null
}

variable "provisioning_enabled" {
  description = "Whether to run post-provision steps (SSH remote-exec + local Ansible). If null, defaults to true for linux and false for windows."
  type        = bool
  default     = null
}

variable "vm_machine" {
  description = "QEMU machine type (e.g., pc, q35). Defaults to pc."
  type        = string
  default     = "pc"
}

variable "template" {
  description = "Template VM name to clone from. Required when vm_os_family = \"linux\". For Windows VMs, use windows_template_2019 / windows_template_2022 instead."
  type        = string
  default     = null
}

variable "windows_server_version" {
  description = "Windows Server version for Windows VMs. Allowed: 2019, 2022. Used when vm_os_family = \"windows\"."
  type        = string
  default     = "2022"

  validation {
    condition     = contains(["2019", "2022"], var.windows_server_version)
    error_message = "windows_server_version must be one of: 2019, 2022."
  }
}

variable "windows_template_2019" {
  description = "Proxmox template VM name for Windows Server 2019. Required when vm_os_family=\"windows\" and windows_server_version=\"2019\"."
  type        = string
  default     = null
}

variable "windows_template_2022" {
  description = "Proxmox template VM name for Windows Server 2022. Required when vm_os_family=\"windows\" and windows_server_version=\"2022\"."
  type        = string
  default     = null
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cpu_cores_per_socket" {
  description = "Number of cores per socket"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "disk_storage" {
  description = "Proxmox storage to place the disk"
  type        = string
  default     = "local-lvm"
}

variable "network_model" {
  description = "Network interface model"
  type        = string
  default     = "virtio"
}

variable "network_bridge" {
  description = "Bridge to attach NIC"
  type        = string
  default     = "vmbr0"
}

variable "cloudinit_user" {
  description = "Default user created by cloud-init"
  type        = string
  default     = "rocky"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key (leave empty to use cloudinit_ssh_keys instead)"
  type        = string
  default     = ""
}

variable "ssh_private_key_path" {
  description = "Path to private SSH key"
  type        = string
  default     = ""
}

variable "ip_config" {
  description = "ipconfig0 value (e.g., ip=dhcp)"
  type        = string
  default     = "ip=dhcp"
}

variable "qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Comma-separated tags for the VM"
  type        = string
  default     = ""
}

variable "cloudinit_packages" {
  description = "List of packages to install via cloud-init"
  type        = list(string)
  default     = ["curl", "htop", "git"]
}

variable "cloudinit_ssh_keys" {
  description = "List of SSH public keys to add (alternative to ssh_public_key_path)"
  type        = list(string)
  default     = []
}
