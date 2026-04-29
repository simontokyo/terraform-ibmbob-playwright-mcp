# Local values for OS detection and platform-specific configurations

locals {
  # Detect operating system
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  is_macos   = !local.is_windows && fileexists("/usr/bin/sw_vers")
  is_linux   = !local.is_windows && !local.is_macos

  # Determine OS type string
  os_type = local.is_windows ? "windows" : (local.is_macos ? "macos" : "linux")

  # Home directory path (cross-platform)
  home_dir = pathexpand("~")

  # IBM Bob configuration paths by OS
  bob_config_dir = var.bob_config_path != "" ? var.bob_config_path : (
    local.is_windows ? "${local.home_dir}\\.bob\\settings" :
    "${local.home_dir}/.bob/settings"
  )

  bob_config_file = "${local.bob_config_dir}/mcp_settings.json"

  # Script paths
  scripts_dir = "${path.module}/scripts"

  # Node.js check scripts
  nodejs_check_script = local.is_windows ? "${local.scripts_dir}/check_nodejs.ps1" : "${local.scripts_dir}/check_nodejs.sh"

  # Node.js installation scripts
  nodejs_install_script = local.is_windows ? "${local.scripts_dir}/install_nodejs_windows.ps1" : "${local.scripts_dir}/install_nodejs_unix.sh"

  # Playwright installation scripts
  playwright_install_script = local.is_windows ? "${local.scripts_dir}/install_playwright.ps1" : "${local.scripts_dir}/install_playwright.sh"

  # Shell interpreter
  shell_interpreter = local.is_windows ? ["PowerShell", "-ExecutionPolicy", "Bypass", "-File"] : ["/bin/bash"]

  # Node.js version for installation
  nodejs_version = var.nodejs_min_version

  # Environment variables for scripts
  script_env = {
    MIN_NODEJS_VERSION    = var.nodejs_min_version
    NODEJS_VERSION        = local.nodejs_version
    FORCE_REINSTALL       = var.force_reinstall ? "true" : "false"
    VERBOSE               = var.verbose_output ? "true" : "false"
    PLAYWRIGHT_BROWSERS   = var.playwright_browsers
    BOB_CONFIG_DIR        = local.bob_config_dir
    BOB_CONFIG_FILE       = local.bob_config_file
  }

  # MCP configuration
  mcp_config = {
    mcpServers = {
      "${var.mcp_server_name}" = {
        command = "npx"
        args    = ["@playwright/mcp@latest"]
      }
    }
  }
}