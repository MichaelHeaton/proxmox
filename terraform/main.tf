# Proxmox Terraform Configuration
# Main entry point for infrastructure management

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "proxmox-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configure the Proxmox Provider
provider "proxmox" {
  endpoint = var.proxmox_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure = var.proxmox_insecure
  ssh {
    agent = true
  }
}

