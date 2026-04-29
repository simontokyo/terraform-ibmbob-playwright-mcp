# Terraform Configuration for Playwright MCP Automation
# Target: IBM Bob IDE on Windows, macOS, and Ubuntu

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Display detected OS information
resource "null_resource" "detect_os" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = local.is_windows ? "Write-Host 'Detected OS: Windows'" : "echo 'Detected OS: ${local.os_type}'"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}

# Check Node.js installation and version
resource "null_resource" "check_nodejs" {
  depends_on = [null_resource.detect_os]

  triggers = {
    force_reinstall = var.force_reinstall
    min_version     = var.nodejs_min_version
  }

  provisioner "local-exec" {
    command     = local.is_windows ? local.nodejs_check_script : "bash ${local.nodejs_check_script}"
    interpreter = local.is_windows ? ["PowerShell", "-ExecutionPolicy", "Bypass", "-File"] : []
    environment = local.script_env
  }
}

# Install Node.js if needed
resource "null_resource" "install_nodejs" {
  depends_on = [null_resource.check_nodejs]

  count = var.skip_nodejs_install ? 0 : 1

  triggers = {
    force_reinstall = var.force_reinstall
    script_hash     = filemd5(local.nodejs_install_script)
    # Always check if Node.js exists to ensure installation
    always_check    = timestamp()
  }

  provisioner "local-exec" {
    command = local.is_windows ? (
      "PowerShell -ExecutionPolicy Bypass -File ${local.nodejs_install_script}"
    ) : (
      "bash ${local.nodejs_install_script}"
    )
    environment = local.script_env
  }
}

# Verify Node.js installation
resource "null_resource" "verify_nodejs" {
  depends_on = [null_resource.install_nodejs]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = local.is_windows ? (
      "$nodePaths = @('C:\\Program Files\\nodejs\\node.exe', 'C:\\Program Files (x86)\\nodejs\\node.exe', \"$env:ProgramData\\chocolatey\\bin\\node.exe\"); $nodeFound = $false; foreach ($path in $nodePaths) { if (Test-Path $path) { $version = & $path --version; Write-Host \"Node.js found at $path : $version\"; $nodeFound = $true; break } }; if (-not $nodeFound) { $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User'); try { $version = node --version; Write-Host \"Node.js found in PATH: $version\"; $nodeFound = $true } catch { } }; if (-not $nodeFound) { Write-Error 'Node.js not found. Please restart your terminal or system.'; exit 1 }"
    ) : (
      # Check common Node.js installation paths on Unix systems
      "if command -v node >/dev/null 2>&1; then echo \"Node.js found: $(node --version)\"; exit 0; fi; export NVM_DIR=\"$HOME/.nvm\"; [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"; if command -v node >/dev/null 2>&1; then echo \"Node.js found via nvm: $(node --version)\"; exit 0; fi; if [ -f /usr/local/bin/node ]; then echo \"Node.js found at /usr/local/bin/node: $(/usr/local/bin/node --version)\"; exit 0; fi; if [ -f /opt/homebrew/bin/node ]; then echo \"Node.js found at /opt/homebrew/bin/node: $(/opt/homebrew/bin/node --version)\"; exit 0; fi; echo 'Node.js not found. Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc)' >&2; exit 1"
    )
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}

# Install Playwright browsers
resource "null_resource" "install_playwright" {
  depends_on = [null_resource.verify_nodejs]

  count = var.skip_playwright_install ? 0 : 1

  triggers = {
    force_reinstall = var.force_reinstall
    browsers        = var.playwright_browsers
    script_hash     = filemd5(local.playwright_install_script)
    # Always check if Playwright is installed to ensure installation
    always_check    = timestamp()
  }

  provisioner "local-exec" {
    command = local.is_windows ? (
      "PowerShell -ExecutionPolicy Bypass -File ${local.playwright_install_script}"
    ) : (
      "bash ${local.playwright_install_script}"
    )
    environment = local.script_env
  }
}

# Create IBM Bob settings directory if it doesn't exist
resource "null_resource" "create_bob_config_dir" {
  depends_on = [null_resource.install_playwright]

  triggers = {
    config_dir = local.bob_config_dir
  }

  provisioner "local-exec" {
    command = local.is_windows ? (
      "New-Item -ItemType Directory -Force -Path '${local.bob_config_dir}' | Out-Null"
    ) : (
      "mkdir -p '${local.bob_config_dir}'"
    )
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}

# Deploy MCP configuration to IBM Bob
resource "local_file" "mcp_config" {
  depends_on = [null_resource.create_bob_config_dir]

  filename = local.bob_config_file
  content  = jsonencode(local.mcp_config)

  file_permission = "0644"

  lifecycle {
    create_before_destroy = true
  }
}

# Validate MCP configuration
resource "null_resource" "validate_config" {
  depends_on = [local_file.mcp_config]

  triggers = {
    config_hash = local_file.mcp_config.content
  }

  provisioner "local-exec" {
    command = local.is_windows ? (
      "if (Test-Path '${local.bob_config_file}') { Write-Host 'MCP configuration deployed successfully' } else { Write-Error 'Configuration file not found'; exit 1 }"
    ) : (
      "if [ -f '${local.bob_config_file}' ]; then echo 'MCP configuration deployed successfully'; else echo 'Configuration file not found' >&2; exit 1; fi"
    )
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }
}