# Terraform IBM Bob Playwright MCP Automation

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Node.js](https://img.shields.io/badge/Node.js-v24.15.0-339933?logo=node.js)](https://nodejs.org/)
[![Playwright](https://img.shields.io/badge/Playwright-Chrome-2EAD33?logo=playwright)](https://playwright.dev/)
[![IBM Bob](https://img.shields.io/badge/IBM-Bob_IDE-0530AD?logo=ibm)](https://ibm.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Automate the installation and configuration of Playwright MCP for **IBM Bob IDE** on Windows, macOS, and Ubuntu using Terraform.

**Repository:** `terraform-ibmbob-playwright-mcp`

## Overview

This Terraform configuration automates the following tasks:
- ✅ Detects your operating system (Windows, macOS, or Ubuntu)
- ✅ Checks for Node.js v24.15.0 installation
- ✅ Installs Node.js v24.15.0 if not present (Chocolatey on Windows, nvm on macOS/Ubuntu)
- ✅ Installs Playwright Chrome browser only
- ✅ Configures IBM Bob IDE with Playwright MCP settings
- ✅ Validates the installation

## Prerequisites

### Required Software
- **Terraform** v1.14.9 or later ([Download](https://www.terraform.io/downloads))
- **Internet connection** for downloading Node.js and Playwright

### Platform-Specific Requirements

#### Windows
- PowerShell 5.1 or later (included in Windows 10/11)
- Administrator privileges (for Node.js installation if needed)

#### macOS
- No special requirements (will use Homebrew if available, otherwise nvm)

#### Ubuntu/Debian
- curl (for nvm installation)
- bash shell

## Quick Start

### 1. Clone or Download This Repository

```bash
git clone https://github.com/<username>/terraform-ibmbob-playwright-mcp.git
cd terraform-ibmbob-playwright-mcp
```

Or download and extract the ZIP file from the [releases page](https://github.com/<username>/terraform-ibmbob-playwright-mcp/releases).

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

This shows what Terraform will do without making any changes.

### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 5. Verify Installation

After successful completion, restart IBM Bob IDE and verify:
- Node.js is installed: `node --version`
- Playwright is installed: `npx playwright --version`
- MCP configuration exists: Check `~/.bob/settings/mcp_settings.json`

## Configuration Options

### Variables

You can customize the installation by setting variables. Create a `terraform.tfvars` file:

```hcl
# Node.js version to install (default: "24.15.0")
nodejs_min_version = "24.15.0"

# Skip Node.js installation (default: false)
skip_nodejs_install = false

# Skip Playwright installation (default: false)
skip_playwright_install = false

# MCP server name (default: "playwright")
mcp_server_name = "playwright"

# Force reinstallation (default: false)
force_reinstall = false

# Playwright browser (locked to chrome only, default: "chrome")
playwright_browsers = "chrome"

# Custom IBM Bob configuration path (default: "" for auto-detection)
bob_config_path = ""

# Custom Node.js download URL (default: "" for default sources)
nodejs_download_url = ""

# Enable verbose output (default: true)
verbose_output = true
```

### Command-Line Variables

You can also pass variables via command line:

```bash
terraform apply -var="force_reinstall=true" -var="verbose_output=false"
```

## Usage Examples

### Force Reinstall Everything

```bash
terraform apply -var="force_reinstall=true"
```

### Skip Node.js Installation (if already installed)

```bash
terraform apply -var="skip_nodejs_install=true"
```

### Custom MCP Server Name

```bash
terraform apply -var="mcp_server_name=my-playwright"
```

## File Structure

```
terraform-playwright-mcp/
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Input variables
├── locals.tf                        # Local values and OS detection
├── outputs.tf                       # Output values
├── README.md                        # This file
├── .gitignore                       # Git ignore patterns
├── terraform.tfvars.example         # Example configuration
├── scripts/
│   ├── check_nodejs.ps1            # Windows Node.js version check
│   ├── check_nodejs.sh             # Unix Node.js version check
│   ├── install_nodejs_windows.ps1  # Windows Node.js installer (Chocolatey)
│   ├── install_nodejs_unix.sh      # macOS/Ubuntu Node.js installer (nvm)
│   ├── install_playwright.ps1      # Windows Playwright Chrome installer
│   └── install_playwright.sh       # Unix Playwright Chrome installer
└── templates/
    └── mcp_config.json.tpl         # MCP configuration template
```

## IBM Bob Configuration

The MCP configuration is deployed to:
- **Windows**: `%USERPROFILE%\.bob\settings\mcp_settings.json`
- **macOS**: `~/.bob/settings/mcp_settings.json`
- **Linux**: `~/.bob/settings/mcp_settings.json`

### Configuration Format

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

## Troubleshooting

### Node.js Installation Fails

**Windows:**
- Ensure you have administrator privileges
- Check Windows Defender or antivirus isn't blocking the installer
- Try manual installation from [nodejs.org](https://nodejs.org/)

**macOS:**
- Install Xcode Command Line Tools: `xcode-select --install`
- If Homebrew fails, the script will fall back to direct installation

**Ubuntu:**
- Ensure you have sudo privileges
- Update package lists: `sudo apt-get update`
- Check internet connectivity

### Playwright Installation Fails

- Verify Node.js is installed: `node --version`
- Check npm is working: `npm --version`
- Try manual installation: `npx playwright install chrome`
- Check disk space (Playwright browsers require ~500MB)

### Configuration Not Applied

- Restart IBM Bob IDE after running Terraform
- Verify config file exists: 
  - Windows: `type %USERPROFILE%\.bob\settings\mcp_settings.json`
  - Unix: `cat ~/.bob/settings/mcp_settings.json`
- Check file permissions

### Permission Errors

**Windows:**
- Run PowerShell as Administrator
- Check execution policy: `Get-ExecutionPolicy`

**macOS/Linux:**
- Use sudo for system-wide installations
- Check file permissions: `ls -la ~/.bob/settings/`

## Uninstallation

To remove the MCP configuration:

```bash
terraform destroy
```

This will remove the MCP configuration file but will NOT uninstall Node.js or Playwright.

To manually uninstall:

**Node.js:**
- Windows: Use "Add or Remove Programs"
- macOS: `brew uninstall node` or remove from `/usr/local`
- Ubuntu: `sudo apt-get remove nodejs`

**Playwright:**
```bash
npx playwright uninstall
```

## Advanced Usage

### Custom Node.js Download URL

```bash
terraform apply -var='nodejs_download_url=https://custom-mirror.com/node.msi'
```

### Custom Bob Configuration Path

```bash
terraform apply -var='bob_config_path=/custom/path/to/bob/settings'
```

### Dry Run (Plan Only)

```bash
terraform plan -out=tfplan
# Review the plan
terraform show tfplan
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Setup Playwright MCP
on: [push]
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
      - run: terraform apply -auto-approve
```

## References

- [Playwright Documentation](https://playwright.dev/)
- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)
- [Node.js Downloads](https://nodejs.org/en/download)
- [Terraform Documentation](https://www.terraform.io/docs)
- [IBM Bob IDE](https://ibm.com/bob)

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Terraform output for error messages
3. Check script logs (verbose mode enabled by default)
4. Verify prerequisites are met

## License

This project is provided as-is for automating Playwright MCP setup.

## Contributing

Contributions are welcome! Please ensure:
- Scripts work on all three platforms (Windows, macOS, Ubuntu)
- Error handling is comprehensive
- Documentation is updated
- Code follows existing patterns

## Changelog

### Version 1.0.0
- Initial release
- Support for Windows, macOS, and Ubuntu
- Node.js v18+ installation
- Playwright Chrome browser installation
- IBM Bob MCP configuration
- Idempotent operations
- Comprehensive error handling