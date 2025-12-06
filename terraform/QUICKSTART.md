# Proxmox Terraform Quick Start

Get started managing your Proxmox infrastructure with Terraform in 5 minutes.

## Prerequisites

- Terraform >= 1.0 installed
- HCP Terraform Cloud account
- Proxmox API token with appropriate permissions
- Access to your Proxmox cluster

## Setup

1. **Set up HCP Workspace** (see [HCP-WORKSPACE-SETUP.md](./HCP-WORKSPACE-SETUP.md) for details):

   - Create workspace `homelab-proxmox` in HCP Terraform Cloud
   - Use **CLI-Driven Workflow**
   - Set execution mode to **Local** (required for internal Proxmox access)
   - Authenticate: `terraform login`

2. **Navigate to the terraform directory:**

   ```bash
   cd terraform
   ```

3. **Create your configuration file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

4. **Edit terraform.tfvars** with your Proxmox credentials:

   ```hcl
   proxmox_url              = "https://your-proxmox-server:8006/api2/json"
   proxmox_api_token_id    = "terraform@pam!token-name"
   proxmox_api_token_secret = "your-secret-here"
   proxmox_insecure         = false  # Set to true if using self-signed certs
   ```

5. **Initialize Terraform:**
   ```bash
   terraform init
   ```

## Import Existing Infrastructure

If you have existing Proxmox resources, import them:

```bash
# Automated import (recommended)
./scripts/import-all-resources.sh

# Or import manually
terraform import proxmox_virtual_environment_storage.backups_nfs backups-nfs
```

See [IMPORT.md](./IMPORT.md) for detailed import instructions.

## Verify Configuration

After importing, verify everything is correct:

```bash
# List all resources in state
terraform state list

# Check for any differences
terraform plan
```

If `terraform plan` shows changes, you may need to update the resource definitions to match your actual configuration.

## Common Commands

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List all resources
terraform state list

# Import a resource
terraform import <resource_type>.<resource_name> <resource_id>

# Remove a resource from state (doesn't delete it)
terraform state rm <resource_type>.<resource_name>
```

## Project Structure

```
terraform/
├── main.tf                 # Provider configuration
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
├── terraform.tfvars       # Your configuration (gitignored)
├── import-ids.txt         # Import commands
├── resources/             # Resource definitions
│   ├── storage.tf         # Storage pools
│   ├── network.tf         # Network bridges/VLANs
│   ├── vm.tf              # Virtual machines
│   └── pools.tf           # Resource pools
├── data/                  # Data sources
│   └── cluster.tf         # Cluster/node data
└── scripts/               # Helper scripts
    └── import-all-resources.sh
```

## Next Steps

1. **Review imported resources**: Check that all resources imported correctly
2. **Refine configurations**: Update resource definitions to match your needs
3. **Add missing resources**: Add any resources not yet in Terraform
4. **Set up remote state**: Consider using Terraform Cloud or S3 for state management
5. **Create CI/CD**: Automate infrastructure changes with pipelines

## Getting Help

- **HCP Setup**: See [HCP-WORKSPACE-SETUP.md](./HCP-WORKSPACE-SETUP.md)
- **Import Guide**: See [IMPORT.md](./IMPORT.md)
- **Implementation Notes**: See [NOTES.md](./NOTES.md)
- **Provider Docs**: [bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- **Discovery Data**: `../../specs-homelab/proxmox-discovery/`

## Troubleshooting

### Import Errors

If imports fail:

1. Verify the resource IDs in `import-ids.txt` are correct
2. Check your API token has proper permissions
3. Ensure resources exist in Proxmox
4. Check the provider documentation for correct import format

### Configuration Mismatches

If `terraform plan` shows unexpected changes:

1. Run `terraform show` to see current state
2. Compare with your resource definitions
3. Update `.tf` files to match actual configuration
4. Use `ignore_changes` lifecycle blocks if needed

### Provider Errors

If you see provider-related errors:

1. Verify your `terraform.tfvars` configuration
2. Test API connectivity: `curl -k -H "Authorization: PVEAPIToken=..." $PROXMOX_URL/version`
3. Check provider version compatibility
4. Review provider logs for detailed errors
