# Proxmox Terraform Configuration
# Main entry point for infrastructure management

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # HCP Terraform Cloud backend (CLI-driven workflow)
  # Organization name can be overridden via TF_CLOUD_ORGANIZATION environment variable
  cloud {
    organization = "SpecterRealm"

    workspaces {
      name = "homelab-proxmox"
    }
  }
}

# Configure the Proxmox Provider
provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = var.proxmox_insecure
  ssh {
    agent = true
  }
}


# Proxmox Virtual Machine Resources
# Import existing QEMU VMs from discovery data
#
# NOTE: These are minimal resource definitions for import.
# After importing, run `terraform show` to see the actual configuration,
# then update these resources to match your desired state.

# GPU01 VMs
resource "proxmox_virtual_environment_vm" "minecraft01" {
  name      = "Minecraft01"
  node_name = "GPU01"
  vm_id     = 103

  # Preserve existing configuration - don't manage these attributes
  lifecycle {
    ignore_changes = [
      # Don't change existing VM configuration
      cpu,
      memory,
      disk,
      network_device,
      operating_system,
      agent,
      machine,
      description,
      tags,
      on_boot,
      started,
      scsi_hardware,
      keyboard_layout, # Ignore default keyboard layout
    ]
  }
}

# Note: VM 102 (plex) and VM 105 (k8s-01) do not exist in Proxmox
# Removed resource definitions - these VMs were deleted or never created

# GPU01 VMs - Template
resource "proxmox_virtual_environment_vm" "ubuntu_24_04_hardened_template" {
  name      = "ubuntu-24.04-hardened" # Actual name in Proxmox
  node_name = "GPU01"
  vm_id     = 100
  template  = true # This is a template

  # Preserve existing template configuration
  lifecycle {
    ignore_changes = [
      # Don't change existing template configuration
      cpu,
      memory,
      disk,
      network_device,
      operating_system,
      agent,
      machine,
      description,
      tags,
      on_boot,
      started,
      scsi_hardware,
      boot_order,
      keyboard_layout, # Ignore default keyboard layout
    ]
  }
}

resource "proxmox_virtual_environment_vm" "test4" {
  name      = "Test4" # Actual name in Proxmox
  node_name = "GPU01"
  vm_id     = 101

  # Preserve existing VM configuration
  lifecycle {
    ignore_changes = [
      # Don't change existing VM configuration
      cpu,
      memory,
      disk,
      network_device,
      operating_system,
      agent,
      machine,
      description,
      tags,
      on_boot,
      started,
      scsi_hardware,
      boot_order,
      keyboard_layout, # Ignore default keyboard layout
    ]
  }
}

# Note: VMs 104 (dns), 106 (k8s-02), 107 (k8s-03), 108 (postgresql) do not exist in Proxmox
# Removed resource definitions - these VMs were deleted or never created

# Proxmox Network Resources
# Import existing network bridges and VLANs from discovery data

# Network Bridges
# Note: Network configuration in Proxmox is typically managed at the node level
# These resources represent the network bridges on each node

# GPU01 Network Bridges
resource "proxmox_virtual_environment_network_linux_bridge" "gpu01_vmbr0" {
  node_name = "GPU01"
  name      = "vmbr0"

  address = "172.16.15.10/24"
  gateway = "172.16.15.1"

  ports = ["enp7s0"]

  vlan_aware = true

}

resource "proxmox_virtual_environment_network_linux_bridge" "gpu01_vmbr1" {
  node_name = "GPU01"
  name      = "vmbr1"

  address = "172.16.30.10/24"

  ports = ["enp11s0"]

  vlan_aware = true

  # Note: enp11s0 is a 10 GbE SFP+ interface dedicated to high-bandwidth storage access (VLAN 30)
  # This provides 10x the bandwidth compared to NUC01/NUC02's 1 GbE interfaces
  # VMs requiring high storage I/O should remain on GPU01 to utilize this 10 GbE connection
}

# GPU01 VLAN Interface
resource "proxmox_virtual_environment_network_linux_vlan" "gpu01_enp11s0_12" {
  node_name = "GPU01"
  name      = "enp11s0.12"

  interface = "enp11s0"

  address = "172.16.12.10/24"
}

# NUC02 Network Bridges
# Note: NUC02 has only one NIC (enp89s0, 1 GbE), so it uses a single VLAN-aware bridge (vmbr0)
# with VLAN sub-interfaces, unlike GPU01 which has separate bridges on separate NICs
#
# Architecture difference:
# - GPU01: vmbr0 (1 GbE) for general network, vmbr1 (10 GbE SFP+) for storage
# - NUC02: vmbr0 (1 GbE) for all traffic, including storage (limited to 1 GbE)
#
# Performance impact: VMs migrated from GPU01 to NUC02 will have 10x slower storage access
# (1 GbE vs 10 GbE). Consider keeping storage-intensive VMs on GPU01.
resource "proxmox_virtual_environment_network_linux_bridge" "nuc02_vmbr0" {
  node_name = "NUC02"
  name      = "vmbr0"

  address = "172.16.15.12/24"
  gateway = "172.16.15.1"

  ports = ["enp89s0"]

  vlan_aware = true
}

