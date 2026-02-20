# Common utilities for Nushell scripts
# Shared functions used across all scripts

# Print error message and exit
export def die [message: string] {
  print $"Error: ($message)"
  exit 1
}

# Print with timestamp
export def log [level: string, message: string] {
  let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S")
  print $"[($timestamp)] [($level)] ($message)"
}

# Info log
export def info [message: string] {
  log "INFO" $message
}

# Warning log
export def warn [message: string] {
  log "WARN" $message
}

# Error log
export def error [message: string] {
  log "ERROR" $message
}

# Ask for user confirmation
export def confirm [prompt: string] -> bool {
  let answer = (input $"($prompt) [y/N]: ")
  $answer | str downcase | str contains "y"
}

# Check if command exists
export def has-command [cmd: string] -> bool {
  which $cmd | is-not-empty
}

# Require command to exist or exit
export def require-command [cmd: string] {
  if not (has-command $cmd) {
    die $"Required command not found: ($cmd)"
  }
}

# Get current script directory
export def script-dir [] {
  $env.CURRENT_FILE | path dirname | path expand
}

# Ensure directory exists
export def ensure-dir [dir: string] {
  if not ($dir | path exists) {
    mkdir -p $dir
    info $"Created directory: ($dir)"
  }
}

# Check if running in CI
export def is-ci [] -> bool {
  $env.CI? | is-not-empty
}

# Print a section header
export def section [title: string] {
  print ""
  print "========================"
  print $title
  print "========================"
}

# Print a success message
export def success [message: string] {
  print $"✓ ($message)"
}

# Print a failure message
export def failure [message: string] {
  print $"✗ ($message)"
}
