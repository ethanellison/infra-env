# Cluster operations - Deploy, test, and manage Talos Kubernetes clusters
# High-level cluster management commands

# Add mise shims to PATH
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/share/mise/shims")

const ENVIRONMENTS = ["staging", "prod"]

# Show help
export def help [] {
  print $"Usage: nu scripts/cluster.nu <command> [environment]"
  print ""
  print "Commands:"
  print "  deploy <env>      Full cluster deployment (infra + Talos)"
  print "  status <env>      Check cluster health status"
  print "  destroy <env>     Destroy cluster and infrastructure"
  print "  benchmark <type>  Run benchmarks (network, storage, etc.)"
  print "  nodes <env>       List cluster nodes"
  print "  dashboard <env>   Open Talos dashboard"
  print ""
  print "Examples:"
  print "  nu scripts/cluster.nu deploy staging"
  print "  nu scripts/cluster.nu status prod"
  print "  nu scripts/cluster.nu nodes staging"
}

# Full cluster deployment
export def deploy [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Deploying cluster: ($environment)"
  print "========================"
  
  # Step 1: Terraform init
  print "Step 1/3: Initializing Terraform..."
  nu scripts/infra.nu init $environment
  
  # Step 2: Terraform apply
  print "Step 2/3: Provisioning infrastructure..."
  nu scripts/infra.nu apply $environment
  
  # Step 3: Get configs
  print "Step 3/3: Extracting configs..."
  nu scripts/infra.nu get-configs $environment
  
  print ""
  print "========================"
  print $"Cluster ($environment) deployed successfully!"
  print "Use: nu scripts/cluster.nu status ($environment)"
}

# Check cluster status
export def status [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Cluster status: ($environment)"
  print "========================"
  
  let env_dir = $"infra/terraform/environments/($environment)"
  
  if not ($env_dir | path exists) {
    print "Error: Environment not initialized"
    return
  }
  
  let prev_dir = $env.PWD
  cd $env_dir
  
  # Check if kubeconfig exists
  let kubeconfig = $"($env_dir)/kubeconfig"
  if not ($kubeconfig | path exists) {
    print "Error: kubeconfig not found. Run: nu scripts/infra.nu get-configs (env)"
    cd $prev_dir
    return
  }
  
  # Show Terraform outputs
  print "Terraform Outputs:"
  terraform output
  
  # Show Kubernetes nodes if kubeconfig available
  print ""
  print "Kubernetes Nodes:"
  with-env { KUBECONFIG: $kubeconfig } { kubectl get nodes }
  
  cd $prev_dir
}

# List cluster nodes
export def nodes [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  let env_dir = $"infra/terraform/environments/($environment)"
  let kubeconfig = $"($env_dir)/kubeconfig"
  
  if not ($kubeconfig | path exists) {
    print "Error: kubeconfig not found"
    return
  }
  
  with-env { KUBECONFIG: $kubeconfig } { kubectl get nodes -o wide }
}

# Destroy cluster
export def destroy [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"WARNING: This will destroy the entire ($environment) cluster!"
  let confirm = (input "Type 'yes' to confirm: ")
  
  if $confirm == "yes" {
    nu scripts/infra.nu destroy $environment
    
    # Clean up configs
    let env_dir = $"infra/terraform/environments/($environment)"
    rm -f $"($env_dir)/kubeconfig"
    rm -f $"($env_dir)/talosconfig"
    
    print "Cluster destroyed."
  } else {
    print "Destroy cancelled."
  }
}

# Run benchmarks
export def benchmark [type: string] {
  let benchmark_types = ["network", "storage", "cpu", "memory"]
  
  if not ($benchmark_types | any { |x| $x == $type }) {
    print $"Error: Unknown benchmark type. Available: (($benchmark_types | str join ', '))"
    return
  }
  
  print $"Running ($type) benchmark..."
  
  let kubeconfig = "infra/terraform/environments/staging/kubeconfig"
  
  if not ($kubeconfig | path exists) {
    print "Error: kubeconfig not found"
    return
  }
  
  # Run kube-burner based on type
  match $type {
    "network" => {
      print "Running network benchmark..."
      let prev_dir = $env.PWD
      cd testing/benchmarks/kube-burner
      # kubectl apply -f ... (benchmark config)
      cd $prev_dir
    }
    "storage" => {
      print "Running storage benchmark..."
    }
    "cpu" => {
      print "Running CPU benchmark..."
    }
    "memory" => {
      print "Running memory benchmark..."
    }
  }
  
  print "Benchmark complete."
}

# Open Talos dashboard
export def dashboard [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  let env_dir = $"infra/terraform/environments/($environment)"
  let talosconfig = $"($env_dir)/talosconfig"
  
  if not ($talosconfig | path exists) {
    print "Error: talosconfig not found"
    return
  }
  
  # Get first control plane node IP from terraform output
  let prev_dir = $env.PWD
  cd $env_dir
  let node_ip = (terraform output -json controlplane_ips | from json | first)
  cd $prev_dir
  
  with-env { TALOSCONFIG: $talosconfig } { talosctl dashboard -n $node_ip }
}

# Main entry point
def main [cmd: string, arg?: string] {
  match $cmd {
    "help" => { help }
    "deploy" => { 
      if $arg == null { print "Error: environment required" } else { deploy $arg }
    }
    "status" => { 
      if $arg == null { print "Error: environment required" } else { status $arg }
    }
    "nodes" => { 
      if $arg == null { print "Error: environment required" } else { nodes $arg }
    }
    "destroy" => { 
      if $arg == null { print "Error: environment required" } else { destroy $arg }
    }
    "benchmark" => { 
      if $arg == null { print "Error: benchmark type required" } else { benchmark $arg }
    }
    "dashboard" => { 
      if $arg == null { print "Error: environment required" } else { dashboard $arg }
    }
    _ => { 
      print $"Unknown command: ($cmd)"
      help
    }
  }
}
