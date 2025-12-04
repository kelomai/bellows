#!/bin/bash
# =============================================================================
# install-headless.sh - Ubuntu Headless Server Setup (CLI Only)
# =============================================================================
#
# Automated setup script for a headless Ubuntu server optimized for
# CLI-based development with Claude Code.
#
# Package configuration is loaded from packages.json (local file or GitHub).
#
# Includes:
#   - Core: Git, curl, wget, build-essential
#   - Languages: Go, Node.js, Python, .NET SDK
#   - Claude Code: AI coding assistant (npm)
#   - Cloud CLIs: Azure CLI, AWS CLI, Google Cloud CLI, GitHub CLI
#   - DevOps: Docker, Terraform, kubectl, Helm, k9s
#   - Shell: Zsh, Oh My Zsh
#   - Fonts: FiraCode Nerd Font, MesloLGS Nerd Font
#   - Utilities: jq, htop, tree, ripgrep, tmux
#   - Networking: dig, nslookup, whois, traceroute, mtr, nmap
#   - Remote: openssh-server
#
# NOT included (use dev-workstation for GUI):
#   - VS Code, GitKraken, MS Edge, Postman, DBeaver
#   - Azure Storage Explorer, xrdp
#
# Target: Ubuntu Server / Headless Ubuntu Desktop / WSL2 / Docker containers
#
# Usage:
#   ./install-headless.sh                        # Run full setup
#   ./install-headless.sh --repo <org/repo>      # Use forked repo (default: kelomai/bellows)
#   ./install-headless.sh --branch <branch>      # Use specific branch (default: main)
#
# Remote:
#   wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
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
GITHUB_MANIFEST_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${BRANCH}/ubuntu-setup/headless/packages.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$HOME/ubuntu-headless-${TIMESTAMP}.log"
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
        return 0
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
        return 0
    fi
}

load_manifest() {
    local manifest_file=""

    if [[ -f "$SCRIPT_DIR/packages.json" ]]; then
        manifest_file="$SCRIPT_DIR/packages.json"
        log "Loading manifest from: $manifest_file"
    else
        log "Fetching manifest from GitHub..."
        manifest_file="/tmp/packages-$$.json"
        if ! curl -fsSL "$GITHUB_MANIFEST_URL" -o "$manifest_file"; then
            log "ERROR: Failed to download package manifest"
            exit 1
        fi
    fi

    if ! jq empty "$manifest_file" 2>/dev/null; then
        log "ERROR: Invalid JSON in manifest file"
        exit 1
    fi

    echo "$manifest_file"
}

