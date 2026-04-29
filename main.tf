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
      "node --version; if ($LASTEXITCODE -ne 0) { exit 1 }"
    ) : (
      "node --version || exit 1"
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