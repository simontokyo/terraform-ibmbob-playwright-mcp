# PowerShell Script to Check Node.js Installation
# Checks if Node.js is installed and meets minimum version requirement

param(
    [string]$MinVersion = $env:MIN_NODEJS_VERSION,
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

function Compare-Versions {
    param(
        [string]$Version1,
        [string]$Version2
    )
    
    $v1 = [version]($Version1 -replace '^v', '')
    $v2 = [version]($Version2 -replace '^v', '')
    
    return $v1.CompareTo($v2)
}

try {
    Write-Log "Checking Node.js installation..."
    
    # Check if Node.js is installed
    $nodeCommand = Get-Command node -ErrorAction SilentlyContinue
    
    if (-not $nodeCommand) {
        Write-Log "Node.js is not installed - will proceed with installation" "INFO"
        exit 0
    }
    
    # Get installed Node.js version
    $installedVersion = (node --version 2>&1) -replace '^v', ''
    Write-Log "Found Node.js version: v$installedVersion"
    
    # Compare with minimum required version
    $minVer = $MinVersion -replace '^v', ''
    $comparison = Compare-Versions -Version1 $installedVersion -Version2 $minVer
    
    if ($comparison -lt 0) {
        Write-Log "Node.js version v$installedVersion is older than required v$minVer - will proceed with installation" "INFO"
        exit 0
    }
    
    Write-Log "Node.js version v$installedVersion meets minimum requirement (v$minVer)" "SUCCESS"
    
    # Check npm
    $npmVersion = (npm --version 2>&1)
    Write-Log "npm version: $npmVersion"
    
    exit 0
    
} catch {
    Write-Log "Error checking Node.js: $_" "ERROR"
    exit 0
}

# Made with Bob
