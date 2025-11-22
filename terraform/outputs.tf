# Proxmox Terraform Outputs

output "cluster_name" {
  description = "Proxmox cluster name"
  value       = var.cluster_name
}

output "proxmox_url" {
  description = "Proxmox API URL"
  value       = var.proxmox_url
  sensitive   = false
}

