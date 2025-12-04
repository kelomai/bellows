# 🐧 Ubuntu Workstation Setup

Automated setup scripts for Ubuntu development environments.

> 📖 **Full Documentation:** See [docs/ubuntu-dev-workstation.md](../docs/ubuntu-dev-workstation.md) and [docs/ubuntu-headless.md](../docs/ubuntu-headless.md) for detailed tool lists and usage instructions.

## 💻 Workstation Types

| Type | Target | Description |
|------|--------|-------------|
| **[Dev Workstation](dev-workstation/)** | Ubuntu Desktop on Proxmox VM | Full GUI development environment |
| **[Headless](headless/)** | Ubuntu Server / WSL2 / Docker | CLI-only for coding with Claude |

---

## 🚀 Quick Start

### 🖥️ Dev Workstation (Ubuntu Desktop with GUI)

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash
```

### 🤖 Headless (CLI Only)

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

---

## 📦 What's Included

### ⚙️ Both Environments

| Category | Tools |
|----------|-------|
| **Core** | Git, curl, wget, build-essential |
| **Languages** | Python 3, Node.js 22, Go 1.23, .NET SDK (latest) |
| **Claude Code** | AI coding assistant |
| **Cloud CLIs** | Azure CLI, AWS CLI, Google Cloud CLI, GitHub CLI |
| **DevOps** | Docker, Terraform, kubectl, Helm, k9s |
| **Shell** | Zsh, Oh My Zsh |
| **Utilities** | jq, htop, tree, ripgrep, tmux |
| **Fonts** | FiraCode Nerd Font, MesloLGS Nerd Font |
| **Networking** | dig, nslookup, whois, traceroute, mtr, nmap |
| **Database** | PostgreSQL client (psql) |
| **Remote** | SSH server |

### 🖥️ Dev Workstation Only (GUI)

| Category | Tools |
|----------|-------|
| **Browser** | Microsoft Edge |
| **Code Editor** | VS Code |
| **Git GUI** | GitKraken |
| **API Testing** | Postman |
| **Database GUI** | DBeaver |
| **Azure** | Azure Storage Explorer, PowerShell + Az Module |
| **Remote Desktop** | xrdp (port 3389) |
| **Proxmox** | qemu-guest-agent, spice-vdagent |
| **Shell Theme** | Oh My Posh |

---

## 📂 Directory Structure

```text
ubuntu-setup/
├── README.md                              # This file
├── update.sh                              # Update script (common)
├── dev-workstation/
│   └── install-dev-workstation.sh         # Full desktop setup
└── headless/
    └── install-headless.sh                # CLI-only setup
```

---

## 🔄 Updating Packages

Both workstation types can be updated with:

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash
```

This updates:

- APT packages
- Snap packages (dev-workstation only)
- NPM global packages (Claude Code)
- Helm
- k9s

---

## ✅ Post-Installation

**⚙️ Both Environments:**

1. 🚪 **Log out and back in** - Required for Docker group and Zsh shell
2. 🔐 **SSH access** - Available on port 22

**🖥️ Dev Workstation Only:**

1. 🖥️ **RDP access** - Available on port 3389
2. 🎨 **Configure terminal font** - Set to 'FiraCode Nerd Font' for icons
3. 🔑 **Install 1Password browser extension** - Manual install in Edge

---

## 📋 Common Commands

### 🤖 Claude Code

```bash
claude                     # Start Claude Code
claude --help              # Show help
```

### 🐳 Docker

```bash
docker ps                  # List running containers
docker-compose up -d       # Start compose stack
```

### ☸️ Kubernetes

```bash
kubectl get pods           # List pods
k9s                        # Launch k9s TUI
helm list                  # List Helm releases
```

### ☁️ Cloud CLIs

```bash
az login                   # Login to Azure
aws configure              # Configure AWS
gcloud init                # Initialize Google Cloud
gh auth login              # Login to GitHub
```

### 🏗️ Terraform

```bash
terraform init             # Initialize
terraform plan             # Preview changes
terraform apply            # Apply changes
```

---

## 🔧 Troubleshooting

### 🐳 Docker permission denied

```bash
# Log out and back in, or run:
newgrp docker
```

### 📦 Snap apps not found (dev-workstation)

```bash
source /etc/profile.d/apps-bin-path.sh
```

### 🔑 GPG key errors on apt update

```bash
# Re-run the key import for the failing repo
# Check /etc/apt/sources.list.d/ for repo files
```

### 📋 Proxmox clipboard not working (dev-workstation)

```bash
sudo systemctl restart spice-vdagent
```
