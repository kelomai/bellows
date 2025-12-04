# 📚 Bellows Documentation

Comprehensive guides for all Bellows workstation setup scripts.

## 📖 Script Documentation

### 🍎 macOS

| Script | Description | Documentation |
|--------|-------------|---------------|
| **LLM Workstation** | Mac Ultra/Pro with local LLM stack | [mac-llm-workstation.md](mac-llm-workstation.md) |
| **Dev Workstation** | MacBook/Mac Mini standard dev setup | [mac-dev-workstation.md](mac-dev-workstation.md) |

### 🪟 Windows 11

| Script | Description | Documentation |
|--------|-------------|---------------|
| **Dev Workstation** | Full developer environment | [win11-dev-workstation.md](win11-dev-workstation.md) |
| **Client Workstation** | Business productivity setup | [win11-client-workstation.md](win11-client-workstation.md) |
| **Debloat Windows** | Remove bloatware and telemetry | [win11-debloat.md](win11-debloat.md) |

### 🐧 Ubuntu

| Script | Description | Documentation |
|--------|-------------|---------------|
| **Dev Workstation** | Full desktop development environment | [ubuntu-dev-workstation.md](ubuntu-dev-workstation.md) |
| **Headless** | CLI-only for servers/WSL2/Docker | [ubuntu-headless.md](ubuntu-headless.md) |

## ⚡ Quick Reference

### 📥 Installation Commands

```bash
# macOS LLM Workstation (Mac Ultra 64GB+)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/llm-workstation/install-llm-workstation.sh | bash

# macOS Dev Workstation (MacBook)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash

# Ubuntu Dev Workstation (Desktop)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash

# Ubuntu Headless (CLI only)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

```powershell
# Windows 11 Dev Workstation
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex

# Windows 11 Client Workstation
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
```

## ✅ Common Post-Installation Steps

1. 🔄 **Restart your terminal** or source your shell config
2. 🚪 **Log out and back in** for group memberships (Docker, etc.)
3. 🔑 **Authenticate cloud CLIs**: `az login`, `aws configure`, `gh auth login`

## 💬 Getting Help

- 🐛 [GitHub Issues](https://github.com/kelomai/bellows/issues) - Report bugs or request features
- 🤝 [Contributing Guide](../CONTRIBUTING.md) - How to contribute to Bellows
