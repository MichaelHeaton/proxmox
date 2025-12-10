#!/bin/bash
# Script to create Tdarr VM from template
# Usage: ./create-tdarr-vm.sh [VM_ID] [TEMPLATE_ID]
# Example: ./create-tdarr-vm.sh 103 900

set -e

PROXMOX_HOST="gpu01.specterrealm.com"
VM_ID="${1:-103}"  # Use first argument or default to 103
TEMPLATE_ID="${2:-900}"  # Use second argument or default to 900
VM_NAME="tdarr-vm-01"

echo "Creating Tdarr VM from template..."
echo "  Template ID: ${TEMPLATE_ID}"
echo "  VM ID: ${VM_ID}"
echo "  VM Name: ${VM_NAME}"
echo ""

# Check if VM ID is already in use
if ssh root@${PROXMOX_HOST} "qm list | grep -qE '^[[:space:]]*${VM_ID}[[:space:]]'"; then
    echo "❌ Error: VM ID ${VM_ID} already exists!"
    echo "Please choose a different VM ID."
    exit 1
fi

# Check if template exists (template or stopped VM)
if ! ssh root@${PROXMOX_HOST} "qm list | grep -qE '^[[:space:]]*${TEMPLATE_ID}[[:space:]]'"; then
    echo "❌ Error: Template/VM ${TEMPLATE_ID} not found!"
    exit 1
fi

echo "✅ Template found, VM ID available"
echo ""

# Create VM from template
echo "Cloning template ${TEMPLATE_ID} to VM ${VM_ID}..."
ssh root@${PROXMOX_HOST} << EOF
    # Clone template
    qm clone ${TEMPLATE_ID} ${VM_ID} --name ${VM_NAME} --full

    # Configure resources
    echo "Configuring VM resources..."
    qm set ${VM_ID} --cores 4
    qm set ${VM_ID} --memory 8192
    qm resize ${VM_ID} scsi0 40G

    # Configure network (VLAN 10 for production)
    echo "Configuring network (VLAN 10)..."
    qm set ${VM_ID} --net0 virtio,bridge=vmbr0,tag=10

    # Configure network (VLAN 30 for direct storage access)
    echo "Configuring network (VLAN 30)..."
    qm set ${VM_ID} --net1 virtio,bridge=vmbr1

    # Note: No GPU passthrough - CPU transcoding only
    # This allows the VM to run on any Proxmox node (GPU01, NUC01, or NUC02)
    # Single GPU is dedicated to Plex VM to avoid coordination complexity

    echo "✅ VM ${VM_ID} (${VM_NAME}) created and configured successfully"
    echo ""
    echo "Next steps:"
    echo "  1. Start the Tdarr VM: qm start ${VM_ID}"
    echo "  2. Check VM IP in Proxmox Summary tab (will get DHCP IP initially)"
    echo "  3. Configure static IPs via Ansible:"
    echo "     - VLAN 10: 172.16.10.21"
    echo "     - VLAN 30: 172.16.30.21 (if needed)"
    echo "  4. Run Ansible playbook to configure VM (when playbook is ready)"
    echo ""
    echo "Note: CPU transcoding only - no GPU passthrough required"
    echo "Note: VM can run on any Proxmox node (GPU01, NUC01, or NUC02)"
EOF

echo ""
echo "✅ Tdarr VM created! You can now start it and configure it."
echo ""
echo "Note: CPU transcoding only - no GPU passthrough required"
echo "Note: VM can run on any Proxmox node (GPU01, NUC01, or NUC02)"
echo "Note: Single GPU is dedicated to Plex VM to avoid coordination complexity"

