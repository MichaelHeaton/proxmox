# Proxmox Terraform Variables

variable "proxmox_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = false
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (format: user@realm!token-name)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification (not recommended for production)"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Proxmox cluster name"
  type        = string
  default     = "pve-cluster01"
}

variable "default_storage_pool" {
  description = "Default storage pool for VMs"
  type        = string
  default     = "disk-image-nfs-nas02"
}

variable "default_network_bridge" {
  description = "Default network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

