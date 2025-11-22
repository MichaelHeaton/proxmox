# Proxmox Terraform Infrastructure

This directory contains Terraform configurations for managing the Proxmox cluster infrastructure.

## Structure

```
terraform/
├── environments/          # Environment-specific configurations
│   ├── production/
│   └── development/
├── modules/               # Reusable Terraform modules
│   ├── storage/
│   ├── network/
│   ├── vm/
│   └── access/
├── resources/             # Resource definitions
│   ├── storage.tf
│   ├── network.tf
│   ├── vm.tf
│   └── access.tf
├── data/                  # Data sources
├── variables.tf          # Variable definitions
├── outputs.tf            # Output definitions
├── terraform.tfvars.example
└── main.tf               # Main configuration
```

## Getting Started

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in your Proxmox credentials and configuration
3. Initialize Terraform: `terraform init`
4. Plan changes: `terraform plan`
5. Apply changes: `terraform apply`

## Importing Existing Resources

Use the discovery data in `../specs-homelab/proxmox-discovery/` to import existing resources:

```bash
terraform import proxmox_storage.nfs_backups backups-nfs
terraform import proxmox_network_bridge.vmbr0 GPU01/vmbr0
# etc.
```

## Modules

- **storage**: NFS shares, LVM pools, local storage
- **network**: Bridges, VLANs, physical interfaces
- **vm**: Virtual machines and containers
- **access**: Users, groups, roles, ACLs

