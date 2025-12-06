# HCP Terraform Cloud Workspace Setup for Proxmox

This guide walks you through setting up a HashiCorp Cloud Platform (HCP) Terraform Cloud workspace for managing your Proxmox infrastructure.

## Prerequisites

- HCP Terraform Cloud account
- Access to the `SpecterRealm` organization (or your organization)
- Proxmox API token with appropriate permissions

## Step 1: Create HCP Workspace

1. **Log in to HCP Terraform Cloud:**

   - Go to: https://app.terraform.io
   - Navigate to your organization (SpecterRealm)

2. **Create New Workspace:**

   - Click **"New Workspace"**
   - Choose **"CLI-Driven Workflow"** (not VCS-driven)
   - This allows you to run Terraform commands from your local machine

3. **Configure Workspace:**
   - **Workspace Name**: `homelab-proxmox`
   - **Description**: "Proxmox cluster infrastructure management"
   - Click **"Create Workspace"**

## Step 2: Configure Execution Mode

**Important**: Since Proxmox is on your internal network, you need to use **Local Execution Mode**.

1. **Access Workspace Settings:**

   - Go to: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/settings/general
   - Or navigate: HCP → Workspaces → `homelab-proxmox` → Settings → General

2. **Change Execution Mode:**
   - Find the **"Execution Mode"** section
   - Change from **"Remote"** to **"Local"**
   - Click **"Save settings"**

### Why Local Execution Mode?

- **Access to Internal Resources**: Can reach `gpu01.specterrealm.com:8006`
- **Faster Execution**: No network latency to HCP
- **Better Debugging**: Full access to local tools and logs
- **State Still Remote**: State is still stored securely in HCP

## Step 3: Configure Workspace Variables (Optional)

You can store sensitive values in HCP workspace variables instead of `terraform.tfvars`:

1. **Navigate to Variables:**

   - Go to: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/variables
   - Or: Workspace → Variables tab

2. **Add Variables:**
   - `proxmox_url` (Terraform variable, not sensitive)
   - `proxmox_api_token_id` (Terraform variable, **mark as sensitive**)
   - `proxmox_api_token_secret` (Terraform variable, **mark as sensitive**)
   - `proxmox_insecure` (Terraform variable, not sensitive)
   - `cluster_name` (Terraform variable, not sensitive)
   - `default_storage_pool` (Terraform variable, not sensitive)
   - `default_network_bridge` (Terraform variable, not sensitive)

**Note**: If you use workspace variables, you don't need `terraform.tfvars` (or can use it for non-sensitive values only).

## Step 4: Authenticate with HCP

From your local machine:

```bash
cd /Users/michaelheaton/Projects/HomeLab/proxmox/terraform
terraform login
```

This will:

- Open your browser
- Authenticate with HCP
- Save credentials locally (`~/.terraform.d/credentials.tfrc.json`)

## Step 5: Configure Local Variables

1. **Copy the example file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your Proxmox credentials:

   ```hcl
   proxmox_url              = "https://gpu01.specterrealm.com:8006/api2/json"
   proxmox_api_token_id    = "terraform@pam!imagefactory"
   proxmox_api_token_secret = "your-token-secret-here"
   proxmox_insecure         = false

   cluster_name            = "pve-cluster01"
   default_storage_pool    = "disk-image-nfs-nas02"
   default_network_bridge  = "vmbr0"
   ```

## Step 6: Initialize Terraform

```bash
terraform init
```

This will:

- Download the Proxmox provider
- Connect to HCP Terraform Cloud
- Set up remote state backend

You should see:

```
Initializing Terraform Cloud...
Initializing provider plugins...
Terraform Cloud has been successfully initialized!
```

## Step 7: Verify Configuration

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate
```

## Step 8: Test Connection

Test the connection by running a plan:

```bash
terraform plan
```

This should:

- Connect to HCP
- Connect to Proxmox API
- Show the current state (empty if nothing imported yet)

## Workspace URL

Your workspace will be available at:

- **Workspace**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox
- **Settings**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/settings/general
- **Variables**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/variables
- **Runs**: https://app.terraform.io/app/SpecterRealm/homelab-proxmox/runs

## Organization Override

If you need to use a different organization, you can:

1. **Edit `main.tf`** and change the organization name, or
2. **Set environment variable:**
   ```bash
   export TF_CLOUD_ORGANIZATION="YourOrgName"
   ```

## Verification Checklist

- [ ] Workspace `homelab-proxmox` created in HCP
- [ ] Execution mode set to **Local**
- [ ] `terraform login` completed successfully
- [ ] `terraform.tfvars` configured with Proxmox credentials
- [ ] `terraform init` completed successfully
- [ ] `terraform validate` passes
- [ ] `terraform plan` connects to Proxmox API

## Next Steps

After workspace setup:

1. **Import existing resources** (see [IMPORT.md](./IMPORT.md))
2. **Review and refine** resource configurations
3. **Set up CI/CD** pipelines if needed
4. **Document** any manual configuration steps

## Troubleshooting

### Authentication Issues

If `terraform login` fails:

- Check your HCP account access
- Verify organization name is correct
- Try logging out and back in: `terraform logout` then `terraform login`

### Connection Issues

If `terraform plan` can't connect to Proxmox:

- Verify Proxmox URL is accessible from your machine
- Check API token has proper permissions
- Test API connectivity: `curl -k -H "Authorization: PVEAPIToken=..." $PROXMOX_URL/version`
- Ensure execution mode is set to **Local**

### State Issues

If you see state-related errors:

- Verify workspace name matches exactly: `homelab-proxmox`
- Check organization name is correct: `SpecterRealm`
- Ensure you have workspace permissions

## References

- [HCP Terraform Cloud Docs](https://developer.hashicorp.com/terraform/cloud-docs)
- [CLI-Driven Workflow](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/creating#cli-driven-workflow)
- [Local Execution Mode](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode)
- [Workspace Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables)
