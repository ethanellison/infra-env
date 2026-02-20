# Toolbox management - Build, create, and enter container-based development environments
# Replaces Makefile targets for toolbox operations

# List of available toolboxes
const TOOLBOXES = ["dev", "cka", "infra", "playwright"]

# Default toolbox image registry
const REGISTRY = "localhost"

# Show help
export def help [] {
  print $"Usage: nu scripts/toolbox.nu <command> [toolbox-name]"
  print ""
  print "Commands:"
  print "  build [name]    Build toolbox images (default: all)"
  print "  create [name]  Create toolbox containers (default: all)"
  print "  enter <name>   Enter a toolbox"
  print "  list           List available toolboxes"
  print "  rebuild <name> Remove and recreate a toolbox"
  print "  remove <name>  Remove a toolbox"
  print ""
  print "Examples:"
  print "  nu scripts/toolbox.nu build"
  print "  nu scripts/toolbox.nu build dev"
  print "  nu scripts/toolbox.nu enter infra"
  print "  nu scripts/toolbox.nu rebuild cka"
}

# Build toolbox images
export def build [name?: string] {
  let toolboxes = if ($name | is-empty) { $TOOLBOXES } else { [$name] }
  
  for tb in $toolboxes {
    let dockerfile = $"toolboxes/($tb)/Dockerfile"
    
    if not ($dockerfile | path exists) {
      print $"Error: Dockerfile not found: ($dockerfile)"
      return
    }
    
    print $"Building toolbox: ($tb)..."
    let image = $"($REGISTRY)/toolbox-($tb):latest"
    
    (podman build 
      --tag $image 
      --file $dockerfile 
      $"toolboxes/($tb)")
    
    if $env.LAST_EXIT_CODE == 0 {
      print $"Successfully built: ($image)"
    } else {
      print $"Error building toolbox: ($tb)"
    }
  }
}

# Create toolbox containers
export def create [name?: string] {
  let toolboxes = if ($name | is-empty) { $TOOLBOXES } else { [$name] }
  
  for tb in $toolboxes {
    print $"Creating toolbox: ($tb)..."
    
    # Check if already exists using toolbox list
    let exists = (toolbox list err>| complete | get stdout | lines | any { |x| $x =~ $tb })
    
    if $exists {
      print $"Toolbox already exists: ($tb)"
      continue
    }
    
    let image = $"($REGISTRY)/toolbox-($tb):latest"
    
    # Use toolbox create (runs as current user by default)
    toolbox create --image $image $tb
    
    if $env.LAST_EXIT_CODE == 0 {
      print $"Successfully created toolbox: ($tb)"
    } else {
      print $"Error creating toolbox: ($tb)"
    }
  }
}

# Enter a toolbox
export def enter [name: string] {
  if not ($TOOLBOXES | any { |x| $x == $name }) {
    print $"Error: Unknown toolbox '($name)'. Available: (($TOOLBOXES | str join ', '))"
    return
  }
  
  # Check if container exists using toolbox list
  let exists = (toolbox list err>| complete | get stdout | lines | any { |x| $x =~ $name })
  
  if not $exists {
    print $"Toolbox '($name)' does not exist. Creating..."
    create $name
  }
  
  print $"Entering toolbox: ($name)"
  toolbox enter $name
}

# List available toolboxes
export def list [] {
  print "Available toolboxes:"
  for tb in $TOOLBOXES {
    let dockerfile = $"toolboxes/($tb)/Dockerfile"
    let exists = if ($dockerfile | path exists) { "✓" } else { "✗" }
    print $"  ($tb) - (if ($dockerfile | path exists) { 'exists' } else { 'missing' })"
  }
}

# Rebuild a toolbox (remove and recreate)
export def rebuild [name: string] {
  remove $name
  create $name
}

# Remove a toolbox
export def remove [name: string] {
  print $"Removing toolbox: ($name)..."
  
  toolbox rm -f $name
  
  if $env.LAST_EXIT_CODE == 0 {
    print $"Successfully removed toolbox: ($name)"
  } else {
    print $"Error removing toolbox: ($name)"
  }
}

# Main entry point
def main [cmd: string = "help", name?: string] {
  match $cmd {
    "help" => { help }
    "build" => { build $name }
    "create" => { create $name }
    "enter" => { 
      if $name == null {
        print "Error: toolbox name required"
        help
      } else {
        enter $name
      }
    }
    "list" => { list }
    "rebuild" => { 
      if $name == null {
        print "Error: toolbox name required"
      } else {
        rebuild $name
      }
    }
    "remove" => {
      if $name == null {
        print "Error: toolbox name required"
      } else {
        remove $name
      }
    }
    _ => { 
      print $"Unknown command: ($cmd)"
      help
    }
  }
}

main
