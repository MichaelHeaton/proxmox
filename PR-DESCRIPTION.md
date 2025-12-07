# Terraform Repository Cleanup

## Summary

This PR cleans up the Terraform repository structure, consolidates documentation, and removes outdated files. All resources have been consolidated into `main.tf` as required by HCP Terraform Cloud's CLI-driven workflow.

## Changes

### Files Removed

- `resources/vm.tf` - Outdated VM definitions (moved to main.tf)
- `resources/network.tf` - Outdated network definitions (moved to main.tf)
- `resources/pools.tf` - Outdated pool definitions (moved to main.tf)
- `resources/storage.tf` - Empty file (storage resources in main.tf)
- `FIX-STATE-LOCK.md` - Consolidated into TROUBLESHOOTING.md
- `UNLOCK-HCP.md` - Consolidated into TROUBLESHOOTING.md
- `STATE-LOCK-FIX.md` - Consolidated into TROUBLESHOOTING.md
- `IMPORT-STATUS.md` - Outdated status information

### Files Added/Updated

- `TROUBLESHOOTING.md` - New comprehensive troubleshooting guide covering:
  - State lock issues
  - Storage pool creation issues
  - VM import issues
  - Network configuration issues
  - General troubleshooting
- `README.md` - Updated to reflect current repository structure
- `IMPORT.md` - Updated to remove outdated references
- `IMPORT-FIXES.md` - Updated with current status
- `main.tf` - Added storage pool resources (via null_resource with Proxmox API)

### Key Improvements

1. **Consolidated Resources**: All resources now in `main.tf` (required for HCP Terraform Cloud)
2. **Better Documentation**: Consolidated duplicate docs into single comprehensive guides
3. **Storage Management**: Added storage pool resources using Proxmox API (since provider doesn't support storage)
4. **Cleaner Structure**: Removed empty directories and outdated files

## Testing

- ✅ `terraform validate` passes
- ✅ All resources properly defined
- ✅ Documentation is up to date
- ✅ Storage pools successfully created in Proxmox

## Repository Structure

```
terraform/
├── data/
│   └── cluster.tf
├── scripts/
│   └── import-all-resources.sh
├── *.md (documentation)
├── main.tf (all resources)
├── outputs.tf
└── variables.tf
```

## Related Issues

- Repository cleanup and organization
- Consolidate duplicate documentation
- Add storage pool management
