# Terraform Playwright MCP - Architecture Overview

**Target IDE:** IBM Bob
**Node.js Version:** v24.15.0
**Playwright Browser:** Chrome only
**Configuration Path:** `~/.bob/settings/mcp_settings.json`

## System Architecture Diagram

```mermaid
flowchart TD
    Start([Terraform Apply]) --> DetectOS[Detect Operating System]
    
    DetectOS --> Windows{Windows?}
    DetectOS --> MacOS{macOS?}
    DetectOS --> Ubuntu{Ubuntu?}
    
    Windows --> CheckNodeWin[Check Node.js v24.15.0]
    MacOS --> CheckNodeMac[Check Node.js v24.15.0]
    Ubuntu --> CheckNodeUbu[Check Node.js v24.15.0]
    
    CheckNodeWin --> NodeExistsWin{Exists?}
    CheckNodeMac --> NodeExistsMac{Exists?}
    CheckNodeUbu --> NodeExistsUbu{Exists?}
    
    NodeExistsWin -->|No| InstallNodeWin[Install via Chocolatey v24.15.0]
    NodeExistsWin -->|Yes| SkipNodeWin[Skip Installation]
    
    NodeExistsMac -->|No| CheckBrew{Homebrew?}
    NodeExistsMac -->|Yes| SkipNodeMac[Skip Installation]
    
    CheckBrew -->|Yes| InstallNodeMac[brew install node@24]
    CheckBrew -->|No| InstallNodeMacNvm[nvm install 24]
    
    NodeExistsUbu -->|No| InstallNodeUbu[nvm install 24]
    NodeExistsUbu -->|Yes| SkipNodeUbu[Skip Installation]
    
    InstallNodeMac --> VerifyNodeMac[Verify Installation]
    InstallNodeMacNvm --> VerifyNodeMac
    
    InstallNodeWin --> VerifyNodeWin[Verify Installation]
    InstallNodeMac --> VerifyNodeMac[Verify Installation]
    InstallNodeUbu --> VerifyNodeUbu[Verify Installation]
    
    SkipNodeWin --> CheckPlaywright
    SkipNodeMac --> CheckPlaywright
    SkipNodeUbu --> CheckPlaywright
    VerifyNodeWin --> CheckPlaywright
    VerifyNodeMac --> CheckPlaywright
    VerifyNodeUbu --> CheckPlaywright
    
    CheckPlaywright[Check Playwright Chrome] --> PlaywrightExists{Exists?}
    
    PlaywrightExists -->|No| InstallPlaywright[npx playwright install chrome]
    PlaywrightExists -->|Yes| SkipPlaywright[Skip Installation]
    
    InstallPlaywright --> VerifyPlaywright[Verify Installation]
    SkipPlaywright --> ConfigMCP
    VerifyPlaywright --> ConfigMCP
    
    ConfigMCP[Configure MCP JSON] --> CheckConfig{Config Exists?}
    
    CheckConfig -->|Yes| MergeConfig[Merge with Existing]
    CheckConfig -->|No| CreateConfig[Create New Config]
    
    MergeConfig --> DeployConfig[Deploy to Roo Code Settings]
    CreateConfig --> DeployConfig
    
    DeployConfig --> SetPermissions[Set File Permissions]
    SetPermissions --> ValidateConfig[Validate Configuration]
    ValidateConfig --> Complete([Complete])
```

## Component Interaction Flow

```mermaid
sequenceDiagram
    participant TF as Terraform
    participant OS as OS Detection
    participant Node as Node.js Installer
    participant PW as Playwright Installer
    participant MCP as MCP Configurator
    participant FS as File System

    TF->>OS: Detect Operating System
    OS-->>TF: Return OS Type
    
    TF->>Node: Check Node.js v24.15.0
    Node->>FS: Query Installation
    FS-->>Node: Installation Status
    
    alt Node.js Not Installed
        Node->>FS: Download & Install
        FS-->>Node: Installation Complete
    else Node.js Already Installed
        Node-->>TF: Skip Installation
    end
    
    TF->>PW: Check Playwright Chrome
    PW->>FS: Query Browser Installation
    FS-->>PW: Browser Status
    
    alt Playwright Not Installed
        PW->>FS: Execute npx playwright install
        FS-->>PW: Installation Complete
    else Playwright Already Installed
        PW-->>TF: Skip Installation
    end
    
    TF->>MCP: Configure MCP Settings
    MCP->>FS: Check Existing Config
    FS-->>MCP: Config Status
    
    alt Config Exists
        MCP->>MCP: Merge Configurations
    else Config Not Exists
        MCP->>MCP: Create New Config
    end
    
    MCP->>FS: Write Config File
    FS-->>MCP: Write Complete
    MCP->>FS: Set Permissions
    FS-->>MCP: Permissions Set
    
    MCP-->>TF: Configuration Complete
    TF-->>TF: Output Results
```

