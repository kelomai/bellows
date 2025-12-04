# 📚 Bellows Documentation

Welcome to the Bellows docs! Everything you need to set up, customize, and extend your workstation automation.

---

## 🗂️ Documentation Index

### 📖 Setup Guides

#### 🍎 macOS

| Script | Description | 📄 Docs |
|--------|-------------|---------|
| 🤖 **LLM Workstation** | Mac Ultra/Pro with 64GB+ RAM - includes Ollama, LM Studio, MLX | [📖 mac-llm-workstation.md](mac-llm-workstation.md) |
| 💻 **Dev Workstation** | MacBook/Mac Mini standard development setup | [📖 mac-dev-workstation.md](mac-dev-workstation.md) |

#### 🪟 Windows 11

| Script | Description | 📄 Docs |
|--------|-------------|---------|
| 👨‍💻 **Dev Workstation** | Full developer environment with LLM tools | [📖 win11-dev-workstation.md](win11-dev-workstation.md) |
| 💼 **Client Workstation** | Business productivity setup (no dev tools) | [📖 win11-client-workstation.md](win11-client-workstation.md) |
| 🧹 **Debloat Windows** | Remove bloatware, telemetry, and consumer features | [📖 win11-debloat.md](win11-debloat.md) |

#### 🐧 Ubuntu

| Script | Description | 📄 Docs |
|--------|-------------|---------|
| 🖥️ **Dev Workstation** | Full desktop development environment with GUI | [📖 ubuntu-dev-workstation.md](ubuntu-dev-workstation.md) |
| 💻 **Headless** | CLI-only for servers, WSL2, Docker containers | [📖 ubuntu-headless.md](ubuntu-headless.md) |

### 🎛️ Customization & Architecture

| Guide | Description |
|-------|-------------|
| 🔧 **[Customization Guide](CUSTOMIZATION.md)** | How to add/remove packages, create custom profiles, and understand the manifest system |

---

## ⚡ Quick Start Commands

**🍎 macOS:**

```bash
# 🤖 LLM Workstation (Mac Ultra 64GB+)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/llm-workstation/install-llm-workstation.sh | bash

# 💻 Dev Workstation (MacBook/Mac Mini)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash
```

**🐧 Ubuntu:**

```bash
# 🖥️ Dev Workstation (Desktop with GUI)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash

# 💻 Headless (CLI only - servers, WSL2, Docker)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash

# 🔄 Update all packages
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash
```

**🪟 Windows 11:**

```powershell
# 👨‍💻 Dev Workstation (Run as Administrator)
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex

# 💼 Client Workstation
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex

# 🧹 Debloat Windows (run before setup)
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/Debloat-Windows.ps1 | iex
```

---

## 🏗️ How Bellows Works

Bellows uses a **manifest-driven architecture**:

```text
📄 packages.json     →    🔧 install script    →    ✅ Configured workstation
   (what to install)        (how to install)         (ready to use!)
```

### 📄 Package Manifests

Each workstation profile has a `packages.json` file that defines:

| Section | What It Contains | Example |
|---------|------------------|---------|
| 🍺 `taps` | Homebrew repositories | `"hashicorp/tap"` |
| 📦 `casks` | GUI applications (grouped) | `"visual-studio-code"` |
| 🧪 `formulae` | CLI tools (grouped) | `"terraform"` |
| 🍎 `mas_apps` | Mac App Store apps | `"497799835": "Xcode"` |
| 💻 `vscode_extensions` | VS Code extensions | `"github.copilot"` |
| 🐚 `zsh_plugins` | oh-my-zsh plugins | `"zsh-users/zsh-autosuggestions"` |
| 🤖 `ollama_models` | LLM models | `"llama3.2:3b"` |

### 🔧 Customization

Want to add or remove packages? See the **[🎛️ Customization Guide](CUSTOMIZATION.md)** for:

- ➕ Adding new packages
- ➖ Removing unwanted tools
- 📁 Creating custom workstation profiles
- 🧪 Testing your changes

---

## ✅ Post-Installation Checklist

After running a setup script, complete these steps:

### 🔄 1. Restart Your Terminal

```bash
# Or source your shell config
source ~/.zshrc    # macOS/Ubuntu
```

### 🚪 2. Log Out & Back In

Required for group memberships (Docker, etc.) to take effect.

### 🔑 3. Authenticate Cloud CLIs

```bash
# Azure
az login

# GitHub CLI
gh auth login

# AWS (if using)
aws configure
```

### 🤖 4. Pull LLM Models (LLM Workstation only)

```bash
# Start Ollama
ollama serve

# Pull recommended models
ollama pull llama3.2:3b          # Fast, small (2GB)
ollama pull qwen2.5-coder:32b    # Best for coding (18GB)
```

---

## 🐛 Troubleshooting

### 🍎 macOS Issues

**Homebrew not found:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**mas (Mac App Store CLI) failing:**

- Ensure you're signed into the App Store app first
- Some apps require previous purchase

### 🪟 Windows Issues

**winget not found:**

```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

**Execution policy error:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 🐧 Ubuntu Issues

**Permission denied:**

```bash
# Don't run as root, script will use sudo when needed
./install-dev-workstation.sh
```

---

## 💬 Getting Help

| Resource | Link |
|----------|------|
| 🐛 **Report a Bug** | [GitHub Issues](https://github.com/kelomai/bellows/issues) |
| 💡 **Request a Feature** | [GitHub Issues](https://github.com/kelomai/bellows/issues/new?template=feature_request.md) |
| 💬 **Ask a Question** | [GitHub Discussions](https://github.com/kelomai/bellows/discussions) |
| 🤝 **Contribute** | [Contributing Guide](../CONTRIBUTING.md) |

---

## 📚 Additional Resources

- 🔥 [Main README](../README.md) - Project overview and quick start
- 🎛️ [Customization Guide](CUSTOMIZATION.md) - Add/remove packages
- 🤝 [Contributing Guide](../CONTRIBUTING.md) - How to contribute
- 📄 [License](../LICENSE) - MIT License
