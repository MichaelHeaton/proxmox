# New Storage Pools Configuration

**Date**: 2025-12-04
**Status**: ✅ Terraform resources created

## Overview

This document describes the new NFS storage pools added to Proxmox from the recently created shares on NAS01 and NAS02.

## New Storage Pools

### NAS01 (Synology) - High IOPS Storage

| Storage ID   | Type | Server      | Export Path           | Content Type | Shared | Purpose                  |
| ------------ | ---- | ----------- | --------------------- | ------------ | ------ | ------------------------ |
| `lxcs-iops`  | NFS  | 172.16.30.5 | `/volume1/lxcs-iops`  | Container    | Yes    | High IOPS LXC containers |
| `vmdks-iops` | NFS  | 172.16.30.5 | `/volume1/vmdks-iops` | Disk image   | Yes    | High IOPS VM disk images |

### NAS02 (UniFi UNAS Pro) - Medium IOPS Storage

| Storage ID          | Type | Server      | Export Path                         | Content Type       | Shared | Purpose                    |
| ------------------- | ---- | ----------- | ----------------------------------- | ------------------ | ------ | -------------------------- |
| `lxcs`              | NFS  | 172.16.30.4 | `/var/nfs/shared/lxcs`              | Container          | Yes    | Medium IOPS LXC containers |
| `vmdks`             | NFS  | 172.16.30.4 | `/var/nfs/shared/vmdks`             | Disk image         | Yes    | Medium IOPS VM disk images |
| `isos`              | NFS  | 172.16.30.4 | `/var/nfs/shared/isos`              | ISO image          | Yes    | Installation ISOs          |
| `templates-proxmox` | NFS  | 172.16.30.4 | `/var/nfs/shared/templates_proxmox` | Container template | Yes    | LXC container templates    |
| `snippets-proxmox`  | NFS  | 172.16.30.4 | `/var/nfs/shared/snippets_proxmox`  | Snippets           | Yes    | Cloud-init snippets        |
| `import-proxmox`    | NFS  | 172.16.30.4 | `/var/nfs/shared/import_proxmox`    | Import             | Yes    | Import staging area        |

## Migration Notes

### Replacing Old Storage Pools

The following new storage pools replace old ones (migration planned for later):

- `isos` replaces `iso-nfs` (old share: `ISO`)
- `templates-proxmox` replaces `templates-nfs` (old share: `pve_Templates`)
- `snippets-proxmox` replaces `snippets-nfs` (old share: `pve_Snippets`)
- `vmdks` replaces `disk-image-nfs-nas02` (old share: `pve_Disk_Image`)

**Note**: Old storage pools remain configured for backward compatibility during migration.

## Terraform Resources

All new storage pools are managed via Terraform using `null_resource` with `local-exec` to call the Proxmox API directly, since the `bpg/proxmox` provider does not support storage management.

Resources are defined in: `resources/storage.tf`

## Deployment

To deploy the new storage pools:

```bash
cd /Users/michaelheaton/Projects/HomeLab/proxmox/terraform
terraform init
terraform plan
terraform apply
```

## Verification

After deployment, verify storage pools are available:

1. **Proxmox Web UI**: Datacenter → Storage → Verify all new pools are listed
2. **Terraform State**: `terraform state list | grep null_resource.storage_`
3. **Proxmox API**: Check storage list via API or CLI

## References

- Share definitions: `../../specs-homelab/storage/nas-share-layout.md`
- Proxmox storage docs: `../../specs-homelab/storage/proxmox-storage.md`
- NAS01 shares: `../../synology/SHARES_CREATION_SUMMARY.md`
- NAS02 shares: `../../specs-homelab/storage/NAS02_SHARES_REVIEW.md`
