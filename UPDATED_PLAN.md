# Updated Terraform Playwright MCP Automation Plan

## Changes from Original Plan

### ✅ Key Updates Applied

1. **Target IDE Changed**: Roo Code → **IBM Bob**
2. **Node.js Version**: v24.15.0 → **v18 or newer** (more flexible)
3. **MCP Args Format**: `["-y", "@playwright/mcp@latest"]` → **`["@playwright/mcp@latest"]`**
4. **Configuration Paths Updated**:
   - Windows: `%USERPROFILE%\.bob\settings\mcp_settings.json`
   - macOS: `~/.bob/settings/mcp_settings.json`
   - Linux: `~/.bob/settings/mcp_settings.json`

### Verified Configuration

Based on the actual IBM Bob configuration file at `C:\Users\<user>\.bob\settings\mcp_settings.json`:

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

## What Will Be Created

### Terraform Files
1. **main.tf** - Main orchestration with null_resource and local_file resources
2. **variables.tf** - Input variables (nodejs_min_version, skip flags, etc.)
3. **locals.tf** - OS detection and platform-specific path configuration
4. **outputs.tf** - Installation status and paths

### Installation Scripts

**Windows (PowerShell):**
- `scripts/check_nodejs.ps1` - Check Node.js v18+ installation
- `scripts/install_nodejs_windows.ps1` - Install latest LTS Node.js
- `scripts/install_playwright.ps1` - Install Playwright Chrome

**Unix (Shell - macOS/Ubuntu):**
- `scripts/check_nodejs.sh` - Check Node.js v18+ installation
- `scripts/install_nodejs_macos.sh` - Install Node.js on macOS
- `scripts/install_nodejs_ubuntu.sh` - Install Node.js on Ubuntu
- `scripts/install_playwright.sh` - Install Playwright Chrome

### Templates
- `templates/mcp_config.json.tpl` - IBM Bob MCP configuration template

### Documentation
- `README.md` - Complete usage guide
- `IMPLEMENTATION_PLAN.md` - Technical details (updated)
- `ARCHITECTURE.md` - System architecture (updated)
- `PROJECT_SUMMARY.md` - Executive summary (updated)

## Implementation Workflow

```
1. Detect OS (Windows/macOS/Ubuntu)
   ↓
2. Check Node.js version (≥18.0.0)
   ↓
3. Install Node.js if needed (or skip)
   ↓
4. Verify Node.js installation
   ↓
5. Check Playwright Chrome browser
   ↓
6. Install Playwright if needed (or skip)
   ↓
7. Verify Playwright installation
   ↓
8. Deploy MCP configuration to ~/.bob/settings/
   ↓
9. Validate configuration
   ↓
10. Output results
```

## Key Features

✅ **Cross-Platform**: Windows, macOS, Ubuntu  
✅ **Idempotent**: Safe to run multiple times  
✅ **Smart Detection**: Skips existing installations  
✅ **Flexible Node.js**: Accepts v18 or newer  
✅ **Error Handling**: Clear messages and validation  
✅ **IBM Bob Integration**: Correct paths and format  

## Prerequisites

- Terraform v1.0.0+
- Internet connection
- Platform-specific requirements:
  - **Windows**: PowerShell 5.1+, Admin privileges (if installing)
  - **macOS**: Homebrew (optional), Xcode CLI Tools
  - **Ubuntu**: sudo privileges, apt

## Usage Example

```bash
# Initialize
terraform init

# Review plan
terraform plan

# Apply configuration
terraform apply

# Check outputs
terraform output
```

## Ready for Implementation

All planning documents have been updated with:
- ✅ IBM Bob configuration paths
- ✅ Node.js v18+ requirement
- ✅ Correct MCP args format
- ✅ Verified configuration structure

**Next Step**: Switch to Code mode to implement the Terraform scripts and supporting files.