# Note: NUC02 does NOT have vmbr1 - it uses vmbr0 with VLAN tagging instead
# VMs that need VLAN 30 (storage) access should use: bridge=vmbr0,tag=30
# This will work but is limited to 1 GbE instead of GPU01's 10 GbE storage connection

# Physical Interface Configuration (MTU)
# Note: Physical interface MTU configuration may need to be managed separately
# or via cloud-init/scripts as the provider may not support all interface settings

# Proxmox Resource Pools
# Import existing resource pools from discovery data

resource "proxmox_virtual_environment_pool" "gitops" {
  pool_id = "gitops"
  # comment = "GitOps managed resources"  # Commented out to avoid unnecessary changes
}

# Proxmox Storage Resources
# NOTE: The bpg/proxmox provider does NOT support managing storage resources via Terraform.
# Storage pools are managed using null_resource with local-exec to call the Proxmox API directly.
#
# Storage configuration is documented in:
# - ../../specs-homelab/proxmox-discovery/09-storage-list.json
# - ../../specs-homelab/storage/proxmox-storage.md
# - ../../specs-homelab/storage/nas-share-layout.md

# NAS01 (Synology) - High IOPS Storage Pools
# Server: 172.16.30.5
# Export format: /volume{number}/{share-name}

resource "null_resource" "storage_lxcs_iops" {
  # Create lxcs-iops storage pool from NAS01
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/lxcs-iops" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage lxcs-iops..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=lxcs-iops" \
          -d "type=nfs" \
          -d "server=172.16.30.5" \
          -d "export=/volume1/lxcs-iops" \
          -d "content=rootdir"
        echo "Storage lxcs-iops created successfully"
      else
        echo "Storage lxcs-iops already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "lxcs-iops"
    server     = "172.16.30.5"
    export     = "/volume1/lxcs-iops"
  }
}

resource "null_resource" "storage_vmdks_iops" {
  # Create vmdks-iops storage pool from NAS01
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/vmdks-iops" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage vmdks-iops..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=vmdks-iops" \
          -d "type=nfs" \
          -d "server=172.16.30.5" \
          -d "export=/volume1/vmdks-iops" \
          -d "content=images"
        echo "Storage vmdks-iops created successfully"
      else
        echo "Storage vmdks-iops already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "vmdks-iops"
    server     = "172.16.30.5"
    export     = "/volume1/vmdks-iops"
  }
}

# NAS02 (UniFi UNAS Pro) - Medium IOPS Storage Pools
# Server: 172.16.30.4
# Export format: /var/nfs/shared/{share-name}

resource "null_resource" "storage_lxcs" {
  # Create lxcs storage pool from NAS02
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/lxcs" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage lxcs..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=lxcs" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/lxcs" \
          -d "content=rootdir"
        echo "Storage lxcs created successfully"
      else
        echo "Storage lxcs already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "lxcs"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/lxcs"
  }
}

resource "null_resource" "storage_vmdks" {
  # Create vmdks storage pool from NAS02
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/vmdks" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage vmdks..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=vmdks" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/vmdks" \
          -d "content=images"
        echo "Storage vmdks created successfully"
      else
        echo "Storage vmdks already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "vmdks"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/vmdks"
  }
}

resource "null_resource" "storage_isos" {
  # Create isos storage pool from NAS02 (replaces old iso-nfs)
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/isos" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage isos..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=isos" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/isos" \
          -d "content=iso"
        echo "Storage isos created successfully"
      else
        echo "Storage isos already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "isos"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/isos"
  }
}

resource "null_resource" "storage_templates_proxmox" {
  # Create templates-proxmox storage pool from NAS02 (replaces old templates-nfs)
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/templates-proxmox" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage templates-proxmox..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=templates-proxmox" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/templates_proxmox" \
          -d "content=vztmpl"
        echo "Storage templates-proxmox created successfully"
      else
        echo "Storage templates-proxmox already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "templates-proxmox"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/templates_proxmox"
  }
}

resource "null_resource" "storage_snippets_proxmox" {
  # Create snippets-proxmox storage pool from NAS02 (replaces old snippets-nfs)
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/snippets-proxmox" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage snippets-proxmox..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=snippets-proxmox" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/snippets_proxmox" \
          -d "content=snippets"
        echo "Storage snippets-proxmox created successfully"
      else
        echo "Storage snippets-proxmox already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "snippets-proxmox"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/snippets_proxmox"
  }
}

resource "null_resource" "storage_import_proxmox" {
  # Create import-proxmox storage pool from NAS02 (new share)
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if storage already exists
      if ! curl -k -s -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        "${var.proxmox_url}/storage/import-proxmox" > /dev/null 2>&1; then
        # Storage doesn't exist, create it
        echo "Creating storage import-proxmox..."
        curl -k -f -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
          -X POST "${var.proxmox_url}/storage" \
          -d "storage=import-proxmox" \
          -d "type=nfs" \
          -d "server=172.16.30.4" \
          -d "export=/var/nfs/shared/import_proxmox" \
          -d "content=images"
        echo "Storage import-proxmox created successfully"
      else
        echo "Storage import-proxmox already exists, skipping creation"
      fi
    EOT
  }

  triggers = {
    storage_id = "import-proxmox"
    server     = "172.16.30.4"
    export     = "/var/nfs/shared/import_proxmox"
  }
}


