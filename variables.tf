# Terraform Variables for Playwright MCP Automation
# Target: IBM Bob IDE on Windows, macOS, and Ubuntu

variable "nodejs_min_version" {
  description = "Node.js version to install (default: 24.15.0)"
  type        = string
  default     = "24.15.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.nodejs_min_version))
    error_message = "Node.js version must be in semantic version format (e.g., 24.15.0)."
  }
}

variable "skip_nodejs_install" {
  description = "Skip Node.js installation even if not found or version is too old"
  type        = bool
  default     = false
}

variable "skip_playwright_install" {
  description = "Skip Playwright browser installation"
  type        = bool
  default     = false
}

variable "mcp_server_name" {
  description = "Name of the MCP server in configuration"
  type        = string
  default     = "playwright"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.mcp_server_name))
    error_message = "MCP server name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "force_reinstall" {
  description = "Force reinstallation of Node.js and Playwright even if already installed"
  type        = bool
  default     = false
}

variable "playwright_browsers" {
  description = "Playwright browser to install (locked to chrome only)"
  type        = string
  default     = "chrome"

  validation {
    condition     = var.playwright_browsers == "chrome"
    error_message = "Playwright browser must be 'chrome'. Other browsers are not supported."
  }
}

variable "bob_config_path" {
  description = "Custom path to IBM Bob configuration directory (leave empty for auto-detection)"
  type        = string
  default     = ""
}

variable "nodejs_download_url" {
  description = "Custom Node.js download URL (leave empty for default nodejs.org)"
  type        = string
  default     = ""
}

variable "verbose_output" {
  description = "Enable verbose output for installation scripts"
  type        = bool
  default     = true
}