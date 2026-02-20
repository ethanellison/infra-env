# Infrastructure operations - Terraform and Packer management
# Replaces Makefile targets for infrastructure operations

# Add mise shims to PATH
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/share/mise/shims")

const ENVIRONMENTS = ["staging", "prod"]

# Show help
export def help [] {
  print $"Usage: nu scripts/infra.nu <command> [environment]"
  print ""
  print "Terraform Commands:"
  print "  init <env>      Initialize Terraform for environment"
  print "  plan <env>     Plan Terraform changes"
  print "  apply <env>    Apply Terraform changes"
  print "  destroy <env> Destroy Terraform resources"
  print "  output <env>  Show Terraform outputs"
  print "  validate       Validate Terraform files"
  print ""
  print "Packer Commands:"
  print "  build-template    Build Packer template (Proxmox)"
  print "  validate-packer   Validate Packer files"
  print ""
  print "Utility Commands:"
  print "  get-configs <env> Extract kubeconfig and talosconfig"
  print "  clean             Clean Terraform caches"
  print ""
  print "Examples:"
  print "  nu scripts/infra.nu init staging"
  print "  nu scripts/infra.nu plan prod"
  print "  nu scripts/infra.nu apply staging"
  print "  nu scripts/infra.nu get-configs prod"
}

# Change to environment directory and execute closure
def with-env-dir [environment: string, closure: closure] {
  let env_dir = $"infra/terraform/environments/($environment)"
  
  if not ($env_dir | path exists) {
    print $"Error: Environment directory not found: ($env_dir)"
    return
  }
  
  let prev_dir = $env.PWD
  cd $env_dir
  do $closure
  cd $prev_dir
}

# Terraform init
export def init [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Initializing Terraform for: ($environment)..."
  with-env-dir $environment { terraform init }
}

# Terraform plan
export def plan [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Planning Terraform for: ($environment)..."
  with-env-dir $environment { terraform plan }
}

# Terraform apply
export def apply [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Applying Terraform for: ($environment)..."
  with-env-dir $environment { terraform apply }
}

# Terraform destroy
export def destroy [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"WARNING: This will destroy all resources in ($environment)!"
  let confirm = (input "Type 'yes' to confirm: ")
  
  if $confirm == "yes" {
    with-env-dir $environment { terraform destroy }
  } else {
    print "Destroy cancelled."
  }
}

# Terraform output
export def output [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  with-env-dir $environment { terraform output }
}

# Terraform validate
export def validate [] {
  print "Validating Terraform files..."
  
  for environment in $ENVIRONMENTS {
    let env_dir = $"infra/terraform/environments/($environment)"
    if ($env_dir | path exists) {
      let prev_dir = $env.PWD
      cd $env_dir
      print $"  Validating ($environment)..."
      terraform validate
      cd $prev_dir
    }
  }
  
  print "Validation complete."
}

# Packer build
export def build-template [] {
  print "Building Packer template for Proxmox..."
  
  let prev_dir = $env.PWD
  cd infra/packer
  
  packer init .
  packer build .
  
  cd $prev_dir
}

# Packer validate
export def validate-packer [] {
  print "Validating Packer files..."
  
  let prev_dir = $env.PWD
  cd infra/packer
  packer init .
  packer validate .
  cd $prev_dir
  
  print "Packer validation complete."
}

# Get kubeconfig and talosconfig
export def get-configs [environment: string] {
  if not ($ENVIRONMENTS | any { |x| $x == $environment }) {
    print $"Error: Unknown environment '($environment)'. Available: (($ENVIRONMENTS | str join ', '))"
    return
  }
  
  print $"Extracting configs for: ($environment)..."
  with-env-dir $environment {
    # Get kubeconfig
    let kubeconfig = (terraform output -raw kubeconfig)
    if $kubeconfig != "" {
      $kubeconfig | save -f $"kubeconfig"
      print "  Saved kubeconfig"
    }
    
    # Get talosconfig
    let talosconfig = (terraform output -raw talosconfig)
    if $talosconfig != "" {
      $talosconfig | save -f $"talosconfig"
      print "  Saved talosconfig"
    }
  }
}

# Clean Terraform caches
export def clean [] {
  print "Cleaning Terraform caches..."
  
  for environment in $ENVIRONMENTS {
    let env_dir = $"infra/terraform/environments/($environment)"
    if ($env_dir | path exists) {
      let prev_dir = $env.PWD
      cd $env_dir
      rm -rf .terraform
      rm -f .terraform.lock.hcl
      print $"  Cleaned ($environment)"
      cd $prev_dir
    }
  }
  
  # Also clean modules
  let modules = (ls infra/terraform/modules | where type == dir | get name)
  for module in $modules {
    rm -rf $"($module)/.terraform"
    rm -f $"($module)/.terraform.lock.hcl"
  }
  
  print "Clean complete."
}

# Main entry point
def main [cmd: string, arg?: string] {
  match $cmd {
    "help" => { help }
    "init" => { 
      if $arg == null { print "Error: environment required" } else { init $arg }
    }
    "plan" => { 
      if $arg == null { print "Error: environment required" } else { plan $arg }
    }
    "apply" => { 
      if $arg == null { print "Error: environment required" } else { apply $arg }
    }
    "destroy" => { 
      if $arg == null { print "Error: environment required" } else { destroy $arg }
    }
    "output" => { 
      if $arg == null { print "Error: environment required" } else { output $arg }
    }
    "validate" => { validate }
    "build-template" => { build-template }
    "validate-packer" => { validate-packer }
    "get-configs" => { 
      if $arg == null { print "Error: environment required" } else { get-configs $arg }
    }
    "clean" => { clean }
    _ => { 
      print $"Unknown command: ($cmd)"
      help
    }
  }
}
