#!/bin/bash
# =============================================================================
# install-dev-workstation.sh - Ubuntu Developer Workstation Setup
# =============================================================================
#
# Automated setup script for an Ubuntu development workstation.
# Optimized for Proxmox VMs and cloud development.
#
# Package configuration is loaded from packages.json (local file or GitHub).
#
# Includes:
#   - Core: Git, MS Edge, GitKraken, VS Code, Postman, DBeaver
#   - Languages: Go, Node.js, Python, .NET SDK, PowerShell
#   - Shell: Zsh, Oh My Zsh, Oh My Posh (Bellows theme), Nerd Fonts
#   - Cloud CLIs: Azure CLI, AWS CLI, Google Cloud CLI, GitHub CLI
#   - Azure: Azure PowerShell (Az), Storage Explorer
#   - DevOps: Docker, Terraform, kubectl, Helm, k9s
#   - Database: psql, DBeaver
#   - Utilities: jq, htop, tree, ripgrep, build-essential
#   - Networking: dig, nslookup, whois, traceroute, mtr, nmap, nc, tcpdump
#   - Proxmox: qemu-guest-agent, spice-vdagent
#   - Remote: xrdp, openssh-server
#
# Target: Ubuntu Desktop on Proxmox VM
#
# Note: For headless servers (no GUI), use headless/install-headless.sh instead.
#
# Usage:
#   ./install-dev-workstation.sh                        # Run full setup
#   ./install-dev-workstation.sh --repo <org/repo>      # Use forked repo (default: kelomai/bellows)
#   ./install-dev-workstation.sh --branch <branch>      # Use specific branch (default: main)
#
# Remote:
#   wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash
#
# Author: 🧙‍♂️ Kelomai (https://kelomai.io)
# License: MIT
# =============================================================================

set -e

# =============================================================================
# COMMAND LINE FLAGS
# =============================================================================
GITHUB_REPO="kelomai/bellows"
BRANCH="main"

while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)
            GITHUB_REPO="$2"
            shift 2
            ;;
        --repo=*)
            GITHUB_REPO="${1#*=}"
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --branch=*)
            BRANCH="${1#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Configuration
GITHUB_MANIFEST_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${BRANCH}/ubuntu-setup/dev-workstation/packages.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$HOME/ubuntu-setup-${TIMESTAMP}.log"
FAILED_INSTALLS=()
SUCCESSFUL_INSTALLS=()

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_step() {
    echo "" | tee -a "$LOG_FILE"
    echo "=== $1 ===" | tee -a "$LOG_FILE"
}

install_package() {
    local name="$1"
    shift
    log ""
    log "Installing $name..."

    if (
        set -e
        "$@"
    ) >> "$LOG_FILE" 2>&1; then
        SUCCESSFUL_INSTALLS+=("$name")
        log "✓ $name installed successfully"
        return 0
    else
        FAILED_INSTALLS+=("$name")
        log "✗ $name FAILED - see log for details"
        return 0  # Don't exit on failure
    fi
}

install_with_commands() {
    local name="$1"
    log ""
    log "Installing $name..."

    if (
        set -e
        eval "$2"
    ) >> "$LOG_FILE" 2>&1; then
        SUCCESSFUL_INSTALLS+=("$name")
        log "✓ $name installed successfully"
        return 0
    else
        FAILED_INSTALLS+=("$name")
        log "✗ $name FAILED - see log for details"
        return 0  # Don't exit on failure
    fi
}

# Load package manifest from local file or GitHub
load_manifest() {
    local manifest_file=""

    # Check for local packages.json
    if [[ -f "$SCRIPT_DIR/packages.json" ]]; then
        manifest_file="$SCRIPT_DIR/packages.json"
        log "Loading manifest from: $manifest_file" >&2
    else
        # Fetch from GitHub
        log "Fetching manifest from GitHub..." >&2
        manifest_file="/tmp/packages-$$.json"
        if ! curl -fsSL "$GITHUB_MANIFEST_URL" -o "$manifest_file"; then
            log "ERROR: Failed to download package manifest" >&2
            exit 1
        fi
    fi

    # Validate JSON
    if ! jq empty "$manifest_file" 2>/dev/null; then
        log "ERROR: Invalid JSON in manifest file" >&2
        exit 1
    fi

    echo "$manifest_file"
}

