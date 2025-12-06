# Proxmox Terraform Infrastructure

This directory contains Terraform configurations for managing the Proxmox cluster infrastructure.

## Structure

```
terraform/
├── data/                  # Data sources
│   └── cluster.tf        # Cluster/node information
├── scripts/              # Utility scripts
│   └── import-all-resources.sh  # Automated import script
├── variables.tf          # Variable definitions
├── outputs.tf            # Output definitions
├── terraform.tfvars.example  # Example variables file
├── terraform.tfvars      # Your actual variables (gitignored)
├── import-ids.txt        # Import commands for existing resources
├── main.tf               # Main configuration (all resources)
└── *.md                  # Documentation files
```

**Note**: All resources are defined in `main.tf` because HCP Terraform Cloud in CLI-driven workflow does not load resources from subdirectories.

## Getting Started

### Prerequisites

- **HCP Terraform Cloud Account**: You need a HashiCorp Cloud Platform account
- **Workspace Created**: Create a workspace named `homelab-proxmox` in HCP Terraform (see [HCP-WORKSPACE-SETUP.md](./HCP-WORKSPACE-SETUP.md))
- **Proxmox API Access**: Ensure your Proxmox cluster has API access configured

### Initial Setup

1. **Set up HCP Workspace** (see [HCP-WORKSPACE-SETUP.md](./HCP-WORKSPACE-SETUP.md) for detailed instructions):

   - Create workspace `homelab-proxmox` in HCP
   - Configure execution mode to **Local** (required for internal Proxmox access)
   - Authenticate: `terraform login`

2. **Copy and configure variables**:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Proxmox credentials
   ```

3. **Initialize Terraform**:

   ```bash
   terraform init
   ```

4. **Verify configuration**:
   ```bash
   terraform validate
   terraform plan
   ```

## Importing Existing Resources

See [IMPORT.md](./IMPORT.md) for detailed import instructions.

Quick start:

```bash
# 1. Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials

# 2. Initialize Terraform
terraform init

# 3. Import all resources (automated)
./scripts/import-all-resources.sh

# Or import manually using commands from import-ids.txt
```

The discovery data in `../../specs-homelab/proxmox-discovery/` was used to create the resource definitions.

## Managed Resources

### Virtual Machines

- QEMU VMs are managed via `proxmox_virtual_environment_vm` resources
- Templates are also managed (with `template = true`)
- See `main.tf` for current VM definitions

### Networks

- Network bridges (`proxmox_virtual_environment_network_linux_bridge`)
- VLAN interfaces (`proxmox_virtual_environment_network_linux_vlan`)
- Currently only GPU01 networks are managed

### Resource Pools

- Resource pools (`proxmox_virtual_environment_pool`)
- Currently manages the `gitops` pool

### Storage Pools

- **Note**: Storage pools are managed via `null_resource` with Proxmox API calls
- The `bpg/proxmox` provider does not support storage management directly
- See [NEW-STORAGE-POOLS.md](./NEW-STORAGE-POOLS.md) for storage configuration
- See [STORAGE-PROVIDERS.md](./STORAGE-PROVIDERS.md) for provider limitations

## Documentation

- **[QUICKSTART.md](./QUICKSTART.md)**: Quick start guide
- **[IMPORT.md](./IMPORT.md)**: Detailed import instructions
- **[HCP-WORKSPACE-SETUP.md](./HCP-WORKSPACE-SETUP.md)**: HCP Terraform Cloud setup
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**: Common issues and solutions
- **[NEW-STORAGE-POOLS.md](./NEW-STORAGE-POOLS.md)**: New storage pools configuration
- **[STORAGE-PROVIDERS.md](./STORAGE-PROVIDERS.md)**: Storage provider limitations
- **[NOTES.md](./NOTES.md)**: Implementation notes

## Important Notes

1. **Storage Management**: Storage pools must be created via Proxmox API (using `null_resource`). The `bpg/proxmox` provider does not support storage resources.

2. **Resource Location**: All resources are in `main.tf` because HCP Terraform Cloud in CLI-driven workflow doesn't load subdirectories.

3. **Lifecycle Blocks**: VM resources use `lifecycle { ignore_changes = [...] }` to prevent Terraform from modifying existing configurations.

4. **State Management**: State is stored in HCP Terraform Cloud. Use `terraform login` to authenticate.

## Discovery Data

The discovery data used to create these configurations is located in:
`../../specs-homelab/proxmox-discovery/`

This includes:

- VM inventory
- Network configuration
- Storage pools
- Resource pools

## Provider

- **Provider**: `bpg/proxmox` (version ~> 0.50)
- **Documentation**: https://registry.terraform.io/providers/bpg/proxmox/latest/docs
