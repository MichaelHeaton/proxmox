# Prerequisites for Application Data NFS Mounts

## Required NAS02 Shares

Before running the `mount-application-shares.yml` playbook, ensure the following shares exist on NAS02:

### 1. `/streaming` Share

- **Share Name**: `streaming` (or `media_streaming` if using existing)
- **NFS Export Path**: `/var/nfs/shared/streaming`
- **Purpose**: Streaming media for Plex and related services
- **Access**: Proxmox hosts (GPU01, NUC01, NUC02) need read-write access
- **Status**: ⚠️ **May need to be created on NAS02**

### 2. `/backups` Share

- **Share Name**: `backups`
- **NFS Export Path**: `/var/nfs/shared/backups`
- **Purpose**: General backup storage for application databases
- **Access**: Proxmox hosts (GPU01, NUC01, NUC02) need read-write access
- **Status**: ⚠️ **May need to be created on NAS02**

## Current Status

Based on NFS exports check:

- ✅ `media_streaming` exists and GPU01 (172.16.30.10) has access
- ❓ `/streaming` share may need to be created (or use `media_streaming` as alias)
- ❓ `/backups` share needs to be created

## Next Steps

1. **Verify/Create Shares on NAS02**:

   - Log into NAS02 management interface
   - Create `/streaming` share if it doesn't exist
   - Create `/backups` share if it doesn't exist
   - Configure NFS exports with read-write access for:
     - 172.16.30.10 (GPU01)
     - 172.16.30.11 (NUC01)
     - 172.16.30.12 (NUC02)

2. **Run Playbook**:
   ```bash
   cd /Users/michaelheaton/Projects/HomeLab/proxmox/ansible
   ansible-playbook playbooks/mount-application-shares.yml
   ```

## Notes

- If shares don't exist, the playbook will fail at the mount step
- The playbook will still add entries to `/etc/fstab` even if mounts fail
- Remove `/etc/fstab` entries if shares need to be created first
