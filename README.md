# 🔥 Bellows

Automated workstation setup scripts for AI developers and teams. Provision consistent development environments across macOS, Windows, and Ubuntu with a single command.

[![CI](https://github.com/kelomai/bellows/actions/workflows/ci.yml/badge.svg)](https://github.com/kelomai/bellows/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Why Bellows?

- ⚡ **One command setup** - Get a fully configured dev environment in minutes
- 🔄 **Consistent tooling** - Same tools and configs across all platforms
- 🔁 **Idempotent** - Safe to run multiple times
- 🎛️ **Customizable** - JSON manifests and modular scripts
- 📚 **Well documented** - Detailed docs for every tool installed

## 🏃 Quick Start

### 🍎 macOS

```bash
# LLM Workstation (Mac Ultra with 64GB+ RAM)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/llm-workstation/install-llm-workstation.sh | bash

# Developer Workstation (MacBook/Mac Mini)
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash
```

### 🪟 Windows 11

```powershell
# Developer Workstation
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex

# Client Workstation (Business users)
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
```

### 🐧 Ubuntu

```bash
# Developer Workstation (Desktop with GUI)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash

# Headless (CLI only - servers, WSL2, Docker)
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

## 📦 Available Scripts

| Platform | Script | Target | Documentation |
|----------|--------|--------|---------------|
| 🍎 **macOS** | [LLM Workstation](mac-setup/llm-workstation/) | Mac Ultra 64GB+ | [📖 docs](docs/mac-llm-workstation.md) |
| 🍎 **macOS** | [Dev Workstation](mac-setup/dev-workstation/) | MacBook/Mac Mini | [📖 docs](docs/mac-dev-workstation.md) |
| 🪟 **Windows** | [Dev Workstation](win11-setup/dev-workstation/) | Windows 11 | [📖 docs](docs/win11-dev-workstation.md) |
| 🪟 **Windows** | [Client Workstation](win11-setup/client-workstation/) | Windows 11 | [📖 docs](docs/win11-client-workstation.md) |
| 🪟 **Windows** | [Debloat](win11-setup/) | Windows 11 | [📖 docs](docs/win11-debloat.md) |
| 🐧 **Ubuntu** | [Dev Workstation](ubuntu-setup/dev-workstation/) | Ubuntu Desktop | [📖 docs](docs/ubuntu-dev-workstation.md) |
| 🐧 **Ubuntu** | [Headless](ubuntu-setup/headless/) | Ubuntu Server/WSL2 | [📖 docs](docs/ubuntu-headless.md) |

## 🛠️ What Gets Installed

### 👨‍💻 Developer Workstations

- 🐍 **Languages**: Python, Node.js, Go, .NET, Java
- 🔧 **Tools**: VS Code, Git, Docker, GitKraken
- 🏗️ **IaC**: Terraform, Packer
- ☁️ **Cloud**: Azure CLI, AWS CLI, kubectl, Helm
- 🔒 **Security**: GitGuardian (ggshield)
- 🐚 **Shell**: oh-my-zsh, oh-my-posh, Nerd Fonts

### 🤖 LLM Workstations (macOS)

Everything above, plus:

- 🦙 **Ollama** - Local LLM runner with OpenAI-compatible API
- 🎨 **LM Studio** - GUI for model management
- ⚡ **MLX** - Apple Silicon native inference
- 🌐 **Open WebUI** - ChatGPT-like interface

### 💻 Headless (Ubuntu)

CLI-only setup optimized for:

- 🤖 **Claude Code** - AI-assisted development
- 🖥️ Remote servers and VMs
- 🪟 WSL2 on Windows
- 🐳 Docker containers

## 🏗️ How It Works

Bellows uses a **manifest-driven architecture** that separates *what* to install from *how* to install it:

```text
📄 packages.json          →       🔧 install script        →       ✅ Ready!
(Define your tools)              (Automated setup)                 (Start coding)
```

### 📄 Package Manifests

Each workstation has a `packages.json` file that defines everything to install:

```json
{
  "casks": {
    "browsers": ["firefox", "google-chrome"],
    "development": ["visual-studio-code", "docker-desktop"],
    "ai_llm": ["ollama", "lm-studio"]
  },
  "formulae": {
    "languages": ["python@3.13", "node", "go"],
    "iac": ["terraform", "packer"]
  },
  "vscode_extensions": ["github.copilot", "ms-python.python"],
  "ollama_models": {
    "default": ["llama3.2:3b", "qwen2.5-coder:32b"]
  }
}
```

### 🎛️ Customization

Want to add or remove tools? It's easy:

- ➕ **Add a package**: Add it to the appropriate category in `packages.json`
- ➖ **Remove a package**: Delete the line from `packages.json`
- 📁 **Create a profile**: Copy a folder and customize the manifest

👉 **[See the full Customization Guide →](docs/CUSTOMIZATION.md)**

## 📁 Project Structure

```text
bellows/
├── mac-setup/
│   ├── llm-workstation/        # 🤖 Mac Ultra with LLM tools
│   │   ├── install-*.sh        #    └── Setup script
│   │   └── packages.json       #    └── Package manifest
│   └── dev-workstation/        # 💻 Standard MacBook setup
│       ├── install-*.sh
│       └── packages.json
├── win11-setup/
│   ├── dev-workstation/        # 👨‍💻 Windows developer setup
│   │   ├── Install-*.ps1       #    └── Setup script
│   │   └── packages.json       #    └── Package manifest
│   ├── client-workstation/     # 💼 Windows business user setup
│   │   ├── Install-*.ps1       #    └── Setup script
│   │   └── packages.json       #    └── Package manifest
│   └── Debloat-Windows.ps1     # 🧹 Remove bloatware
├── ubuntu-setup/
│   ├── dev-workstation/        # 🖥️ Ubuntu Desktop setup
│   │   ├── install-*.sh        #    └── Setup script
│   │   └── packages.json       #    └── Package manifest
│   ├── headless/               # 💻 CLI-only setup
│   │   ├── install-*.sh        #    └── Setup script
│   │   └── packages.json       #    └── Package manifest
│   └── update.sh               # 🔄 Update all packages
├── cli/                        # 🎨 Shell themes (oh-my-posh)
├── docs/                       # 📚 Detailed documentation
└── tests/                      # 🧪 Script validation tests
```

## 📚 Documentation

Detailed documentation for each script is available in the [docs/](docs/) folder:

### 🎛️ Guides

- 🔧 [Customization Guide](docs/CUSTOMIZATION.md) - **Add/remove packages, create custom profiles**
- 🤝 [Contributing Guide](CONTRIBUTING.md) - How to contribute to Bellows

### 📖 Setup Docs

- 🍎 [Mac LLM Workstation](docs/mac-llm-workstation.md) - Complete tool list and LLM setup
- 🍎 [Mac Dev Workstation](docs/mac-dev-workstation.md) - Standard dev environment
- 🐧 [Ubuntu Dev Workstation](docs/ubuntu-dev-workstation.md) - Desktop setup with GUI tools
- 🐧 [Ubuntu Headless](docs/ubuntu-headless.md) - CLI-only for Claude Code
- 🪟 [Windows Dev Workstation](docs/win11-dev-workstation.md) - Full developer setup
- 🪟 [Windows Client Workstation](docs/win11-client-workstation.md) - Business productivity
- 🪟 [Windows Debloat](docs/win11-debloat.md) - Remove bloatware and telemetry

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a PR.

### Quick Contribution Steps

1. 🍴 **Fork** the repository
2. 🌿 **Create** a feature branch: `git checkout -b feature/my-feature`
3. ✏️ **Make** your changes following our [coding standards](CONTRIBUTING.md#coding-standards)
4. 🧪 **Test** your changes: `./tests/test-bash-scripts.sh`
5. 💾 **Commit** with a clear message: `git commit -m "Add: description"`
6. 📤 **Push** to your fork: `git push origin feature/my-feature`
7. 🔀 **Open** a Pull Request

### 🐛 Reporting Issues

Found a bug? Have a feature request? [Open an issue](https://github.com/kelomai/bellows/issues/new/choose).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/kelomai/bellows/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/kelomai/bellows/discussions)
- 📚 **Documentation**: [docs/](docs/)
