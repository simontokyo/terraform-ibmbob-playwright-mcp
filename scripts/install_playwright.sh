#!/bin/bash
# Shell Script to Install Playwright Browsers
# Installs specified Playwright browsers using npx

set -e

BROWSERS="${PLAYWRIGHT_BROWSERS:-chrome}"
FORCE_REINSTALL="${FORCE_REINSTALL:-false}"
VERBOSE="${VERBOSE:-true}"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$VERBOSE" = "true" ]; then
        echo "[$timestamp] [$level] $message"
    fi
}

test_playwright_installed() {
    local browser="$1"
    
    # Check if Playwright is installed and browser is available
    if npx playwright install --dry-run "$browser" 2>&1 | grep -q "is already installed\|Skipping"; then
        return 0
    fi
    return 1
}

main() {
    log "INFO" "Starting Playwright browser installation..."
    
    # Load nvm if available (needed when Node.js was installed via nvm)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Verify Node.js and npm are available
    if ! command -v node &> /dev/null; then
        log "ERROR" "Node.js not found. Please install Node.js first or restart your terminal."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log "ERROR" "npm not found. Please install Node.js first or restart your terminal."
        exit 1
    fi
    
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    log "INFO" "Using Node.js $node_version and npm $npm_version"
    
    log "INFO" "Installing Playwright browser(s): $BROWSERS"
    
    # Check if already installed (but always attempt installation to ensure it's complete)
    if [ "$FORCE_REINSTALL" != "true" ]; then
        if test_playwright_installed "$BROWSERS"; then
            log "INFO" "Playwright browser '$BROWSERS' appears to be installed."
            log "INFO" "Running installation to verify/update..."
        fi
    fi
    
    # Install Playwright browsers
    log "INFO" "Running: npx playwright install $BROWSERS"
    
    if [ "$BROWSERS" = "all" ]; then
        # Install all browsers
        log "INFO" "Installing all Playwright browsers..."
        npx playwright install
    else
        # Install specific browser
        npx playwright install "$BROWSERS"
    fi
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Playwright installation failed"
        exit 1
    fi
    
    log "SUCCESS" "Playwright browser installation completed successfully"
    
    # Verify installation
    log "INFO" "Verifying Playwright installation..."
    if command -v npx &> /dev/null; then
        local playwright_version=$(npx playwright --version 2>&1 || echo "unknown")
        log "SUCCESS" "Playwright version: $playwright_version"
    fi
    
    # Test Playwright MCP
    log "INFO" "Testing Playwright MCP package..."
    if npx @playwright/mcp@latest --help &> /dev/null; then
        log "SUCCESS" "Playwright MCP package is accessible"
    else
        log "WARN" "Warning: Could not test Playwright MCP package"
    fi
    
    exit 0
}

main "$@"

# Made with Bob
