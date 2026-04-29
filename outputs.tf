# Terraform Outputs for Playwright MCP Automation

output "detected_os" {
  description = "Detected operating system"
  value       = local.os_type
}

output "home_directory" {
  description = "User home directory path"
  value       = local.home_dir
}

output "bob_config_directory" {
  description = "IBM Bob configuration directory"
  value       = local.bob_config_dir
}

output "bob_config_file" {
  description = "IBM Bob MCP configuration file path"
  value       = local.bob_config_file
}

output "nodejs_min_version" {
  description = "Minimum required Node.js version"
  value       = var.nodejs_min_version
}

output "mcp_server_name" {
  description = "Configured MCP server name"
  value       = var.mcp_server_name
}

output "playwright_browser" {
  description = "Playwright browser installed (Chrome only)"
  value       = "chrome"
}

output "installation_summary" {
  description = "Summary of installation configuration"
  value = {
    os                      = local.os_type
    nodejs_min_version      = var.nodejs_min_version
    skip_nodejs_install     = var.skip_nodejs_install
    skip_playwright_install = var.skip_playwright_install
    force_reinstall         = var.force_reinstall
    mcp_server_name         = var.mcp_server_name
    playwright_browser      = "chrome"
    config_file             = local.bob_config_file
  }
}

output "next_steps" {
  description = "Next steps after installation"
  value = <<-EOT
    
    ✅ Playwright MCP Configuration Complete!
    
    Configuration file: ${local.bob_config_file}
    
    Next steps:
    1. Restart IBM Bob IDE to load the new MCP configuration
    2. Verify Playwright MCP is available in Bob's MCP servers list
    3. Test Playwright automation features
    
    To verify Node.js installation:
      node --version
    
    To verify Playwright installation:
      npx playwright --version
    
    To manually test Playwright MCP:
      npx @playwright/mcp@latest
    
  EOT
}