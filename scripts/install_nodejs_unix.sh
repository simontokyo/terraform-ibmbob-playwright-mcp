#!/bin/bash
# Shell Script to Install Node.js on macOS and Ubuntu using nvm
# Installs Node.js v24.15.0 via Node Version Manager (nvm)

set -e

NODEJS_VERSION="${NODEJS_VERSION:-24}"
FORCE_REINSTALL="${FORCE_REINSTALL:-false}"
VERBOSE="${VERBOSE:-true}"
NVM_VERSION="v0.40.4"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$VERBOSE" = "true" ]; then
        echo "[$timestamp] [$level] $message"
    fi
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

install_nvm() {
    log "INFO" "Installing nvm (Node Version Manager) $NVM_VERSION..."
    
    # Download and install nvm
    if curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash; then
        log "SUCCESS" "nvm installed successfully"
    else
        log "ERROR" "Failed to install nvm"
        return 1
    fi
    
    # Load nvm into current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    return 0
}

check_nvm_installed() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if command -v nvm &> /dev/null; then
        return 0
    fi
    return 1
}

try_homebrew_install() {
    # Only attempt on macOS
    local os_type=$(detect_os)
    if [ "$os_type" != "macos" ]; then
        return 1
    fi
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        log "INFO" "Homebrew not found on macOS, will use nvm instead"
        return 1
    fi
    
    log "INFO" "Homebrew is already installed"
    log "INFO" "Attempting to install Node.js v24 using Homebrew..."
    
    if [ "$FORCE_REINSTALL" = "true" ]; then
        log "INFO" "Force reinstall enabled, removing existing Node.js..."
        brew uninstall node node@24 2>/dev/null || true
    fi
    
    # Install Node.js v24
    log "INFO" "Running: brew install node@24"
    if brew install node@24; then
        log "SUCCESS" "Node.js v24 installed successfully via Homebrew"
        return 0
    else
        log "WARN" "Homebrew installation failed, will use nvm instead"
        return 1
    fi
}

get_shell_profile() {
    # Determine the appropriate shell profile file
    if [ -f "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"
    elif [ -f "$HOME/.bashrc" ]; then
        echo "$HOME/.bashrc"
    else
        echo ""
    fi
}

main() {
    local os_type=$(detect_os)
    log "INFO" "Starting Node.js installation for $os_type using nvm..."
    
    # Check if already installed and force reinstall is not set
    if [ "$FORCE_REINSTALL" != "true" ]; then
        if command -v node &> /dev/null; then
            local current_version=$(node --version)
            log "INFO" "Node.js $current_version is already installed. Use force_reinstall=true to reinstall."
            exit 0
        fi
    fi
    
    # Try Homebrew first on macOS (optional)
    if [ "$os_type" = "macos" ]; then
        if try_homebrew_install; then
            # Verify installation
            if command -v node &> /dev/null; then
                local node_version=$(node --version)
                local npm_version=$(npm --version)
                log "SUCCESS" "Installed Node.js version: $node_version"
                log "SUCCESS" "Installed npm version: $npm_version"
                exit 0
            fi
        fi
    fi
    
    # Use nvm installation (works for both macOS and Linux)
    log "INFO" "Using nvm for Node.js installation..."
    
    # Check if nvm is installed
    if ! check_nvm_installed; then
        log "INFO" "nvm not found, installing..."
        if ! install_nvm; then
            log "ERROR" "Failed to install nvm"
            exit 1
        fi
    else
        log "INFO" "nvm is already installed"
        # Load nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Verify nvm is available
    if ! command -v nvm &> /dev/null; then
        log "ERROR" "nvm command not found after installation"
        log "INFO" "Please restart your shell and run this script again"
        exit 1
    fi
    
    local nvm_version=$(nvm --version 2>&1)
    log "INFO" "Using nvm version: $nvm_version"
    
    # Uninstall existing Node.js if force reinstall
    if [ "$FORCE_REINSTALL" = "true" ]; then
        log "INFO" "Force reinstall enabled, removing existing Node.js..."
        nvm uninstall "$NODEJS_VERSION" 2>/dev/null || true
    fi
    
    # Install Node.js via nvm
    log "INFO" "Installing Node.js v$NODEJS_VERSION via nvm..."
    log "INFO" "Running: nvm install $NODEJS_VERSION"
    
    if nvm install "$NODEJS_VERSION"; then
        log "SUCCESS" "Node.js installation completed successfully"
    else
        log "ERROR" "Failed to install Node.js via nvm"
        exit 1
    fi
    
    # Set as default version
    log "INFO" "Setting Node.js v$NODEJS_VERSION as default..."
    nvm alias default "$NODEJS_VERSION"
    nvm use "$NODEJS_VERSION"
    
    # Verify installation
    log "INFO" "Verifying Node.js installation..."
    sleep 2
    
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        local npm_version=$(npm --version)
        log "SUCCESS" "Installed Node.js version: $node_version"
        log "SUCCESS" "Installed npm version: $npm_version"
        
        # Verify it's the correct version
        if [[ "$node_version" == v24.* ]]; then
            log "SUCCESS" "Version verification successful: $node_version"
        else
            log "WARN" "Warning: Installed version ($node_version) may differ from expected (v24.x)"
        fi
        
        # Add nvm to shell profile if not already present
        log "INFO" "Ensuring nvm is loaded in shell profile..."
        local shell_profile=$(get_shell_profile)
        
        if [ -n "$shell_profile" ]; then
            if ! grep -q 'NVM_DIR' "$shell_profile"; then
                log "INFO" "Adding nvm to $shell_profile"
                cat >> "$shell_profile" << 'EOF'

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
                log "SUCCESS" "nvm configuration added to $shell_profile"
            else
                log "INFO" "nvm already configured in $shell_profile"
            fi
        fi
        
        log "INFO" "Note: You may need to restart your terminal or run: source $shell_profile"
        
        exit 0
    else
        log "ERROR" "Node.js installation verification failed"
        log "INFO" "Try running: source $shell_profile && node --version"
        exit 1
    fi
}

main "$@"

# Made with Bob
