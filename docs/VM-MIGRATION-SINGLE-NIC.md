# VM Migration to Single-NIC Nodes (NUC01/NUC02)

## Problem

When migrating VMs from GPU01 (which has 2 NICs) to NUC01 or NUC02 (which have only 1 NIC), you may encounter network bridge mismatches.

**GPU01 Architecture:**

- `vmbr0` on `enp7s0` (1 GbE, 172.16.15.10/24) - VLAN-aware, general network
- `vmbr1` on `enp11s0` (10 GbE SFP+, 172.16.30.10/24) - VLAN-aware, **dedicated storage network**
  - **Important**: This is a 10GB SFP+ connection for high-bandwidth storage access (VLAN 30)
  - Used for NFS access to NAS01 and NAS02 at 10GB speeds
  - MTU 9000 (Jumbo frames) for optimal performance

**NUC01/NUC02 Architecture:**

- `vmbr0` on single NIC (1 GbE, VLAN-aware)
- NO `vmbr1` - uses VLAN sub-interfaces directly on physical interface
- **Limitation**: Only 1 GbE interface, so storage access is limited to 1GB instead of 10GB

## Performance Implications

⚠️ **Important**: Migrating a VM from GPU01 to NUC01/NUC02 will reduce storage network bandwidth from **10 GbE to 1 GbE** (10x slower).

**Consider staying on GPU01 if the VM:**

- Requires high-bandwidth storage access (NFS reads/writes)
- Performs large file transfers regularly
- Needs optimal storage performance

**Migration to NUC01/NUC02 is acceptable if the VM:**

- Doesn't require high-bandwidth storage access
- Can tolerate 1 GbE storage speeds
- Is a lightweight workload

## Solution Options

### Option 1: Reconfigure VM to Use vmbr0 with VLAN Tagging (Recommended for Migration)

Since NUC01 and NUC02 have VLAN-aware `vmbr0` bridges, reconfigure the VM's network interfaces to use `vmbr0` with VLAN tags instead of `vmbr1`.

**⚠️ Performance Warning**: This will limit storage access to 1 GbE instead of 10 GbE.

**Before migration, update VM network configuration:**

```bash
# On GPU01, before migration:
qm set 103 --net0 virtio,bridge=vmbr0,tag=10
qm set 103 --net1 virtio,bridge=vmbr0,tag=30  # Changed from bridge=vmbr1
```

**Or via Proxmox Web UI:**

1. Go to VM 103 → Hardware → Network Device (net1)
2. Change Bridge from `vmbr1` to `vmbr0`
3. Set VLAN tag to `30`

### Option 2: Create vmbr1 on NUC02 (Not Recommended)

If you must keep `vmbr1` for compatibility, you can create it on NUC02, but you'll need to:

1. **Remove conflicting VLAN interface:**

   ```bash
   # On NUC02, remove enp89s0.30 VLAN interface
   # This should be done via Proxmox Web UI: System → Network
   # Or manually edit /etc/network/interfaces
   ```

2. **Create vmbr1 on NUC02:**
   - Via Proxmox Web UI: System → Network → Create → Linux Bridge
   - Name: `vmbr1`
   - Bridge ports: `enp89s0`
   - IP address: `172.16.30.12/24`
   - VLAN aware: Yes

**Note:** This approach is not ideal because:

- It conflicts with the single-NIC architecture
- You lose the VLAN sub-interface configuration
- It's inconsistent with NUC01's setup
- **It doesn't solve the bandwidth problem** - you still only have 1 GbE, not 10 GbE
- Creating `vmbr1` on a 1 GbE interface doesn't provide the same performance as GPU01's 10 GbE `vmbr1`

## Example: VM 103 (Tdarr VM)

VM 103 is currently configured with:

- `net0`: `bridge=vmbr0,tag=10` ✅ (works on all nodes)
- `net1`: `bridge=vmbr1` ❌ (only exists on GPU01, uses 10 GbE for storage)

**To migrate to NUC02, change net1 to:**

```bash
qm set 103 --net1 virtio,bridge=vmbr0,tag=30
```

This will work on all nodes (GPU01, NUC01, NUC02) since they all have VLAN-aware `vmbr0` bridges.

**⚠️ Performance Impact**: Tdarr performs media transcoding and file operations. Migrating to NUC02 will reduce storage I/O from 10 GbE to 1 GbE, which may impact:

- File transfer speeds when reading/writing media files
- Transcoding performance if source files are on NFS storage
- Overall processing time for large media libraries

**Recommendation**: Keep Tdarr on GPU01 if high storage bandwidth is important for your workflow.

## Verification

After reconfiguring, verify the network configuration:

```bash
qm config 103 | grep net
```

You should see:

```
net0: virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr0,tag=10
net1: virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr0,tag=30
```

## Migration Steps

1. **Reconfigure VM network** (Option 1 recommended):

   ```bash
   qm set 103 --net1 virtio,bridge=vmbr0,tag=30
   ```

2. **Migrate VM:**

   - Via Proxmox Web UI: Right-click VM → Migrate → Select NUC02
   - Or via CLI: `qm migrate 103 NUC02 --online`

3. **Verify VM starts successfully** on NUC02

4. **Test network connectivity** inside the VM
