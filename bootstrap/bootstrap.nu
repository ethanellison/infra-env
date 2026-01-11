#!/usr/bin/env nu

const TOOLBOXES = ["dev", "cka", "infra"]
const REPO_DIR = ($env.HOME | path join ".infra-env")
const TOOLBOXES_DIR = ($REPO_DIR | path join "toolboxes")

def die [message: string] {
    print -e $"ERROR: ($message)"
    exit 1
}

def build_toolbox [name: string] {
    let dockerfile = ($TOOLBOXES_DIR | path join $name "Dockerfile")
    
    if not ($dockerfile | path exists) {
        die $"Dockerfile not found for toolbox '($name)' at ($dockerfile)"
    }
    
    print $"Building toolbox image: ($name)"
    
    podman build \
        --file $dockerfile \
        --tag $"localhost/toolbox-($name):latest" \
        ($TOOLBOXES_DIR | path join $name) \
        | tee /dev/null
    
    if $env.LAST_EXIT_CODE != 0 {
        die $"Failed to build toolbox image for '($name)'"
    }
}

def toolbox_exists [name: string] -> bool {
    let toolbox_list = (toolbox list --raw 2>/dev/null | lines)
    $toolbox_list | any { $in == $name }
}

def create_toolbox [name: string] {
    if (toolbox_exists $name) {
        print $"Toolbox '($name)' already exists, skipping creation"
        return
    }
    
    print $"Creating toolbox: ($name)"
    
    toolbox create \
        --container-name $name \
        --image $"localhost/toolbox-($name):latest" \
    | tee /dev/null
    
    if $env.LAST_EXIT_CODE != 0 {
        die $"Failed to create toolbox '($name)'"
    }
}

def main [] {
    print "=== Phase 1: Environment Orchestration ==="
    print ""
    print "Step 1: Building toolbox container images"
    for toolbox in $TOOLBOXES {
        try {
            build_toolbox $toolbox
        } catch {
            die $"Toolbox build failed: ($in)"
        }
    }
    print ""
    print "Step 2: Creating toolboxes idempotently"
    for toolbox in $TOOLBOXES {
        try {
            create_toolbox $toolbox
        } catch {
            die $"Toolbox creation failed: ($in)"
        }
    }
    print ""
    print "=== Bootstrap Complete ==="
    print ""
    print "✓ Toolbox images built successfully"
    print "✓ Toolboxes created successfully"
    print ""
    print "Next steps:"
    print "  Enter a toolbox environment:     toolbox enter dev"
    print "  List available toolboxes:        toolbox list"
    print "  Run a command in a toolbox:      toolbox run -c dev <command>"
    print ""
}

# Execute main
main
