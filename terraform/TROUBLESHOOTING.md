# Troubleshooting Guide

This document covers common issues and their solutions when working with the Proxmox Terraform configuration.

## State Lock Issues

### The Problem

HCP Terraform Cloud uses a different lock format than local state, so `terraform force-unlock` doesn't work directly. The lock ID keeps changing because HCP is creating new locks.

### Solution: Cancel Stuck Runs in HCP

#### Step 1: Go to Your Workspace Runs

Open this URL in your browser:
**https://app.terraform.io/app/SpecterRealm/homelab-proxmox/runs**

#### Step 2: Find Stuck Runs

Look for:

- **Running** operations (may be stuck)
- Operations that have been running for a long time
- Failed operations that didn't clean up

#### Step 3: Cancel/Discard Stuck Runs

1. Click on any stuck/running run
2. Click **"Cancel"** or **"Discard"** button
3. Confirm the cancellation

#### Step 4: Verify Lock is Cleared

After canceling stuck runs, try:

```bash
terraform plan
```

If it still shows a lock, wait 1-2 minutes for HCP to clear it, then try again.

### Alternative: Use -lock=false for Read-Only Operations

If you just need to check your configuration, use `-lock=false` for read-only operations:

```bash
# Safe for read-only operations
terraform plan -lock=false
terraform show -lock=false
terraform state list -lock=false
```

**Important**: Never use `-lock=false` with `apply` or `destroy` - it can corrupt state!

### Why This Happens

HCP Terraform Cloud creates locks when:

- A plan/apply operation starts
- Operations are running remotely
- A previous operation didn't complete cleanly

The lock persists until the operation completes or is cancelled.

### Prevention

1. **Let operations complete** - Don't interrupt HCP runs
2. **Check HCP before force operations** - Make sure no runs are active
3. **Use Local execution mode** - Your workspace is set to Local, but HCP may still create locks for state access
4. **Cancel stuck runs promptly** - Don't let them sit for hours

### Quick Reference

- **HCP Runs**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/runs
- **Workspace Settings**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/settings/general
- **Safe read-only**: `terraform plan -lock=false`

## Storage Pool Creation Issues

### Problem: Storage pools not appearing in Proxmox UI

If Terraform reports success but storage pools don't appear:

1. **Check for API errors**: The `null_resource` provisioners may fail silently. Check the Terraform output for any error messages.

2. **Verify NFS shares exist**: Ensure the NFS shares are created and exported on NAS01 and NAS02 before running Terraform.

3. **Check export paths**: Verify the export paths match your NAS configuration:

   - NAS01: `/volume1/{share-name}`
   - NAS02: `/var/nfs/shared/{share-name}`

4. **Manual creation**: If Terraform fails, you can create storage pools manually via the Proxmox API or web UI.

See [NEW-STORAGE-POOLS.md](./NEW-STORAGE-POOLS.md) for storage pool configuration details.

## VM Import Issues

### Problem: VM not found during import

If you get `Error: Cannot import non-existent remote object`:

1. **Verify VM exists**: Check the Proxmox web UI to confirm the VM exists
2. **Check VM ID**: Ensure the VM ID in `import-ids.txt` matches the actual VM ID in Proxmox
3. **Check node name**: Verify the node name matches (case-sensitive)
4. **Update import-ids.txt**: Remove VMs that no longer exist

### Problem: VM name mismatch

If the VM name in Terraform doesn't match Proxmox:

1. Use `terraform state mv` to rename the resource:
   ```bash
   terraform state mv proxmox_virtual_environment_vm.old_name proxmox_virtual_environment_vm.new_name
   ```
2. Update the resource definition in `main.tf` to match the actual VM name

See [IMPORT.md](./IMPORT.md) for detailed import instructions.

## Network Configuration Issues

### Problem: Network resource import fails

The `bpg/proxmox` provider may not support all network attributes. If import fails:

1. Check which attributes are supported in the provider documentation
2. Remove unsupported attributes from the resource definition
3. Use `lifecycle { ignore_changes = [...] }` to prevent Terraform from managing certain attributes

## General Issues

### Problem: Terraform not detecting changes

If Terraform says "No changes" but you expect changes:

1. **Refresh state**: Run `terraform refresh` to update state from Proxmox
2. **Check lifecycle blocks**: `ignore_changes` blocks may be preventing updates
3. **Verify resource exists**: Ensure the resource actually exists in Proxmox

### Problem: Provider authentication errors

If you get authentication errors:

1. **Check API token**: Verify your token in `terraform.tfvars` is correct
2. **Check token permissions**: Ensure the token has necessary permissions
3. **Check Proxmox URL**: Verify the URL is correct and accessible

## Getting Help

- **Provider Documentation**: https://registry.terraform.io/providers/bpg/proxmox/latest/docs
- **HCP Terraform Cloud**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox
- **Discovery Data**: `../../specs-homelab/proxmox-discovery/`
