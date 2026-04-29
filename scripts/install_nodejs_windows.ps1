# PowerShell Script to Install Node.js on Windows using Chocolatey
# Installs Node.js v24.15.0 via Chocolatey package manager

param(
    [string]$NodeVersion = "24.15.0",
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

function Test-ChocolateyInstalled {
    try {
        $chocoVersion = choco --version 2>&1
        return $true
    } catch {
        return $false
    }
}

function Install-Chocolatey {
    Write-Log "Installing Chocolatey package manager..."
    try {
        # Download and install Chocolatey
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-Log "Chocolatey installed successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to install Chocolatey: $_" "ERROR"
        return $false
    }
}

try {
    Write-Log "Starting Node.js installation for Windows using Chocolatey..."
    
    # Check if already installed and force reinstall is not set
    if ($ForceReinstall -ne "true") {
        $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeInstalled) {
            $currentVersion = (node --version) -replace '^v', ''
            Write-Log "Node.js v$currentVersion is already installed. Use force_reinstall=true to reinstall." "INFO"
            exit 0
        }
    }
    
    # Check if Chocolatey is installed
    if (-not (Test-ChocolateyInstalled)) {
        Write-Log "Chocolatey not found, installing..."
        if (-not (Install-Chocolatey)) {
            Write-Log "Failed to install Chocolatey. Cannot proceed with Node.js installation." "ERROR"
            exit 1
        }
        
        # Wait for Chocolatey to be available
        Start-Sleep -Seconds 3
    } else {
        $chocoVersion = choco --version
        Write-Log "Chocolatey is already installed (version: $chocoVersion)"
    }
    
    # Uninstall existing Node.js if force reinstall
    if ($ForceReinstall -eq "true") {
        Write-Log "Force reinstall enabled, removing existing Node.js..."
        try {
            choco uninstall nodejs -y 2>&1 | Out-Null
            Start-Sleep -Seconds 2
        } catch {
            Write-Log "No existing Node.js installation found or uninstall failed" "WARN"
        }
    }
    
    # Install Node.js via Chocolatey
    Write-Log "Installing Node.js v$NodeVersion via Chocolatey..."
    Write-Log "Running: choco install nodejs --version=$NodeVersion -y"
    
    try {
        $chocoOutput = choco install nodejs --version=$NodeVersion -y 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Chocolatey installation failed with exit code: $LASTEXITCODE" "ERROR"
            Write-Log "Output: $chocoOutput" "ERROR"
            exit 1
        }
        
        Write-Log "Node.js installation completed successfully" "SUCCESS"
        
    } catch {
        Write-Log "Failed to install Node.js via Chocolatey: $_" "ERROR"
        exit 1
    }
    
    # Refresh environment variables
    Write-Log "Refreshing environment variables..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Verify installation
    Write-Log "Verifying Node.js installation..."
    Start-Sleep -Seconds 3
    
    try {
        $nodeVersion = node --version 2>&1
        $npmVersion = npm --version 2>&1
        
        Write-Log "Installed Node.js version: $nodeVersion" "SUCCESS"
        Write-Log "Installed npm version: $npmVersion" "SUCCESS"
        
        # Verify it's the correct version
        $installedVer = $nodeVersion -replace '^v', ''
        if ($installedVer -eq $NodeVersion) {
            Write-Log "Version verification successful: v$NodeVersion" "SUCCESS"
        } else {
            Write-Log "Warning: Installed version ($installedVer) differs from requested ($NodeVersion)" "WARN"
        }
        
    } catch {
        Write-Log "Node.js verification failed. You may need to restart your terminal." "WARN"
        Write-Log "Try running: node --version" "INFO"
    }
    
    exit 0
    
} catch {
    Write-Log "Unexpected error during Node.js installation: $_" "ERROR"
    exit 1
}

# Made with Bob
