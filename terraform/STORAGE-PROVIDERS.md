# Proxmox Storage Management with Terraform

## Current Situation

The **bpg/proxmox** provider (v0.88.0) that we're currently using does **NOT** have a `proxmox_virtual_environment_storage` resource type for managing storage pools/datastores.

## Provider Comparison

### bpg/proxmox Provider

- **Status**: Currently in use
- **Storage Support**: ❌ No direct storage pool management
- **What it supports**: VMs, containers, networks, pools, users, ACLs, etc.
- **Storage workaround**: Storage must be managed manually via Proxmox UI/API

### Telmate/proxmox Provider

- **Status**: Alternative provider
- **Storage Support**: ❌ Limited - primarily focuses on VM/container provisioning
- **What it supports**: QEMU VMs, LXC containers
- **Storage**: Can configure storage within VM definitions, but doesn't manage storage pools

### awlsring/terraform-provider-proxmox

- **Status**: Early development
- **Storage Support**: ⚠️ Claims to support LVM, LVM Thinpool, ZFS pool, and storage classes
- **Maturity**: Early development - may not be production-ready

## Why Storage Management is Limited

Proxmox storage pools are typically:

1. **Pre-configured** during Proxmox installation
2. **Managed via Proxmox UI** or direct API calls
3. **Complex** - involve underlying storage systems (NFS, LVM, ZFS, Ceph, etc.)
4. **Node-specific** - some storage is per-node, some is shared

## Options for Managing Storage

### Option 1: Manual Management (Current Approach)

- Manage storage pools via Proxmox web UI
- Document storage configuration in `specs-homelab/proxmox-discovery/`
- Use Terraform for VMs, networks, and other resources only

**Pros**: Simple, reliable, no provider limitations
**Cons**: Not infrastructure-as-code for storage

### Option 2: Use Proxmox API Directly

- Use `null_resource` with `local-exec` to call Proxmox API
- Create custom scripts for storage management
- Integrate with Terraform lifecycle

**Example**:

```hcl
resource "null_resource" "create_nfs_storage" {
  provisioner "local-exec" {
    command = <<-EOT
      curl -k -H "Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" \
        -X POST "${var.proxmox_url}/storage" \
        -d "storage=backups-nfs" \
        -d "type=nfs" \
        -d "server=172.16.30.4" \
        -d "export=/var/nfs/shared/pve_Backups" \
        -d "content=backup"
    EOT
  }
}
```

**Pros**: Full control, can manage any storage type
**Cons**: More complex, requires API knowledge, harder to maintain

### Option 3: Wait for Provider Support

- Monitor bpg/proxmox provider updates
- Storage management may be added in future versions
- Check provider GitHub issues/roadmap

### Option 4: Use Different Provider (Not Recommended)

- Switch to awlsring/terraform-provider-proxmox (early development)
- Risk: Less mature, may have bugs, limited documentation

## Recommendation

**Stick with Option 1 (Manual Management)** for now because:

1. ✅ Storage pools are typically **set up once** and rarely change
2. ✅ Your storage is already configured and working
3. ✅ Terraform can still manage the important resources (VMs, networks, pools)
4. ✅ Manual storage management is more reliable than workarounds
5. ✅ Documentation in `specs-homelab/proxmox-discovery/` provides the source of truth

## Storage Documentation

Your storage configuration is well-documented in:

- `../../specs-homelab/proxmox-discovery/09-storage-list.json`
- `../../specs-homelab/storage/proxmox-storage.md`

This provides a clear record of your storage setup without needing Terraform to manage it.

## Future Considerations

If you need to automate storage management in the future:

1. **Monitor bpg/proxmox provider**: Check for storage resource additions
2. **Use Proxmox API**: Create custom scripts/modules for storage operations
3. **Consider Ansible**: Ansible has better Proxmox storage support and can complement Terraform

## References

- [bpg/proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Telmate/proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Proxmox API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/index.html)
