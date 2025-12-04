#!/bin/bash
# =============================================================================
# install-dev-workstation.sh - macOS Developer Workstation Setup (MacBook)
# =============================================================================
#
# Automated setup script for a macOS development workstation.
# Optimized for software development on MacBook Pro/Air.
#
# Target: MacBook Pro / MacBook Air / Mac Mini
#
# Includes:
#   - Development tools (VS Code, Git, Docker, etc.)
#   - Programming languages (Python, Node.js, Go, .NET, Java)
#   - Infrastructure as Code (Terraform, Packer)
#   - Cloud tools (Azure CLI, kubectl, Helm)
#   - Shell customization (oh-my-zsh, oh-my-posh)
#
# Note: For LLM workstations (Mac Ultra with 64GB+ RAM), use llm-workstation instead.
#
# Usage:
#   ./install-dev-workstation.sh                        # Run full setup
#   ./install-dev-workstation.sh --dry-run              # Preview without changes
#   ./install-dev-workstation.sh --shells-only          # Only configure shells
#   ./install-dev-workstation.sh --repo <org/repo>      # Use forked repo (default: kelomai/bellows)
#   ./install-dev-workstation.sh --branch <branch>      # Use specific branch (default: main)
#
# Remote:
#   curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash
#
# Author: Bellows
# License: MIT
# =============================================================================

set -e

# =============================================================================
# COMMAND LINE FLAGS
# =============================================================================
DRY_RUN=false
SHELLS_ONLY=false
GITHUB_REPO="kelomai/bellows"
BRANCH="main"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --shells-only)
            SHELLS_ONLY=true
            shift
            ;;
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

if $DRY_RUN; then
    echo "============================================="
    echo "  DRY RUN MODE - No changes will be made"
    echo "============================================="
    echo ""
fi

