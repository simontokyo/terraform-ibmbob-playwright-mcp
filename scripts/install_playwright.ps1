# PowerShell Script to Install Playwright Browsers
# Installs specified Playwright browsers using npx

param(
    [string]$Browsers = $env:PLAYWRIGHT_BROWSERS,
    [string]$ForceReinstall = $env:FORCE_REINSTALL,
    [string]$Verbose = $env:VERBOSE
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($Verbose -eq "true") {
        Write-Host "[$timestamp] [$Level] $Message"
    }
}

function Test-PlaywrightInstalled {
    param([string]$Browser)
    
    try {
        # Check if Playwright is installed and browser is available
        $result = npx playwright install --dry-run $Browser 2>&1
        
        # If dry-run succeeds without downloading, browser is already installed
        if ($result -match "is already installed" -or $result -match "Skipping") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

try {
    Write-Log "Starting Playwright browser installation..."
    
    # Verify Node.js and npm are available
    try {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Write-Log "Using Node.js $nodeVersion and npm $npmVersion"
    } catch {
        Write-Log "Node.js or npm not found. Please install Node.js first." "ERROR"
        exit 1
    }
    
    # Default to chrome if not specified
    if ([string]::IsNullOrEmpty($Browsers)) {
        $Browsers = "chrome"
    }
    
    Write-Log "Installing Playwright browser(s): $Browsers"
    
    # Check if already installed
    if ($ForceReinstall -ne "true") {
        $isInstalled = Test-PlaywrightInstalled -Browser $Browsers
        if ($isInstalled) {
            Write-Log "Playwright browser '$Browsers' is already installed. Use force_reinstall=true to reinstall." "INFO"
            exit 0
        }
    }
    
    # Install Playwright browsers using npm exec
    Write-Log "Running: npx playwright install $Browsers"
    
    try {
        if ($Browsers -eq "all") {
            # Install all browsers
            Write-Log "Installing all Playwright browsers..."
            & npx --yes playwright install
        } else {
            # Install specific browser
            Write-Log "Installing Playwright $Browsers browser..."
            & npx --yes playwright install $Browsers
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Playwright installation failed with exit code: $LASTEXITCODE" "ERROR"
            exit 1
        }
    } catch {
        Write-Log "Playwright installation failed: $_" "ERROR"
        exit 1
    }
    
    Write-Log "Playwright browser installation completed successfully" "SUCCESS"
    
    # Verify installation
    Write-Log "Verifying Playwright installation..."
    try {
        $playwrightVersion = & npx --yes playwright --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Playwright version: $playwrightVersion" "SUCCESS"
        }
    } catch {
        Write-Log "Warning: Could not verify Playwright version" "WARN"
    }
    
    # Test Playwright MCP
    Write-Log "Testing Playwright MCP package..."
    try {
        & npx --yes @playwright/mcp@latest --help 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Playwright MCP package is accessible" "SUCCESS"
        }
    } catch {
        Write-Log "Warning: Could not test Playwright MCP package" "WARN"
    }
    
    exit 0
    
} catch {
    Write-Log "Unexpected error during Playwright installation: $_" "ERROR"
    exit 1
}

# Made with Bob