# Get packages from manifest by category
get_apt_packages() {
    local manifest="$1"
    local category="$2"
    jq -r ".apt.$category[]? // empty" "$manifest" 2>/dev/null | tr '\n' ' '
}

get_snap_packages() {
    local manifest="$1"
    local type="$2"
    jq -r ".snap.$type[]?.name // empty" "$manifest" 2>/dev/null | tr '\n' ' '
}

has_third_party() {
    local manifest="$1"
    local category="$2"
    local package="$3"
    jq -e ".third_party.$category | index(\"$package\")" "$manifest" >/dev/null 2>&1
}

# =============================================================================
# START
# =============================================================================

echo "╔═════════════════════════════════════════════╗" | tee "$LOG_FILE"
echo "║        Welcome 👋 to 🧙‍♂️ Kelomai 🚀          ║" | tee -a "$LOG_FILE"
echo "║           https://kelomai.io                ║" | tee -a "$LOG_FILE"
echo "╠═════════════════════════════════════════════╣" | tee -a "$LOG_FILE"
echo "║    Ubuntu Development Environment Setup     ║" | tee -a "$LOG_FILE"
echo "╚═════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo ""

# Ensure curl and jq are available (needed before manifest loading)
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    log "Installing curl and jq..."
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y curl jq >> "$LOG_FILE" 2>&1
fi

# Load manifest
MANIFEST=$(load_manifest)
log "✓ Package manifest loaded"

# =============================================================================
# APT PACKAGES
# =============================================================================

log_step "Installing APT packages"

# Update package lists
log "Updating package lists..."
sudo apt update >> "$LOG_FILE" 2>&1

# Install prerequisites
PREREQS=$(get_apt_packages "$MANIFEST" "prerequisites")
if [[ -n "$PREREQS" ]]; then
    install_package "Prerequisites" sudo apt install -y $PREREQS
fi

# Install core packages
CORE=$(get_apt_packages "$MANIFEST" "core")
if [[ -n "$CORE" ]]; then
    install_package "Core Tools" sudo apt install -y $CORE
    sudo systemctl enable ssh >> "$LOG_FILE" 2>&1 || true
fi

# Install utilities
UTILS=$(get_apt_packages "$MANIFEST" "utilities")
if [[ -n "$UTILS" ]]; then
    install_package "Utilities" sudo apt install -y $UTILS
fi

# Install networking tools
NETWORK=$(get_apt_packages "$MANIFEST" "networking")
if [[ -n "$NETWORK" ]]; then
    install_package "Networking Tools" sudo apt install -y $NETWORK
fi

# Install Python
PYTHON=$(get_apt_packages "$MANIFEST" "python")
if [[ -n "$PYTHON" ]]; then
    install_package "Python" sudo apt install -y $PYTHON
fi

# Install database clients
DATABASE=$(get_apt_packages "$MANIFEST" "database")
if [[ -n "$DATABASE" ]]; then
    install_package "Database Clients" sudo apt install -y $DATABASE
fi

# Install shell
SHELL_PKGS=$(get_apt_packages "$MANIFEST" "shell")
if [[ -n "$SHELL_PKGS" ]]; then
    install_package "Shell" sudo apt install -y $SHELL_PKGS
fi

# Install Proxmox tools
PROXMOX=$(get_apt_packages "$MANIFEST" "proxmox")
if [[ -n "$PROXMOX" ]]; then
    install_with_commands "Proxmox VM Tools" "
        sudo apt install -y $PROXMOX
        sudo systemctl enable qemu-guest-agent 2>/dev/null || true
    "
fi

