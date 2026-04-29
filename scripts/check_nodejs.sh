#!/bin/bash
# Shell Script to Check Node.js Installation
# Checks if Node.js is installed and meets minimum version requirement

set -e

MIN_VERSION="${MIN_NODEJS_VERSION:-18.0.0}"
VERBOSE="${VERBOSE:-true}"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$VERBOSE" = "true" ]; then
        echo "[$timestamp] [$level] $message"
    fi
}

version_compare() {
    local ver1="$1"
    local ver2="$2"
    
    # Remove 'v' prefix if present
    ver1="${ver1#v}"
    ver2="${ver2#v}"
    
    # Compare versions
    if [ "$ver1" = "$ver2" ]; then
        echo "0"
        return
    fi
    
    local IFS=.
    local i ver1_arr=($ver1) ver2_arr=($ver2)
    
    # Fill empty positions with zeros
    for ((i=${#ver1_arr[@]}; i<${#ver2_arr[@]}; i++)); do
        ver1_arr[i]=0
    done
    
    for ((i=0; i<${#ver1_arr[@]}; i++)); do
        if [[ -z ${ver2_arr[i]} ]]; then
            ver2_arr[i]=0
        fi
        if ((10#${ver1_arr[i]} > 10#${ver2_arr[i]})); then
            echo "1"
            return
        fi
        if ((10#${ver1_arr[i]} < 10#${ver2_arr[i]})); then
            echo "-1"
            return
        fi
    done
    echo "0"
}

main() {
    log "INFO" "Checking Node.js installation..."
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log "INFO" "Node.js is not installed - will proceed with installation"
        exit 0
    fi
    
    # Get installed Node.js version
    installed_version=$(node --version 2>&1)
    installed_version="${installed_version#v}"
    log "INFO" "Found Node.js version: v$installed_version"
    
    # Compare with minimum required version
    min_ver="${MIN_VERSION#v}"
    comparison=$(version_compare "$installed_version" "$min_ver")
    
    if [ "$comparison" = "-1" ]; then
        log "INFO" "Node.js version v$installed_version is older than required v$min_ver - will proceed with installation"
        exit 0
    fi
    
    log "SUCCESS" "Node.js version v$installed_version meets minimum requirement (v$min_ver)"
    
    # Check npm
    if command -v npm &> /dev/null; then
        npm_version=$(npm --version 2>&1)
        log "INFO" "npm version: $npm_version"
    fi
    
    exit 0
}

main "$@"

# Made with Bob
