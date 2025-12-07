# NFS Mount Status

## Current Status

### ✅ Successfully Mounted

- **Backups Share** (NAS01 - Synology)
  - **Path**: `/mnt/nas/backups`
  - **Source**: `172.16.30.5:/volume3/backup`
  - **Status**: ✅ Mounted and accessible

### ⚠️ Pending

- **Streaming Share** (NAS02 - UNAS)
  - **Path**: `/mnt/nas/streaming`
  - **Expected Source**: `172.16.30.4:/var/nfs/shared/media_streaming`
  - **Status**: ❌ Mount failed - "No such file or directory"

## Issue with Streaming Share

The `media_streaming` share exists on UNAS (visible in exports), but mounting fails with:

```
mount.nfs4: mounting 172.16.30.4:/var/nfs/shared/media_streaming failed, reason given by server: No such file or directory
```

**Possible Causes**:

1. UNAS may not have NFS export enabled for `media_streaming` share
2. The `/var/nfs/shared/media_streaming` symlink may not exist on UNAS
3. The share may need to be configured differently in UNAS NFS settings

**Next Steps**:

1. Check UNAS NFS export configuration for `media_streaming`
2. Ensure the share is configured to export via `/var/nfs/shared/media_streaming`
3. Verify NFS export permissions allow GPU01 (172.16.30.10) access
4. Once configured, re-run the mount playbook

## Verification

Check current mounts:

```bash
ssh root@172.16.15.10 "mount | grep '/mnt/nas'"
```

Expected output should show:

- `/mnt/nas/backups` mounted from NAS01 ✅
- `/mnt/nas/streaming` mounted from NAS02 (once UNAS is configured)
