#!/bin/bash
# =============================================================================
# install-headless.sh - Ubuntu Headless Server Setup (CLI Only)
# =============================================================================
#
# Automated setup script for a headless Ubuntu server optimized for
# CLI-based development with Claude Code.
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
# Remote:
#   wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
#
# Author: Bellows
# License: MIT
# =============================================================================
#
# Log file: ~/ubuntu-headless-<timestamp>.log

# Setup logging and error tracking
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$HOME/ubuntu-headless-${TIMESTAMP}.log"
FAILED_INSTALLS=()
SUCCESSFUL_INSTALLS=()

# Logging function - shows on screen and logs to file
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Install wrapper - runs commands in subshell, tracks success/failure
install_package() {
    local name="$1"
    shift
    log ""
    log "=== Installing $name ==="

    # Run all commands in subshell, capture output
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
        return 1
    fi
}

# For multi-command installs, use this pattern
install_with_commands() {
    local name="$1"
    log ""
    log "=== Installing $name ==="

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
        return 1
    fi
}

# Start
echo "=== Ubuntu Headless Server Setup ===" | tee "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo ""

# Update package lists
log "Updating package lists..."
sudo apt update >> "$LOG_FILE" 2>&1

# Install prerequisites
log "Installing prerequisites..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common unzip >> "$LOG_FILE" 2>&1

# =============================================================================
# CORE TOOLS
# =============================================================================

# 1. Git
install_package "Git" sudo apt install -y git

# 2. Build essentials
install_package "Build Tools" sudo apt install -y build-essential

# 3. Utilities
install_package "Utilities" sudo apt install -y jq htop tree ripgrep tmux

# 4. SSH Server
install_with_commands "SSH Server" '
sudo apt install -y openssh-server
sudo systemctl enable ssh
'

# 5. Networking Tools
install_package "Networking Tools" sudo apt install -y dnsutils whois traceroute mtr-tiny nmap netcat-openbsd net-tools

# =============================================================================
# PROGRAMMING LANGUAGES
# =============================================================================

# 6. Python
install_package "Python" sudo apt install -y python3 python3-pip python3-venv

# 7. Node.js + Claude Code
install_with_commands "Node.js + Claude Code" '
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g @anthropic-ai/claude-code
'

# 8. Go (latest stable)
install_with_commands "Go" '
GO_VERSION="1.23.4"
curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
'

# 9. .NET SDK (latest via install script)
install_with_commands ".NET SDK" '
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel STS --install-dir /usr/local/dotnet
sudo ln -sf /usr/local/dotnet/dotnet /usr/local/bin/dotnet
rm /tmp/dotnet-install.sh
echo "export DOTNET_ROOT=/usr/local/dotnet" >> ~/.profile
echo "export PATH=\$PATH:\$DOTNET_ROOT" >> ~/.profile
'

# =============================================================================
# CLOUD CLIs
# =============================================================================

# 10. Azure CLI
install_with_commands "Azure CLI" '
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
'

# 11. AWS CLI
install_with_commands "AWS CLI" '
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
'

# 12. Google Cloud CLI
install_with_commands "Google Cloud CLI" '
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install -y google-cloud-cli
'

# 13. GitHub CLI
install_with_commands "GitHub CLI" '
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
'

# =============================================================================
# DEVOPS TOOLS
# =============================================================================

# 14. Docker
install_with_commands "Docker" '
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
'

# 15. Terraform
install_with_commands "Terraform" '
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
'

# 16. kubectl (latest stable)
install_with_commands "kubectl" '
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
'

# 17. Helm
install_with_commands "Helm" '
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
'

# 18. k9s
install_with_commands "k9s" '
curl -sS https://webinstall.dev/k9s | bash
'

# =============================================================================
# SHELL
# =============================================================================

# 19. Zsh + Oh My Zsh
install_with_commands "Zsh + Oh My Zsh" '
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s $(which zsh) $USER
'

# 20. Zsh plugins
install_with_commands "Zsh Plugins" '
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
'

# 21. Nerd Fonts
install_with_commands "Nerd Fonts" '
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "FiraCode Nerd Font Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
curl -fLo "FiraCode Nerd Font Bold.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFont-Bold.ttf
curl -fLo "MesloLGS NF Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf
curl -fLo "MesloLGS NF Bold.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Bold/MesloLGSNerdFont-Bold.ttf
fc-cache -fv 2>/dev/null || true
'

# 22. Configure .zshrc
install_with_commands "Zsh Config" '
cat > ~/.zshrc << '\''ZSHRC'\''
# =============================================================================
# Zsh Configuration - Bellows Headless
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git
    docker
    kubectl
    terraform
    aws
    gcloud
    gh
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias k="kubectl"
alias tf="terraform"
alias g="git"
alias ll="ls -la"
alias dps="docker ps"

# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# k9s
export PATH=$PATH:$HOME/.local/bin

# History
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Local customizations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
ZSHRC
'

# =============================================================================
# DATABASE CLIENTS
# =============================================================================

# 22. PostgreSQL client
install_package "PostgreSQL Client" sudo apt install -y postgresql-client

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
log "  - SSH available on port 22"
log ""
log "CLAUDE CODE:"
log "  claude        # Start Claude Code"
log "  claude --help # Show help"
log ""
log "USEFUL COMMANDS:"
log "  docker ps                    # List containers"
log "  kubectl get pods             # List Kubernetes pods"
log "  terraform init               # Initialize Terraform"
log "  az login                     # Login to Azure"
log "  gh auth login                # Login to GitHub"
log ""
log "TO UPDATE ALL PACKAGES:"
log "  wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash"
log ""
log "Log file saved to: $LOG_FILE"
