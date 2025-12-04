# 🍎 macOS Workstation Setup

Automated setup scripts for macOS development workstations.

> 📖 **Full Documentation:** See [docs/mac-llm-workstation.md](../docs/mac-llm-workstation.md) and [docs/mac-dev-workstation.md](../docs/mac-dev-workstation.md) for detailed tool lists and usage instructions.

## 💻 Workstation Types

| Type | Target Machine | Description |
|------|----------------|-------------|
| **[LLM Workstation](llm-workstation/)** | Mac Studio Ultra / Mac Pro (64GB+ RAM) | Full development environment + local LLM stack |
| **[Dev Workstation](dev-workstation/)** | MacBook Pro / MacBook Air / Mac Mini | Standard development environment |

---

## 🚀 Quick Start

### 🤖 LLM Workstation (Mac Ultra with 64GB+ RAM)

```bash
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/llm-workstation/install-llm-workstation.sh | bash
```

### 👨‍💻 Dev Workstation (MacBook/Standard Mac)

```bash
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash
```

---

## 📦 What's Included

### ⚙️ Both Workstations

| Category | Tools |
|----------|-------|
| **Package Manager** | Homebrew |
| **Browsers** | Firefox, Chrome, Microsoft Edge |
| **Code Editors** | VS Code |
| **Git Tools** | GitHub Desktop, GitKraken |
| **Terminals** | Warp |
| **Containers** | Docker Desktop |
| **Languages** | Python 3.13, Node.js, Go, .NET, OpenJDK 21 |
| **IaC** | Terraform, Packer |
| **Cloud** | Azure CLI, Azure Storage Explorer, kubectl, kubelogin |
| **Security** | GitGuardian (ggshield) |
| **Shell** | oh-my-zsh + oh-my-posh |
| **Fonts** | FiraCode, Meslo, JetBrains Mono (Nerd Fonts) |

### 🧠 LLM Workstation Only

| Tool | Description |
|------|-------------|
| **Ollama** | CLI + OpenAI-compatible API |
| **LM Studio** | GUI for model management |
| **Jan** | Privacy-focused chat app |
| **MLX** | Apple Silicon native inference |
| **llama.cpp** | GGUF model inference |
| **Open WebUI** | ChatGPT-like web interface |
| **Claude/ChatGPT** | Official desktop apps |

---

## 📂 Directory Structure

```text
mac-setup/
├── README.md                           # This file
├── llm-workstation/
│   ├── install-llm-workstation.sh      # LLM workstation setup
│   └── packages.json                   # Package manifest (with LLM tools)
└── dev-workstation/
    ├── install-dev-workstation.sh      # Dev workstation setup
    └── packages.json                   # Package manifest (no LLM tools)
```

---

## ⚡ Command Line Options

Both scripts support:

```bash
./install-*.sh --dry-run      # Preview changes without executing
./install-*.sh --shells-only  # Only configure shells (zsh + pwsh)
```

---

## 🎨 Customization

Package lists are defined in `packages.json` files. To customize:

```bash
# Clone the repo
git clone https://github.com/kelomai/bellows.git
cd bellows/mac-setup/dev-workstation

# Edit packages.json to add/remove packages
code packages.json

# Run the script (it will use local packages.json)
./install-dev-workstation.sh
```

Remote execution (`curl | bash`) fetches packages.json from GitHub automatically.

---

## 🐚 Shell Configuration

Both workstations get the same shell experience:

- **oh-my-zsh** with plugins (git, docker, kubectl, terraform, azure, etc.)
- **oh-my-posh** with Bellows theme
- **Nerd Fonts** for icons (FiraCode, Meslo, JetBrains Mono)

Theme files are pulled from: `cli/bellows.omp.json`

---

## ✅ Post-Install

1. 🔄 **Restart your terminal** (or `source ~/.zshrc`)
2. 🚪 **Log out and back in** for Docker group to take effect
3. 🔑 **Sign into services**: `az login`, `gh auth login`, `docker login`

---

## 🔧 Troubleshooting

### 🍺 Homebrew not found after install

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

### 🐳 Docker permission denied

```bash
# Log out and back in, or run:
newgrp docker
```

### 🎨 oh-my-posh icons not showing

Ensure your terminal is using a Nerd Font (MesloLGS, FiraCode, JetBrains Mono).
