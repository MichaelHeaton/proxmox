#!/bin/bash

# Import All Proxmox Resources from import-ids.txt
# This script reads import-ids.txt and imports all resources with IDs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMPORT_FILE="$TERRAFORM_DIR/import-ids.txt"

cd "$TERRAFORM_DIR"

if [ ! -f "$IMPORT_FILE" ]; then
    echo "❌ Import IDs file not found: $IMPORT_FILE"
    exit 1
fi

echo "📥 Importing Proxmox Resources from import-ids.txt"
echo "=================================================="
echo ""

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "⚠️  Terraform not initialized. Running terraform init..."
    terraform init
    echo ""
fi

# Extract import commands from the file
# Format: proxmox_resource_type.resource_name = "id"

IMPORTED=0
SKIPPED=0
FAILED=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Parse: proxmox_resource_type.resource_name = "id"
    # Format: proxmox_virtual_environment_storage.backups_nfs = "backups-nfs"
    # Use a simpler approach: split on = and extract quoted value
    if [[ "$line" =~ = ]]; then
        # Extract resource name (everything before =, trimmed)
        full_resource=$(echo "$line" | sed 's/[[:space:]]*=[[:space:]]*.*$//' | xargs)
        # Extract quoted ID (everything between quotes)
        resource_id=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')

        # Skip if no resource name or ID found
        if [[ -z "$full_resource" ]] || [[ -z "$resource_id" ]]; then
            continue
        fi

        # Skip placeholder IDs
        if [[ "$resource_id" == "<id-from-proxmox>" ]]; then
            echo "⏭️  Skipping $full_resource (no ID provided)"
            ((SKIPPED++))
            continue
        fi

        echo "📥 Importing $full_resource..."
        echo "   ID: $resource_id"

        if terraform import "$full_resource" "$resource_id" 2>&1; then
            echo "   ✅ Success"
            ((IMPORTED++))
            # Small delay to avoid rate limiting
            sleep 1
        else
            echo "   ❌ Failed"
            ((FAILED++))
        fi
        echo ""
    fi
done < "$IMPORT_FILE"

echo "=================================================="
echo "Import Summary:"
echo "  ✅ Imported: $IMPORTED"
echo "  ⏭️  Skipped: $SKIPPED"
echo "  ❌ Failed: $FAILED"
echo ""

if [ $IMPORTED -gt 0 ]; then
    echo "💡 Next steps:"
    echo "   1. Review the imported resources: terraform plan"
    echo "   2. Verify the configuration matches your setup"
    echo "   3. Update resource definitions if needed"
    echo "   4. Run terraform plan again to ensure no drift"
fi

if [ $FAILED -gt 0 ]; then
    echo "⚠️  Some imports failed. Check the errors above."
    echo "   You may need to:"
    echo "   - Verify the resource IDs are correct"
    echo "   - Check your Proxmox API credentials"
    echo "   - Ensure the resources exist in Proxmox"
    exit 1
fi