# =============================================================================
# SUDO CREDENTIAL CACHING
# =============================================================================
# Ask for sudo password upfront and keep it alive
if ! $DRY_RUN; then
    echo "This script requires administrator privileges for some operations."
    sudo -v

    # Keep sudo alive in the background (refresh every 50 seconds)
    SUDO_KEEPALIVE_PID=
    (
        while true; do
            sudo -n true 2>/dev/null
            sleep 50
        done
    ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
fi

# Skip Gatekeeper quarantine prompts for Homebrew casks
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Helper function to run or simulate commands
run_cmd() {
    if $DRY_RUN; then
        echo "[DRY RUN] Would execute: $*"
    else
        "$@"
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Starting Mac Development Workstation Setup..."
log_info "Architecture: $(uname -m)"

# =============================================================================
# PACKAGE MANIFEST
# =============================================================================
GITHUB_RAW_BASE="https://raw.githubusercontent.com/${GITHUB_REPO}/${BRANCH}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || pwd)"
PACKAGES_JSON=""

# Bootstrap jq - must be installed before we can parse the manifest
bootstrap_jq() {
    if command -v jq &>/dev/null; then
        log_success "jq already installed"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would install jq for JSON parsing"
        return 0
    fi

    log_info "Installing jq (required for package manifest)..."
    brew install jq || {
        log_error "Failed to install jq - cannot parse package manifest"
        exit 1
    }
    log_success "jq installed"
}

# Load package manifest from local file or GitHub
load_packages() {
    # Try local file first (for local execution)
    if [[ -f "$SCRIPT_DIR/packages.json" ]]; then
        PACKAGES_JSON=$(cat "$SCRIPT_DIR/packages.json")
        log_success "Loaded packages.json from local file"
        return 0
    fi

    # Try current directory
    if [[ -f "./packages.json" ]]; then
        PACKAGES_JSON=$(cat "./packages.json")
        log_success "Loaded packages.json from current directory"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would download packages.json from GitHub"
        return 0
    fi

    # Download from GitHub
    log_info "Downloading packages.json from GitHub..."
    PACKAGES_JSON=$(curl -fsSL "$GITHUB_RAW_BASE/mac-setup/dev-workstation/packages.json") || {
        log_error "Failed to download packages.json"
        exit 1
    }
    log_success "Downloaded packages.json from GitHub"
}

# Helper to get flat array of packages from nested JSON categories
get_packages() {
    local section="$1"
    if [[ -z "$PACKAGES_JSON" ]]; then
        echo ""
        return
    fi
    # Flatten nested objects into a simple array
    echo "$PACKAGES_JSON" | jq -r "
        .$section |
        if type == \"object\" then
            [.[] | if type == \"array\" then .[] else . end] | .[]
        elif type == \"array\" then
            .[]
        else
            empty
        end
    " 2>/dev/null
}

# Helper to get key-value pairs (for mas_apps, edge_extensions)
get_package_map() {
    local section="$1"
    if [[ -z "$PACKAGES_JSON" ]]; then
        echo ""
        return
    fi
    echo "$PACKAGES_JSON" | jq -r ".$section | to_entries | .[] | \"\(.key)|\(.value)\"" 2>/dev/null
}

# =============================================================================
# HOMEBREW INSTALLATION
# =============================================================================
install_homebrew() {
    # Determine Homebrew path based on architecture
    local brew_bin
    if [[ $(uname -m) == 'arm64' ]]; then
        brew_bin="/opt/homebrew/bin/brew"
    else
        brew_bin="/usr/local/bin/brew"
    fi

    # Check if Homebrew binary exists (may not be in PATH yet)
    if [[ -x "$brew_bin" ]]; then
        # Homebrew exists but may not be in PATH - add it for this session
        if ! command -v brew &>/dev/null; then
            log_info "Homebrew found at $brew_bin, adding to PATH..."
            eval "$($brew_bin shellenv)"
        fi
        log_success "Homebrew already installed at $brew_bin"
    elif ! command -v brew &>/dev/null; then
        # Homebrew not installed
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install Homebrew"
            return
        fi
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH based on architecture
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
            log_success "Homebrew installed at /opt/homebrew (Apple Silicon)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
            log_success "Homebrew installed at /usr/local (Intel)"
        fi
        return  # Fresh install, no need to update
    else
        log_success "Homebrew already installed at $(which brew)"
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would check if Homebrew needs updating"
        return
    fi

    # Check when Homebrew was last updated (look at .git FETCH_HEAD timestamp)
    local brew_repo
    if [[ $(uname -m) == 'arm64' ]]; then
        brew_repo="/opt/homebrew"
    else
        brew_repo="/usr/local/Homebrew"
    fi

    local last_update=0
    local fetch_head="$brew_repo/.git/FETCH_HEAD"
    if [[ -f "$fetch_head" ]]; then
        last_update=$(stat -f %m "$fetch_head" 2>/dev/null || echo 0)
    fi

    local now
    now=$(date +%s)
    local age_hours=$(( (now - last_update) / 3600 ))

    if [[ $age_hours -gt 24 ]]; then
        log_info "Homebrew last updated ${age_hours} hours ago, updating..."
        brew update
    else
        log_success "Homebrew updated recently (${age_hours} hours ago), skipping update"
    fi
}

# =============================================================================
# EDGE EXTENSIONS INSTALLATION (via managed preferences)
# =============================================================================
install_edge_extensions() {
    log_info "Configuring Microsoft Edge extensions..."

    local edge_plist_dir="$HOME/Library/Managed Preferences"
    local edge_plist="$edge_plist_dir/com.microsoft.Edge.plist"

    # Create directory if needed
    mkdir -p "$edge_plist_dir"

    # Build plist content from manifest
    local plist_entries=""
    while IFS='|' read -r ext_id ext_name; do
        [[ -z "$ext_id" ]] && continue
        plist_entries+="        <string>${ext_id}</string>\n"
    done < <(get_package_map "edge_extensions")

    # Create/update Edge preferences plist
    cat > "/tmp/edge_extensions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ExtensionInstallForcelist</key>
    <array>
$(echo -e "$plist_entries")    </array>
</dict>
</plist>
EOF

    # Copy to managed preferences (may need sudo for system-wide)
    if [ -w "$edge_plist_dir" ]; then
        cp "/tmp/edge_extensions.plist" "$edge_plist"
        log_success "Edge extensions configured"
    else
        log_info "To install Edge extensions system-wide, run:"
        echo "  sudo cp /tmp/edge_extensions.plist '$edge_plist'"
    fi

    echo ""
    log_info "Edge extensions will be installed on next Edge launch:"
    while IFS='|' read -r ext_id ext_name; do
        [[ -z "$ext_id" ]] && continue
        echo "  - $ext_name ($ext_id)"
    done < <(get_package_map "edge_extensions")
    echo ""
    log_info "Or install manually from: edge://extensions"
}

# =============================================================================
# PYTHON ENVIRONMENT SETUP
# =============================================================================
setup_python() {
    log_info "Setting up Python environment..."

    # Ensure pipx is available
    if command -v pipx &>/dev/null; then
        pipx ensurepath

        # Install Python CLI tools via pipx from manifest
        while IFS= read -r tool; do
            [[ -z "$tool" ]] && continue
            if ! pipx list | grep -q "$tool"; then
                log_info "Installing $tool via pipx..."
                pipx install "$tool" || log_warn "Failed to install $tool"
            else
                log_success "$tool already installed"
            fi
        done < <(get_packages "pipx_packages")
    fi

    # Setup pyenv if installed
    if command -v pyenv &>/dev/null; then
        if ! grep -q 'pyenv init' ~/.zshrc 2>/dev/null; then
            log_info "Configuring pyenv in ~/.zshrc..."
            cat >> ~/.zshrc << 'EOF'

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
            log_success "Pyenv configured"
        fi
    fi
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh for pwsh and zsh)
# =============================================================================
configure_powershell() {
    log_info "Configuring PowerShell with oh-my-posh..."

    # Get the actual PowerShell profile path from PowerShell itself
    local pwsh_profile
    pwsh_profile=$(pwsh -NoProfile -Command 'Write-Host $PROFILE' 2>/dev/null)

    if [ -z "$pwsh_profile" ]; then
        log_warn "Could not determine PowerShell profile path"
        return
    fi

    local pwsh_profile_dir
    pwsh_profile_dir=$(dirname "$pwsh_profile")
    local omp_config_dir="$HOME/.config/oh-my-posh"
    local omp_config="$omp_config_dir/bellows.omp.json"

    log_info "PowerShell profile path: $pwsh_profile"

    mkdir -p "$pwsh_profile_dir"
    mkdir -p "$omp_config_dir"

    # Download oh-my-posh theme from GitHub
    log_info "Downloading oh-my-posh theme..."
    curl -fsSL "$GITHUB_RAW_BASE/cli/bellows.omp.json" -o "$omp_config" || {
        log_warn "Failed to download oh-my-posh theme"
        return
    }

    # Create/update PowerShell profile
    if [ -f "$pwsh_profile" ]; then
        # Check if already configured
        if grep -q "oh-my-posh init pwsh" "$pwsh_profile"; then
            log_success "PowerShell already configured with oh-my-posh"
        else
            # Append to existing profile
            cat >> "$pwsh_profile" << 'EOF'

# oh-my-posh prompt (Bellows theme)
oh-my-posh init pwsh --config "$HOME/.config/oh-my-posh/bellows.omp.json" | Invoke-Expression
EOF
            log_success "Added oh-my-posh to PowerShell profile"
        fi
    else
        # Create new profile
        cat > "$pwsh_profile" << 'EOF'
# PowerShell Profile - Bellows Dev Workstation
# ===========================================

# oh-my-posh prompt (Bellows theme)
oh-my-posh init pwsh --config "$HOME/.config/oh-my-posh/bellows.omp.json" | Invoke-Expression

# Aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform
Set-Alias -Name g -Value git

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
EOF
        log_success "Created PowerShell profile at $pwsh_profile"
    fi
}

install_oh_my_zsh() {
    log_info "Installing oh-my-zsh..."

    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_success "oh-my-zsh already installed"
        return 0
    fi

    # Install oh-my-zsh (unattended)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        log_warn "Failed to install oh-my-zsh"
        return 1
    }

    log_success "oh-my-zsh installed"
}

install_zsh_plugins() {
    log_info "Installing zsh plugins from manifest..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Install plugins from manifest (format: "owner/repo")
    while IFS= read -r plugin; do
        [[ -z "$plugin" ]] && continue
        local plugin_name="${plugin##*/}"  # Extract repo name from "owner/repo"
        local plugin_dir="$zsh_custom/plugins/$plugin_name"

        if [ ! -d "$plugin_dir" ]; then
            log_info "Installing $plugin_name..."
            git clone "https://github.com/$plugin" "$plugin_dir" 2>/dev/null
            log_success "Installed $plugin_name"
        else
            log_success "$plugin_name already installed"
        fi
    done < <(get_packages "zsh_plugins")
}

configure_zsh() {
    log_info "Configuring Zsh with oh-my-zsh + oh-my-posh..."

    local zshrc="$HOME/.zshrc"
    local omp_config_dir="$HOME/.config/oh-my-posh"
    local omp_config="$omp_config_dir/bellows.omp.json"

    # Install oh-my-zsh first
    install_oh_my_zsh
    install_zsh_plugins

    mkdir -p "$omp_config_dir"

    # Download oh-my-posh theme
    log_info "Downloading oh-my-posh theme..."
    curl -fsSL "$GITHUB_RAW_BASE/cli/bellows.omp.json" -o "$omp_config" || {
        log_warn "Failed to download oh-my-posh theme"
    }

    # Backup existing .zshrc if it exists
    if [ -f "$zshrc" ]; then
        cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backed up existing .zshrc"
    fi

    # Create new .zshrc with oh-my-zsh + oh-my-posh
    cat > "$zshrc" << 'EOF'
# =============================================================================
# Zsh Configuration - Bellows Dev Workstation
# oh-my-zsh + oh-my-posh
# =============================================================================

# Homebrew (must be before oh-my-zsh)
if [[ $(uname -m) == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# oh-my-zsh Configuration
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Don't use oh-my-zsh theme (we use oh-my-posh instead)
ZSH_THEME=""

# Plugins (order matters for some)
plugins=(
    git                    # Git aliases and completions
    docker                 # Docker completions
    docker-compose         # Docker Compose completions
    kubectl                # Kubectl completions and aliases
    terraform              # Terraform completions
    azure                  # Azure CLI completions
    brew                   # Homebrew completions
    node                   # Node/npm completions
    python                 # Python completions
    pip                    # Pip completions
    golang                 # Go completions
    dotnet                 # .NET completions
    vscode                 # VS Code aliases
    gh                     # GitHub CLI completions
    zsh-autosuggestions    # Fish-like autosuggestions
    zsh-syntax-highlighting # Syntax highlighting
    zsh-completions        # Additional completions
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# oh-my-posh Prompt (Bellows theme)
# -----------------------------------------------------------------------------
if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/bellows.omp.json)"
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias k="kubectl"
alias tf="terraform"
alias g="git"
alias ll="ls -la"
alias la="ls -A"
alias cls="clear"

# Docker aliases
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"

# Git aliases (in addition to oh-my-zsh git plugin)
alias gst="git status"
alias gco="git checkout"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^R' history-incremental-search-backward

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="code --wait"
export VISUAL="code --wait"

# pipx (Python CLI tools)
export PATH="$HOME/.local/bin:$PATH"

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# -----------------------------------------------------------------------------
# Local customizations (if exists)
# -----------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF

    log_success "Created .zshrc with oh-my-zsh + oh-my-posh"
    echo ""
    echo "oh-my-zsh plugins enabled:"
    echo "  git, docker, kubectl, terraform, azure, brew, node, python, golang, dotnet, gh"
    echo "  + zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions"
}

configure_terminal_font() {
    log_info "Configuring Terminal.app font..."

    # Check if MesloLGS Nerd Font is installed
    if ! fc-list | grep -qi "MesloLG.*Nerd"; then
        log_warn "Nerd Font not found, skipping Terminal.app font configuration"
        return
    fi

    # Create a custom terminal profile with Nerd Font
    # Using MesloLGS NF which is commonly used with oh-my-posh/powerlevel10k
    local font_name="MesloLGS Nerd Font"
    local font_size="14"

    # Set font for the default profile
    osascript <<EOF
tell application "Terminal"
    set font name of settings set "Basic" to "$font_name"
    set font size of settings set "Basic" to $font_size
end tell
EOF

    # Also try to set for current default profile via defaults
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"

    log_success "Terminal.app configured with $font_name ($font_size pt)"
    log_info "Restart Terminal.app for changes to take effect"
}

configure_shells() {
    log_info "Configuring shell prompts..."

    # Check if oh-my-posh is installed
    if ! command -v oh-my-posh &>/dev/null; then
        log_warn "oh-my-posh not installed, skipping shell configuration"
        return
    fi

    configure_zsh

    # Only configure PowerShell if installed
    if command -v pwsh &>/dev/null; then
        configure_powershell
    else
        log_info "PowerShell not installed, skipping pwsh configuration"
    fi

    # Configure terminal font for Nerd Font icons
    configure_terminal_font

    log_success "Shell configuration complete!"
    echo ""
    echo "Theme downloaded to: ~/.config/oh-my-posh/bellows.omp.json"
    echo "Restart your terminal or run: source ~/.zshrc"
}

# =============================================================================
# VSCODE EXTENSIONS
# =============================================================================
install_vscode_extensions() {
    if command -v code &>/dev/null; then
        log_info "Installing VS Code extensions..."

        while IFS= read -r ext; do
            [[ -z "$ext" ]] && continue
            code --install-extension "$ext" --force 2>/dev/null || log_warn "Failed to install $ext"
        done < <(get_packages "vscode_extensions")

        log_success "VS Code extensions installed"
    else
        log_warn "VS Code CLI not found, skipping extensions"
    fi
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================
main() {
    # Handle --shells-only flag
    if $SHELLS_ONLY; then
        echo ""
        echo "============================================="
        echo "  Shell Configuration Only"
        echo "============================================="
        echo ""

        # Need to load manifest for zsh plugins
        if command -v jq &>/dev/null; then
            load_packages
        else
            log_warn "jq not installed - zsh plugins from manifest won't be installed"
        fi

        configure_shells
        echo ""
        log_success "Shell configuration complete!"
        echo "Restart your terminal or run: source ~/.zshrc"
        return
    fi

    echo ""
    echo "============================================="
    echo "  Mac Developer Workstation Setup"
    echo "============================================="
    echo ""

    # Install Homebrew first
    install_homebrew

    # Bootstrap jq (required to parse packages.json)
    bootstrap_jq

    # Load package manifest
    load_packages

    # Add taps from manifest
    log_info "Adding Homebrew taps..."
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would tap: $tap"
        else
            brew tap "$tap" 2>/dev/null || true
        fi
    done < <(get_packages "taps")

    # Install casks (GUI apps) from manifest
    log_info "Installing GUI applications..."
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install cask: $cask"
        elif brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            brew install --cask "$cask" || log_warn "Failed to install $cask"
        fi
    done < <(get_packages "casks")

    # Install formulae (CLI tools) from manifest
    # Auto-accept Microsoft EULA for SQL Server tools
    export HOMEBREW_ACCEPT_EULA=Y
    log_info "Installing CLI tools..."

    # Unlink conflicting sqlcmd if present (conflicts with mssql-tools18)
    if brew list sqlcmd &>/dev/null 2>&1; then
        log_info "Unlinking sqlcmd (conflicts with mssql-tools18)..."
        brew unlink sqlcmd 2>/dev/null || true
    fi

    while IFS= read -r formula; do
        [[ -z "$formula" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install formula: $formula"
        elif brew list "$formula" &>/dev/null; then
            log_success "$formula already installed"
        else
            # Handle mssql-tools18 link conflict
            if [[ "$formula" == *"mssql-tools18"* ]]; then
                brew install "$formula" && brew link --overwrite "$formula" 2>/dev/null || log_warn "Failed to install $formula"
            else
                brew install "$formula" || log_warn "Failed to install $formula"
            fi
        fi
    done < <(get_packages "formulae")

    # Setup Python environment
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Python (pipx, pyenv)"
    else
        setup_python
    fi

    # Configure shell prompts (oh-my-posh)
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Configure shell prompts?"
        log_info "[DRY RUN] Would install oh-my-zsh + plugins"
        log_info "[DRY RUN] Would download oh-my-posh theme from GitHub"
        log_info "[DRY RUN] Would create ~/.zshrc and PowerShell profile"
    else
        read -p "Configure shell prompts (zsh + pwsh with oh-my-posh)? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            configure_shells
        fi
    fi

    # Install VS Code extensions
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Install VS Code extensions?"
    else
        read -p "Install VS Code extensions? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_vscode_extensions
        fi
    fi

    # Install Edge extensions
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Configure Edge extensions?"
    else
        read -p "Configure Microsoft Edge extensions? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_edge_extensions
        fi
    fi

    # Cleanup
    if ! $DRY_RUN; then
        log_info "Cleaning up..."
        brew cleanup
    fi

    echo ""
    echo "============================================="
    log_success "Setup complete!"
    echo "============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Log out and back in for Docker group to take effect"
    echo ""
    echo "Useful commands:"
    echo "  docker ps                        # List running containers"
    echo "  kubectl get pods                 # List Kubernetes pods"
    echo "  terraform init                   # Initialize Terraform"
    echo "  az login                         # Login to Azure CLI"
    echo "  gh auth login                    # Login to GitHub CLI"
    echo ""
    echo "Python environment:"
    echo "  pyenv install 3.13               # Install Python version"
    echo "  pyenv global 3.13                # Set global version"
    echo "  poetry new myproject             # Create new project"
    echo ""
}

# Run main function
main "$@"