# Install remote tools
REMOTE=$(get_apt_packages "$MANIFEST" "remote")
if [[ -n "$REMOTE" ]]; then
    install_with_commands "Remote Desktop (xrdp)" "
        sudo apt install -y $REMOTE
        sudo systemctl enable xrdp 2>/dev/null || true
        sudo adduser xrdp ssl-cert 2>/dev/null || true
    "
fi

# =============================================================================
# SNAP PACKAGES
# =============================================================================

log_step "Installing Snap packages"

# Classic snaps
CLASSIC_SNAPS=$(get_snap_packages "$MANIFEST" "classic")
for snap in $CLASSIC_SNAPS; do
    install_package "$snap (snap)" sudo snap install "$snap" --classic
done

# Standard snaps
STANDARD_SNAPS=$(get_snap_packages "$MANIFEST" "standard")
for snap in $STANDARD_SNAPS; do
    install_package "$snap (snap)" sudo snap install "$snap"
done

# =============================================================================
# THIRD-PARTY PACKAGES (require custom install logic)
# =============================================================================

log_step "Installing third-party packages"

# Microsoft Edge
if has_third_party "$MANIFEST" "browsers" "microsoft-edge"; then
    install_with_commands "Microsoft Edge" '
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
        sudo apt update
        sudo apt install -y microsoft-edge-stable
    '
fi

# VS Code
if has_third_party "$MANIFEST" "editors" "vscode"; then
    install_with_commands "VS Code" '
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode-archive-keyring.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update
        sudo apt install -y code
    '
fi

# Node.js
if has_third_party "$MANIFEST" "languages" "nodejs"; then
    install_with_commands "Node.js" '
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt install -y nodejs
    '

    # Install npm global packages
    NPM_PACKAGES=$(jq -r '.npm_global[]? // empty' "$MANIFEST" 2>/dev/null)
    for pkg in $NPM_PACKAGES; do
        install_package "$pkg (npm)" sudo npm install -g "$pkg"
    done
fi

# .NET SDK
if has_third_party "$MANIFEST" "languages" "dotnet"; then
    install_with_commands ".NET SDK" '
        curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
        chmod +x /tmp/dotnet-install.sh
        sudo /tmp/dotnet-install.sh --channel STS --install-dir /usr/local/dotnet
        sudo ln -sf /usr/local/dotnet/dotnet /usr/local/bin/dotnet
        rm /tmp/dotnet-install.sh
    '
fi

# Azure CLI
if has_third_party "$MANIFEST" "cloud" "azure-cli"; then
    install_with_commands "Azure CLI" '
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    '
fi

# AWS CLI
if has_third_party "$MANIFEST" "cloud" "aws-cli"; then
    install_with_commands "AWS CLI" '
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
        unzip -q /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install --update
        rm -rf /tmp/awscliv2.zip /tmp/aws
    '
fi

# Google Cloud CLI
if has_third_party "$MANIFEST" "cloud" "gcloud-cli"; then
    install_with_commands "Google Cloud CLI" '
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
        sudo apt update
        sudo apt install -y google-cloud-cli
    '
fi

# GitHub CLI
if has_third_party "$MANIFEST" "cloud" "github-cli"; then
    install_with_commands "GitHub CLI" '
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    '
fi

# Docker
if has_third_party "$MANIFEST" "devops" "docker"; then
    install_with_commands "Docker" '
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER
    '
fi

# Terraform
if has_third_party "$MANIFEST" "devops" "terraform"; then
    install_with_commands "Terraform" '
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update
        sudo apt install -y terraform
    '
fi

# kubectl
if has_third_party "$MANIFEST" "devops" "kubectl"; then
    install_with_commands "kubectl" '
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt update
        sudo apt install -y kubectl
    '
fi

# Helm
if has_third_party "$MANIFEST" "devops" "helm"; then
    install_with_commands "Helm" '
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    '
fi

# k9s
if has_third_party "$MANIFEST" "devops" "k9s"; then
    install_with_commands "k9s" '
        curl -sS https://webinstall.dev/k9s | bash
    '
fi

