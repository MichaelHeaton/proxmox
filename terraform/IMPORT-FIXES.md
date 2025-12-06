# Import Process Notes and Fixes

This document contains notes about issues encountered during the import process and how they were resolved.

## Issues Found During Import

After importing resources, `terraform plan` showed many mismatches because:

1. **Minimal Resource Definitions**: We imported with minimal config (just name, node_name, vm_id)
2. **Actual VM Configuration**: The VMs have full configuration (CPU, memory, disks, networks, etc.)
3. **Node Name Mismatches**: Some VMs were on different nodes than expected
4. **Name Mismatches**: Some VMs had different names in Proxmox

## Fixes Applied

### 1. Fixed Node Names

- **VM 100**: Actually on `GPU01`, not `NUC01` (renamed to `ubuntu_24_04_hardened_template`)
- **VM 101**: Actually on `GPU01`, not `NUC01` (renamed to `test4`)

### 2. Fixed VM Names

- **VM 100**: Actual name is `ubuntu-24.04-hardened` (it's a template)
- **VM 101**: Actual name is `Test4`

### 3. Added Lifecycle Ignore Changes

Added `lifecycle { ignore_changes = [...] }` blocks to prevent Terraform from modifying:

- CPU configuration
- Memory configuration
- Disk configuration
- Network device configuration
- Operating system settings
- Agent settings
- Machine type
- Description, tags
- Boot settings
- SCSI hardware
- Keyboard layout

This preserves the existing VM configuration while allowing Terraform to track the resources.

## Current Status

After fixes:

- ✅ VM node names corrected
- ✅ VM names match actual Proxmox names
- ✅ Lifecycle blocks prevent unwanted changes
- ✅ All existing VMs have been imported

## VMs Not Imported

These VMs were listed in discovery data but don't exist in Proxmox (or were deleted):

- `plex` (VM 102) - GPU01
- `dns` (VM 104) - NUC01
- `k8s_01` (VM 105) - GPU01
- `k8s_02` (VM 106) - NUC01
- `k8s_03` (VM 107) - NUC02
- `postgresql` (VM 108) - NUC01

Resource definitions for these VMs have been removed from `main.tf`.

## Best Practices

For existing VMs that are already configured:

1. Import with minimal definitions (name, node_name, vm_id)
2. Use `lifecycle { ignore_changes }` to preserve existing configuration
3. Only manage attributes you want to control via Terraform
4. Use `terraform state mv` to rename resources if names don't match

This prevents Terraform from making unwanted changes to working VMs.
