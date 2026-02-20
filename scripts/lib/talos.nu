# Talos-specific utilities
# Helper functions for Talos Linux cluster operations

# Add mise shims to PATH
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/share/mise/shims")

# Apply Talos config patches to base config
export def apply-patches [
  base: string
  patches: list<string>
] -> string {
  # For now, return base config
  # In production, would merge YAML patches
  $base
}

# Generate Talos machine config from template
export def gen-config [
  cluster: string
  endpoint: string
  version: string
] {
  talosctl generate cluster 
    --name $cluster 
    --endpoint $endpoint 
    --version $version
}

# Get Talos node status
export def node-status [node: string, talosconfig?: string] {
  let config = $talosconfig? | default "talosconfig"
  
  if not ($config | path exists) {
    print "Error: talosconfig not found"
    return
  }
  
  with-env { TALOSCONFIG: $config } { talosctl -n $node get member }
}

# Get Talos version
export def version [] {
  talosctl version
}

# Check if cluster is healthy
export def health [talosconfig: string, nodes: list<string>] {
  for node in $nodes {
    with-env { TALOSCONFIG: $talosconfig } { talosctl -n $node health }
    if $env.LAST_EXIT_CODE != 0 {
      print $"Node ($node) is not healthy"
    } else {
      print $"Node ($node) is healthy"
    }
  }
}

# Upgrade Talos cluster
export def upgrade [
  talosconfig: string
  nodes: list<string>
  version: string
] {
  print $"Upgrading cluster to Talos ($version)..."
  
  for node in $nodes {
    print $"Upgrading node: ($node)"
    with-env { TALOSCONFIG: $talosconfig } { 
      talosctl -n $node upgrade --image $"ghcr.io/siderolabs/installer:($version)"
    }
  }
  
  print "Upgrade initiated. Monitor with: talosctl dashboard"
}

# Get cluster endpoints from terraform output
export def get-endpoint [environment: string] -> string {
  let env_dir = $"infra/terraform/environments/($environment)"
  
  let prev_dir = $env.PWD
  cd $env_dir
  let endpoint = (terraform output -raw cluster_endpoint | str trim)
  cd $prev_dir
  
  $endpoint
}

# Get node IPs from terraform output
export def get-nodes [environment: string] -> list<string> {
  let env_dir = $"infra/terraform/environments/($environment)"
  
  let prev_dir = $env.PWD
  cd $env_dir
  let output = (terraform output -json controlplane_ips | from json)
  cd $prev_dir
  
  $output
}

# Bootstrap Talos cluster
export def bootstrap [talosconfig: string, node: string] {
  print $"Bootstrapping cluster from node: ($node)"
  with-env { TALOSCONFIG: $talosconfig } { talosctl -n $node bootstrap }
}

# Reset Talos node
export def reset [talosconfig: string, node: string] {
  print $"WARNING: This will wipe node: ($node)"
  let confirm = (input "Type 'yes' to confirm: ")
  
  if $confirm == "yes" {
    with-env { TALOSCONFIG: $talosconfig } { talosctl -n $node reset --graceful }
  }
}
