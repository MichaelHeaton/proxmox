# How to Change VM ID in Proxmox

## Important Note

**You cannot directly change a VM ID in Proxmox.** VM IDs are permanent identifiers. However, you have two options:

## Option 1: Clone VM to New ID (Recommended)

This creates a new VM with a different ID, keeping the original:

### Steps:

1. **Clone the VM in Proxmox:**
   - Go to Proxmox web UI
   - Select VM 100 (ubuntu-24.04-hardened)
   - Click "Clone"
   - Choose a new VM ID (e.g., 200)
   - Clone it

2. **Update Terraform to use the new ID:**
   ```hcl
   resource "proxmox_virtual_environment_vm" "ubuntu_24_04_hardened_template" {
     name      = "ubuntu-24.04-hardened"
     node_name = "GPU01"
     vm_id     = 200  # New ID
     template  = true
   }
   ```

3. **Import the new VM:**
   ```bash
   terraform import proxmox_virtual_environment_vm.ubuntu_24_04_hardened_template GPU01/200
   ```

4. **Remove the old VM from Terraform:**
   ```bash
   terraform state rm proxmox_virtual_environment_vm.ubuntu_24_04_hardened_template
   # Then delete VM 100 in Proxmox if desired
   ```

## Option 2: Remove from Terraform and Create New VM

If you want to free up VM ID 100:

1. **Remove from Terraform state:**
   ```bash
   terraform state rm proxmox_virtual_environment_vm.ubuntu_24_04_hardened_template
   ```

2. **Delete VM 100 in Proxmox** (if you want to free the ID)

3. **Create a new VM with desired ID** (manually or via Terraform)

4. **Import the new VM** into Terraform

## Current VM 100 Details

- **Name**: ubuntu-24.04-hardened
- **Type**: Template
- **Node**: GPU01
- **VM ID**: 100

## What ID Do You Want?

Please specify:
- What new VM ID do you want? (e.g., 200, 150, etc.)
- Do you want to keep VM 100 or delete it?
- Should I update the Terraform configuration now?

