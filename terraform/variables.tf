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

variable "template" {
  description = "Cloud-Init template to clone from"
  type        = string
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