get_apt_packages() {
    local manifest="$1"
    local category="$2"
    jq -r ".apt.$category[]? // empty" "$manifest" 2>/dev/null | tr '\n' ' '
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
echo "║       Ubuntu Headless Server Setup          ║" | tee -a "$LOG_FILE"
echo "╚═════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo ""

# Ensure jq is available
if ! command -v jq &>/dev/null; then
    log "Installing jq for JSON parsing..."
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y jq >> "$LOG_FILE" 2>&1
fi

MANIFEST=$(load_manifest)
log "✓ Package manifest loaded"

# =============================================================================
# APT PACKAGES
# =============================================================================

log_step "Installing APT packages"

log "Updating package lists..."
sudo apt update >> "$LOG_FILE" 2>&1

PREREQS=$(get_apt_packages "$MANIFEST" "prerequisites")
[[ -n "$PREREQS" ]] && install_package "Prerequisites" sudo apt install -y $PREREQS

CORE=$(get_apt_packages "$MANIFEST" "core")
if [[ -n "$CORE" ]]; then
    install_package "Core Tools" sudo apt install -y $CORE
    sudo systemctl enable ssh >> "$LOG_FILE" 2>&1 || true
fi

UTILS=$(get_apt_packages "$MANIFEST" "utilities")
[[ -n "$UTILS" ]] && install_package "Utilities" sudo apt install -y $UTILS

NETWORK=$(get_apt_packages "$MANIFEST" "networking")
[[ -n "$NETWORK" ]] && install_package "Networking Tools" sudo apt install -y $NETWORK

PYTHON=$(get_apt_packages "$MANIFEST" "python")
[[ -n "$PYTHON" ]] && install_package "Python" sudo apt install -y $PYTHON

DATABASE=$(get_apt_packages "$MANIFEST" "database")
[[ -n "$DATABASE" ]] && install_package "Database Clients" sudo apt install -y $DATABASE

SHELL_PKGS=$(get_apt_packages "$MANIFEST" "shell")
[[ -n "$SHELL_PKGS" ]] && install_package "Shell" sudo apt install -y $SHELL_PKGS

# =============================================================================
# THIRD-PARTY PACKAGES
# =============================================================================

log_step "Installing third-party packages"

# Node.js + Claude Code
if has_third_party "$MANIFEST" "languages" "nodejs"; then
    install_with_commands "Node.js" '
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt install -y nodejs
    '
    NPM_PACKAGES=$(jq -r '.npm_global[]? // empty' "$MANIFEST" 2>/dev/null)
    for pkg in $NPM_PACKAGES; do
        install_package "$pkg (npm)" sudo npm install -g "$pkg"
    done
fi

# Go
if has_third_party "$MANIFEST" "languages" "go"; then
    install_with_commands "Go" '
        GO_VERSION="1.23.4"
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
    '
fi

# .NET SDK
if has_third_party "$MANIFEST" "languages" "dotnet"; then
    install_with_commands ".NET SDK" '
        curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
        chmod +x /tmp/dotnet-install.sh
        /tmp/dotnet-install.sh --channel STS --install-dir ~/.dotnet
        echo "export DOTNET_ROOT=\$HOME/.dotnet" >> ~/.profile
        echo "export PATH=\$PATH:\$DOTNET_ROOT" >> ~/.profile
        rm /tmp/dotnet-install.sh
    '
fi

# Azure CLI
if has_third_party "$MANIFEST" "cloud" "azure-cli"; then
    install_with_commands "Azure CLI" 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
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
        sudo apt update && sudo apt install -y google-cloud-cli
    '
fi

# GitHub CLI
if has_third_party "$MANIFEST" "cloud" "github-cli"; then
    install_with_commands "GitHub CLI" '
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install -y gh
    '
fi

# Docker
if has_third_party "$MANIFEST" "devops" "docker"; then
    install_with_commands "Docker" '
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER
    '
fi

# Terraform
if has_third_party "$MANIFEST" "devops" "terraform"; then
    install_with_commands "Terraform" '
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install -y terraform
    '
fi

# kubectl
if has_third_party "$MANIFEST" "devops" "kubectl"; then
    install_with_commands "kubectl" '
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt update && sudo apt install -y kubectl
    '
fi

# Helm
if has_third_party "$MANIFEST" "devops" "helm"; then
    install_with_commands "Helm" 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash'
fi

# k9s
if has_third_party "$MANIFEST" "devops" "k9s"; then
    install_with_commands "k9s" 'curl -sS https://webinstall.dev/k9s | bash'
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

    ZSH_PLUGINS=$(jq -r '.zsh_plugins[]? // empty' "$MANIFEST" 2>/dev/null)
    for plugin in $ZSH_PLUGINS; do
        plugin_name=$(basename "$plugin")
        install_with_commands "Zsh plugin: $plugin_name" "
            ZSH_CUSTOM=\"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}\"
            git clone https://github.com/$plugin \"\$ZSH_CUSTOM/plugins/$plugin_name\" 2>/dev/null || true
        "
    done

    # Configure .zshrc
    install_with_commands "Zsh Config" '
cat > ~/.zshrc << '\''ZSHRC'\''
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker kubectl terraform aws gcloud gh zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
alias k="kubectl"
alias tf="terraform"
alias g="git"
alias ll="ls -la"
export PATH=$PATH:/usr/local/go/bin:$HOME/.local/bin
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
ZSHRC
    '
fi

# Nerd Fonts
if has_third_party "$MANIFEST" "shell" "nerd-fonts"; then
    install_with_commands "Nerd Fonts" '
        mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
        curl -fLo "FiraCode Nerd Font Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
        curl -fLo "MesloLGS NF Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf
        fc-cache -fv 2>/dev/null || true
    '
fi

# =============================================================================
# SUMMARY
# =============================================================================

log ""
log "Finished at: $(date)"
log ""
log "✓ SUCCESSFUL (${#SUCCESSFUL_INSTALLS[@]}): ${SUCCESSFUL_INSTALLS[*]}"

if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
    log "✗ FAILED (${#FAILED_INSTALLS[@]}): ${FAILED_INSTALLS[*]}"
    log "Review: $LOG_FILE"
fi

log ""
log "NOTES:"
log "  - Log out and back in for Docker group and Zsh shell"
log "  - SSH available on port 22"
log ""
log "CLAUDE CODE: claude"
log "UPDATE: wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash"
log ""
echo "╔═════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║     ✅ Installation complete!                           ║" | tee -a "$LOG_FILE"
echo "╠═════════════════════════════════════════════════════════╣" | tee -a "$LOG_FILE"
echo "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" | tee -a "$LOG_FILE"
echo "║              https://kelomai.io                         ║" | tee -a "$LOG_FILE"
echo "╚═════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"
