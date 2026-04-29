# Terraform Playwright MCP Automation - Implementation Plan

## Overview
This plan outlines the creation of a Terraform HCL script to automate Playwright MCP configuration for IBM Bob IDE on Windows, macOS, and Ubuntu.

## Architecture Design

### High-Level Flow
```
1. Detect Operating System
2. Check Node.js Installation (v24.15.0)
   ├─ If missing → Install Node.js
   └─ If present → Skip
3. Check Playwright Browser Installation
   ├─ If missing → Install Chrome via npx
   └─ If present → Skip
4. Configure MCP JSON
   └─ Deploy to Roo Code settings directory
```

### File Structure
```
terraform-playwright-mcp/
├── main.tf                 # Main orchestration logic
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── locals.tf               # Local values and OS detection
├── scripts/
│   ├── check_nodejs.sh     # Unix Node.js check script
│   ├── check_nodejs.ps1    # Windows Node.js check script
│   ├── install_nodejs_windows.ps1
│   ├── install_nodejs_macos.sh
│   ├── install_nodejs_ubuntu.sh
│   ├── install_playwright.sh
│   └── install_playwright.ps1
├── templates/
│   └── mcp_config.json.tpl # MCP configuration template
└── README.md               # Usage documentation
```

## Component Details

### 1. OS Detection (locals.tf)
- Use Terraform's built-in functions to detect OS
- Set OS-specific paths and commands
- Define configuration file locations per OS

**OS-Specific Paths:**
- **Windows**: `%USERPROFILE%\.bob\settings\mcp_settings.json` (C:\Users\<username>\.bob\settings\mcp_settings.json)
- **macOS**: `~/.bob/settings/mcp_settings.json`
- **Linux**: `~/.bob/settings/mcp_settings.json`

### 2. Variables (variables.tf)
```hcl
- nodejs_min_version (default: "18.0.0")
- skip_nodejs_install (default: false)
- skip_playwright_install (default: false)
- mcp_server_name (default: "playwright")
- force_reinstall (default: false)
```

### 3. Node.js Installation Logic

#### Windows (PowerShell)
- Check if Node.js v18 or newer is installed
- If not, download latest LTS from nodejs.org and install silently
- Verify installation meets minimum version requirement

#### macOS (Homebrew)
- Check if Homebrew is installed
- Check if Node.js v18 or newer is installed
- Use `brew install node` or download from nodejs.org
- Verify installation meets minimum version requirement

#### Ubuntu (apt)
- Check if Node.js v18 or newer is installed
- Add NodeSource repository for latest LTS
- Install via apt
- Verify installation meets minimum version requirement

### 4. Playwright Browser Installation
- Use `npx playwright install chrome`
- Check if Chrome browser is already installed
- Skip if present (unless force_reinstall is true)

### 5. MCP Configuration
**JSON Template:**
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

**Deployment Strategy:**
- Check if config file exists
- If exists, merge with existing configuration
- If not, create new file with proper directory structure
- Set appropriate file permissions

### 6. Terraform Resources

#### null_resource for OS Detection
```hcl
resource "null_resource" "detect_os" {
  provisioner "local-exec" {
    command = OS-specific detection command
  }
}
```

#### null_resource for Node.js Installation
```hcl
resource "null_resource" "install_nodejs" {
  depends_on = [null_resource.detect_os]
  
  provisioner "local-exec" {
    command = OS-specific Node.js installation script
  }
}
```

#### null_resource for Playwright Installation
```hcl
resource "null_resource" "install_playwright" {
  depends_on = [null_resource.install_nodejs]
  
  provisioner "local-exec" {
    command = "npx playwright install chrome"
  }
}
```

#### local_file for MCP Configuration
```hcl
resource "local_file" "mcp_config" {
  depends_on = [null_resource.install_playwright]
  
  content  = templatefile("templates/mcp_config.json.tpl", {...})
  filename = OS-specific path
}
```

## Implementation Steps

### Phase 1: Core Infrastructure
1. Create project structure
2. Implement OS detection in locals.tf
3. Define variables in variables.tf
4. Create basic main.tf with resource dependencies

### Phase 2: Node.js Installation
5. Create Windows PowerShell installation script
6. Create macOS Homebrew/direct installation script
7. Create Ubuntu apt installation script
8. Implement version check logic for all platforms
9. Add null_resource for Node.js installation

### Phase 3: Playwright Installation
10. Create Playwright installation scripts (Unix/Windows)
11. Add browser check logic
12. Implement null_resource for Playwright installation

### Phase 4: MCP Configuration
13. Create MCP JSON template
14. Implement configuration file deployment
15. Add merge logic for existing configurations
16. Handle directory creation and permissions

### Phase 5: Validation & Documentation
17. Create outputs.tf for status reporting
18. Add error handling and validation
19. Write comprehensive README.md
20. Test on all three platforms

## Key Considerations

### Idempotency
- All operations must be idempotent
- Check before install to avoid unnecessary operations
- Use Terraform's lifecycle management

### Error Handling
- Validate Node.js installation before proceeding
- Check Playwright installation success
- Verify MCP configuration file creation
- Provide clear error messages

### Security
- Use secure download methods (HTTPS)
- Verify checksums where possible
- Set appropriate file permissions on config files

### Cross-Platform Compatibility
- Use platform-agnostic Terraform functions where possible
- Isolate platform-specific logic in separate scripts
- Test path handling on all platforms

## Testing Strategy

1. **Unit Testing**: Test each script independently
2. **Integration Testing**: Test full Terraform workflow
3. **Platform Testing**: Verify on Windows, macOS, and Ubuntu
4. **Edge Cases**:
   - Existing Node.js installation (different version)
   - Existing Playwright installation
   - Existing MCP configuration
   - Missing dependencies (Homebrew on macOS)
   - Permission issues

## Success Criteria

- ✅ Terraform script runs successfully on all three platforms
- ✅ Node.js v24.15.0 is installed (or skipped if present)
- ✅ Playwright Chrome browser is installed
- ✅ MCP configuration is correctly deployed to Roo Code settings
- ✅ Script is idempotent (can be run multiple times safely)
- ✅ Clear error messages for any failures
- ✅ Comprehensive documentation provided

## Timeline Estimate

- Phase 1: 2-3 hours
- Phase 2: 4-5 hours
- Phase 3: 2-3 hours
- Phase 4: 3-4 hours
- Phase 5: 2-3 hours

**Total**: 13-18 hours of development time

## Next Steps

Once this plan is approved, the implementation will proceed in the order outlined above, with each phase building upon the previous one. The Code mode will be used for actual implementation of the Terraform scripts and supporting files.