# 1Password CLI
if has_third_party "$MANIFEST" "security" "1password-cli"; then
    install_with_commands "1Password CLI" '
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
        sudo apt update
        sudo apt install -y 1password-cli
    '
fi

# GitGuardian ggshield
if has_third_party "$MANIFEST" "security" "ggshield"; then
    install_package "ggshield (GitGuardian)" pip3 install --user ggshield
fi

# =============================================================================
# SHELL CONFIGURATION
# =============================================================================

log_step "Configuring shell"

# Oh My Zsh
if has_third_party "$MANIFEST" "shell" "oh-my-zsh"; then
    install_with_commands "Oh My Zsh" '
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        sudo chsh -s $(which zsh) $USER
    '

    # Install Zsh plugins from manifest
    ZSH_PLUGINS=$(jq -r '.zsh_plugins[]? // empty' "$MANIFEST" 2>/dev/null)
    for plugin in $ZSH_PLUGINS; do
        plugin_name=$(basename "$plugin")
        install_with_commands "Zsh plugin: $plugin_name" "
            ZSH_CUSTOM=\"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}\"
            git clone https://github.com/$plugin \"\$ZSH_CUSTOM/plugins/$plugin_name\" 2>/dev/null || true
        "
    done
fi

# Nerd Fonts
if has_third_party "$MANIFEST" "shell" "nerd-fonts"; then
    install_with_commands "Nerd Fonts" '
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        curl -fLo "FiraCode Nerd Font Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
        curl -fLo "FiraCode Nerd Font Bold.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFont-Bold.ttf
        fc-cache -fv
    '
fi

# Oh My Posh
if has_third_party "$MANIFEST" "shell" "oh-my-posh"; then
    install_with_commands "Oh My Posh" '
        curl -s https://ohmyposh.dev/install.sh | bash -s
        mkdir -p ~/.config/powershell
        cat > ~/.config/powershell/Microsoft.PowerShell_profile.ps1 << PWSH_PROFILE
# Oh My Posh with Azure theme
oh-my-posh init pwsh --config ~/.cache/oh-my-posh/themes/cloud-native-azure.omp.json | Invoke-Expression
PWSH_PROFILE
    '
fi

# PowerShell modules
PS_MODULES=$(jq -r '.powershell_modules[]? // empty' "$MANIFEST" 2>/dev/null)
for module in $PS_MODULES; do
    install_with_commands "PowerShell Module: $module" "
        pwsh -Command \"Install-Module -Name $module -Repository PSGallery -Force -Scope CurrentUser -AcceptLicense\"
    "
done

# =============================================================================
# SUMMARY
# =============================================================================

log ""
log "============================================"
log "=== Installation Complete ==="
log "============================================"
log ""
log "Finished at: $(date)"
log ""

# Show successful installs
log "✓ SUCCESSFUL INSTALLS (${#SUCCESSFUL_INSTALLS[@]}):"
for item in "${SUCCESSFUL_INSTALLS[@]}"; do
    log "  ✓ $item"
done

# Show failed installs
if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
    log ""
    log "✗ FAILED INSTALLS (${#FAILED_INSTALLS[@]}):"
    for item in "${FAILED_INSTALLS[@]}"; do
        log "  ✗ $item"
    done
    log ""
    log "Review the log file for error details:"
    log "  $LOG_FILE"
    log ""
    log "To search for errors: grep -i 'error\|failed' $LOG_FILE"
else
    log ""
    log "All installations completed successfully!"
fi

log ""
log "NOTES:"
log "  - Log out and back in for Docker group and Zsh shell to take effect"
log "  - RDP available on port 3389"
log "  - Configure terminal font to 'FiraCode Nerd Font' for icons"
log "  - Install 1Password browser extension in Edge manually"
log ""
log "TO UPDATE ALL PACKAGES:"
log "  wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash"
log ""
log "Log file saved to: $LOG_FILE"
log ""
echo "╔═════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" | tee -a "$LOG_FILE"
echo "║              https://kelomai.io                         ║" | tee -a "$LOG_FILE"
echo "╚═════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
