# Proxmox Terraform Import Guide

This guide explains how to import your existing Proxmox infrastructure into Terraform.

## Prerequisites

1. **Terraform installed** (>= 1.0)
2. **Proxmox API access** configured
3. **Discovery data** collected in `../../specs-homelab/proxmox-discovery/`
4. **terraform.tfvars** file created from `terraform.tfvars.example`

## Setup

1. **Copy the example tfvars file:**

   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your Proxmox credentials:

   ```hcl
   proxmox_url              = "https://gpu01.specterrealm.com:8006/api2/json"
   proxmox_api_token_id    = "terraform@pam!imagefactory"
   proxmox_api_token_secret = "your-token-secret-here"
   proxmox_insecure         = false
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

## Import Process

### Option 1: Automated Import (Recommended)

Use the provided import script to import all resources at once:

```bash
./scripts/import-all-resources.sh
```

This script will:

- Read all import commands from `import-ids.txt`
- Import each resource sequentially
- Provide a summary of successes and failures
- Add a small delay between imports to avoid rate limiting

### Option 2: Manual Import

Import resources individually using the commands in `import-ids.txt`:

```bash
# Note: Storage resources cannot be imported - they're not supported by the provider
# Storage pools are managed via null_resource with Proxmox API calls

# Networks
terraform import proxmox_virtual_environment_network_linux_bridge.gpu01_vmbr0 GPU01/vmbr0
# ... etc

# VMs
terraform import proxmox_virtual_environment_vm.minecraft01 GPU01/103
# ... etc
```

## Import Order

It's recommended to import resources in this order:

1. **Storage** - Foundation for VMs
2. **Networks** - Required for VM networking
3. **Resource Pools** - Organizational structure
4. **Virtual Machines** - Depends on storage and networks

## Verification

After importing, verify the state:

```bash
# Check what Terraform sees
terraform state list

# Plan to see if there are any differences
terraform plan

# If there are differences, update the resource definitions to match
```

## Common Issues

### Import Format Errors

The bpg/proxmox provider uses specific import formats:

- **Storage**: `storage-name` (e.g., `backups-nfs`)
- **Networks**: `node-name/interface-name` (e.g., `GPU01/vmbr0`)
- **VMs**: `node-name/vm-id` (e.g., `GPU01/103`)
- **Pools**: `pool-id` (e.g., `gitops`)

### Resource Configuration Mismatches

After importing, `terraform plan` may show differences. This is normal because:

1. The import only adds resources to state
2. The resource definitions may not match exactly
3. Some attributes may be read-only or computed

**Solution**: Update the resource definitions in the `.tf` files to match the actual configuration, or use `terraform show` to see the current state.

### VM Import Limitations

The bpg/proxmox provider has some limitations with VM imports:

- Complex VM configurations may not import perfectly
- Disk configurations may need manual adjustment
- Network configurations may need refinement

**Solution**: After importing, review each VM's configuration and update the Terraform definitions to match.

## Post-Import Steps

1. **Review the plan:**

   ```bash
   terraform plan
   ```

2. **Fix any configuration mismatches:**

   - Compare `terraform show` output with your resource definitions
   - Update `.tf` files to match actual configuration
   - Use `ignore_changes` lifecycle blocks for attributes that shouldn't be managed

3. **Test the configuration:**

   ```bash
   terraform plan  # Should show no changes
   ```

4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Import existing Proxmox infrastructure into Terraform"
   ```

## Resource Details

### Storage Resources

**Note**: Storage resources are NOT managed via Terraform resources. The `bpg/proxmox` provider does not support storage management. Storage pools are created using `null_resource` with Proxmox API calls (see `main.tf`).

- **NFS Storage**: Shared NFS mounts from NAS01 and NAS02
- **LVM Storage**: Shared LVM volume groups
- **Local Storage**: Per-node directory storage
- See [NEW-STORAGE-POOLS.md](./NEW-STORAGE-POOLS.md) for storage configuration

### Network Resources

Network resources are defined in `main.tf`:

- **Bridges**: VLAN-aware bridges on GPU01
- **VLANs**: VLAN interfaces for specific networks
- Currently only GPU01 networks are managed

### Virtual Machines

VM resources are defined in `main.tf`:

- **GPU01**: 3 VMs (Minecraft01, ubuntu-24.04-hardened template, Test4)
- All VMs use `lifecycle { ignore_changes }` to preserve existing configuration

### Resource Pools

Pool resources are defined in `main.tf`:

- **gitops**: GitOps managed resources pool

## Next Steps

After successful import:

1. Review and refine resource configurations
2. Add any missing resources
3. Set up Terraform Cloud/Enterprise for state management (optional)
4. Create CI/CD pipelines for infrastructure changes
5. Document any manual configuration steps

## References

- [bpg/proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- Discovery data: `../../specs-homelab/proxmox-discovery/`
- Cluster overview: `../../specs-homelab/proxmox-discovery/CLUSTER-OVERVIEW.md`
