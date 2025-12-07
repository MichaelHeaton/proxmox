# Next Steps for Plex VM Deployment

## Current Status

✅ **Completed**:

- VM created (plex-vm-01, VM ID 102)
- VM configured with resources (CPU, RAM, disk, network, GPU)
- Ansible playbooks and roles created
- DNS record added to Terraform (needs `terraform apply`)
- Documentation created

⚠️ **Pending**:

- NFS shares mounting (need to confirm exact share names)
- SSH access verification (image factory key may need verification)
- DNS record deployment (run `terraform apply` in unifi/terraform)

## Issues to Resolve

### 1. NFS Share Names

The playbook is trying to mount:

- `/var/nfs/shared/streaming`
- `/var/nfs/shared/backups`

But the actual exports show:

- `media_streaming` exists (but at full volume path)

**Questions**:

- What are the exact share names on NAS02? Are they `streaming` and `backups`, or `media_streaming` and something else?
- Are the shares exported at `/var/nfs/shared/` paths, or do we need to use the full volume paths?
- If using full volume paths, what are they? (e.g., `/volume/.../.srv/.unifi-drive/streaming/.data`)

**Action**: Once we know the exact share names/paths, update the playbook and re-run.

### 2. SSH Access

SSH is currently failing with "Permission denied (publickey)".

**Questions**:

- Which SSH key should be used? (The one from image factory?)
- Is the key already in the VM, or does it need to be added?
- What's the path to the image factory SSH key?

**Action**: Verify SSH key setup and test access.

### 3. DNS Record

DNS record has been added to Terraform but needs to be applied.

**Action**:

```bash
cd /Users/michaelheaton/Projects/HomeLab/unifi/terraform
terraform plan  # Review changes
terraform apply  # Apply DNS record
```

## Immediate Next Steps

1. **Confirm NFS Share Names**:

   - Check NAS02 for exact share names
   - Update playbook with correct paths
   - Re-run mount playbook

2. **Verify SSH Access**:

   - Check if image factory key works
   - Or add your SSH key to the VM
   - Test SSH connection

3. **Apply DNS Record**:

   - Run `terraform apply` in unifi/terraform
   - Verify DNS resolution: `nslookup plex-vm-01.specterrealm.com`

4. **Run Ansible Playbook**:
   - Once SSH works, run: `cd plex/ansible && ansible-playbook playbooks/deploy-plex-vm.yml`

## Testing Commands

### Test NFS Mounts (once share names confirmed)

```bash
ssh root@172.16.15.10
mount -t nfs4 172.16.30.4:/var/nfs/shared/streaming /mnt/nas/streaming
ls /mnt/nas/streaming
```

### Test SSH Access

```bash
# Try with image factory key (if you know the path)
ssh -i ~/.ssh/image-factory-key packer@172.16.10.100

# Or add your key via Proxmox console
qm terminal 102
# Then in VM console, add your public key to /home/packer/.ssh/authorized_keys
```

### Test DNS

```bash
nslookup plex-vm-01.specterrealm.com
# Should resolve to 172.16.10.20 (after terraform apply)
```
