# Proxmox Data Sources
# Use these to query existing cluster information

data "proxmox_virtual_environment_cluster_nodes" "nodes" {}

data "proxmox_virtual_environment_nodes" "all_nodes" {}

# Get information about each node
data "proxmox_virtual_environment_node" "gpu01" {
  node_name = "GPU01"
}

data "proxmox_virtual_environment_node" "nuc01" {
  node_name = "NUC01"
}

data "proxmox_virtual_environment_node" "nuc02" {
  node_name = "NUC02"
}