## File Structure and Dependencies

```mermaid
graph LR
    subgraph Terraform Files
        Main[main.tf]
        Vars[variables.tf]
        Locals[locals.tf]
        Outputs[outputs.tf]
    end
    
    subgraph Scripts
        CheckNodeSh[check_nodejs.sh]
        CheckNodePs[check_nodejs.ps1]
        InstallWin[install_nodejs_windows.ps1]
        InstallMac[install_nodejs_macos.sh]
        InstallUbu[install_nodejs_ubuntu.sh]
        InstallPWSh[install_playwright.sh]
        InstallPWPs[install_playwright.ps1]
    end
    
    subgraph Templates
        MCPTpl[mcp_config.json.tpl]
    end
    
    subgraph Target System
        RooSettings[Roo Code Settings Directory]
        MCPConfig[cline_mcp_settings.json]
    end
    
    Main --> Vars
    Main --> Locals
    Main --> Outputs
    
    Main --> CheckNodeSh
    Main --> CheckNodePs
    Main --> InstallWin
    Main --> InstallMac
    Main --> InstallUbu
    Main --> InstallPWSh
    Main --> InstallPWPs
    
    Main --> MCPTpl
    MCPTpl --> MCPConfig
    MCPConfig --> RooSettings
```

## OS-Specific Configuration Paths

```mermaid
graph TD
    subgraph Windows
        WinPath["%USERPROFILE%\.bob\settings\mcp_settings.json"]
    end
    
    subgraph macOS
        MacPath["~/.bob/settings/mcp_settings.json"]
    end
    
    subgraph Linux
        LinuxPath["~/.bob/settings/mcp_settings.json"]
    end
    
    OSDetect[OS Detection] --> WinPath
    OSDetect --> MacPath
    OSDetect --> LinuxPath
```

## Resource Dependencies

```mermaid
graph TD
    A[null_resource.detect_os] --> B[null_resource.check_nodejs]
    B --> C{Node.js Installed?}
    C -->|No| D[null_resource.install_nodejs]
    C -->|Yes| E[null_resource.check_playwright]
    D --> E
    E --> F{Playwright Installed?}
    F -->|No| G[null_resource.install_playwright]
    F -->|Yes| H[local_file.mcp_config]
    G --> H
    H --> I[null_resource.validate_config]
    I --> J[Output Results]
```

## Error Handling Strategy

```mermaid
flowchart TD
    Start([Operation Start]) --> Try[Execute Operation]
    Try --> Success{Success?}
    
    Success -->|Yes| Log[Log Success]
    Success -->|No| Catch[Catch Error]
    
    Catch --> CheckRetry{Retryable?}
    CheckRetry -->|Yes| Retry[Retry Operation]
    CheckRetry -->|No| LogError[Log Error]
    
    Retry --> RetryCount{Retry < 3?}
    RetryCount -->|Yes| Try
    RetryCount -->|No| LogError
    
    LogError --> Rollback{Rollback Needed?}
    Rollback -->|Yes| RollbackOp[Rollback Changes]
    Rollback -->|No| Fail
    
    RollbackOp --> Fail[Fail with Message]
    Log --> Continue([Continue])
    Fail --> End([End])
```

## Key Design Principles

1. **Idempotency**: All operations can be safely repeated
2. **Cross-Platform**: Single codebase works on Windows, macOS, and Ubuntu
3. **Fail-Safe**: Graceful error handling with clear messages
4. **Modular**: Separate concerns into distinct scripts and modules
5. **Declarative**: Terraform manages state and dependencies
6. **Validation**: Each step validates before proceeding

## Security Considerations

- HTTPS downloads only
- Checksum verification where available
- Minimal privilege execution
- Secure file permissions on config files
- No hardcoded credentials
- Input validation on all parameters