# Proxmox Host Ansible Configuration

This directory contains Ansible playbooks for managing Proxmox host configuration beyond what Terraform handles.

## Purpose

- **Terraform**: Manages Proxmox resources (VMs, storage pools, etc.)
- **Ansible**: Manages Proxmox host OS configuration (NFS mounts, system settings, etc.)

## Structure

```
ansible/
├── playbooks/
│   └── mount-application-shares.yml  # Mount application data NFS shares
├── inventory/
│   └── proxmox-hosts.yml             # Proxmox host inventory
├── ansible.cfg                        # Ansible configuration
└── README.md                          # This file
```

## Application Data NFS Shares

These shares are mounted on Proxmox hosts for passthrough to VMs:

- **`/streaming`**: Streaming media share (Plex, Sonarr, Radarr, etc.)
- **`/backups`**: General backup storage (application databases, configs)

### Mount Points

- **Proxmox Host**: `/mnt/nas/streaming` and `/mnt/nas/backups`
- **VM Passthrough**: These will be bind-mounted to VMs at `/mnt/streaming` and `/mnt/backups`

## Usage

### Mount Application Shares

```bash
cd /Users/michaelheaton/Projects/HomeLab/proxmox/ansible
ansible-playbook playbooks/mount-application-shares.yml
```

### Verify Mounts

```bash
# On Proxmox host
mount | grep nfs
df -h | grep nas
```

## Notes

- Mounts are configured in `/etc/fstab` for persistence
- Uses optimized NFS mount options for performance
- Shares are mounted on all Proxmox nodes for high availability
