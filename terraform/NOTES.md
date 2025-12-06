# Proxmox Terraform Implementation Notes

## Resource Syntax

The resource definitions in this repository are based on the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider (version ~> 0.50).

**Important**: The exact resource syntax may need adjustment based on:

- The specific version of the provider you're using
- Provider documentation updates
- Your Proxmox version

### Verification Steps

After setting up your configuration:

1. **Initialize Terraform:**

   ```bash
   terraform init
   ```

2. **Validate syntax:**

   ```bash
   terraform validate
   ```

3. **Format code:**

   ```bash
   terraform fmt
   ```

4. **Check provider documentation:**
   - [bpg/proxmox Provider Docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
   - Verify resource names and attributes match the provider

### Common Adjustments Needed

#### Storage Resources

The storage resource syntax may vary. Check the provider docs for:

- Correct block names (`nfs`, `lvm`, `directory`)
- Required vs optional attributes
- Content types format

#### Network Resources

Network resources are complex and may need:

- Different resource types for bridges vs VLANs
- Additional configuration blocks
- Node-specific settings

#### VM Resources

VM resources are the most complex and may require:

- Detailed disk configuration
- Network device settings
- BIOS/UEFI settings
- Cloud-init configuration

## Import Format

The import format for the bpg/proxmox provider:

- **Storage**: `storage-name` (e.g., `backups-nfs`)
- **Networks**: `node-name/interface-name` (e.g., `GPU01/vmbr0`)
- **VMs**: `node-name/vm-id` (e.g., `GPU01/103`)
- **Pools**: `pool-id` (e.g., `gitops`)

If imports fail, check:

1. The resource exists in Proxmox
2. Your API token has proper permissions
3. The import format matches the provider version

## Provider Version

Current provider version: `~> 0.50`

To check for updates:

```bash
terraform providers
```

To update:

```bash
terraform init -upgrade
```

## State Management

Consider using remote state for:

- Team collaboration
- State locking
- State history

Options:

- Terraform Cloud
- S3 + DynamoDB
- Other backends

See `main.tf` for commented S3 backend example.

## Resource Lifecycle

Some resources may need lifecycle blocks:

```hcl
lifecycle {
  ignore_changes = [
    # Attributes that shouldn't be managed by Terraform
    # e.g., computed values, auto-generated IDs
  ]
}
```

## Troubleshooting

### Provider Errors

If you see provider-related errors:

1. Check provider version compatibility
2. Verify API token permissions
3. Test API connectivity manually
4. Review provider logs

### Import Issues

If imports fail:

1. Verify resource IDs are correct
2. Check resource exists in Proxmox
3. Ensure API token has read permissions
4. Try importing manually to see detailed errors

### Configuration Drift

If `terraform plan` shows unexpected changes:

1. Use `terraform show` to see current state
2. Compare with actual Proxmox configuration
3. Update resource definitions to match
4. Use `ignore_changes` for computed values

## Next Steps

1. Run `terraform init` and `terraform validate`
2. Fix any syntax errors
3. Test imports with a single resource first
4. Gradually import all resources
5. Refine configurations based on `terraform plan` output

## References

- [bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Terraform Import](https://www.terraform.io/docs/cli/import/index.html)
- Discovery data: `../../specs-homelab/proxmox-discovery/`
