# macOS LLM Workstation

Full development environment with local LLM inference stack for Mac Studio Ultra / Mac Pro with 64GB+ unified memory.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/llm-workstation/install-llm-workstation.sh | bash
```

### Command Line Options

```bash
./install-llm-workstation.sh              # Full installation
./install-llm-workstation.sh --dry-run    # Preview without changes
./install-llm-workstation.sh --skip-mas   # Skip Mac App Store apps
./install-llm-workstation.sh --shells-only # Only configure shells
```

## Tools Installed

### Package Manager

| Tool | Description | Usage |
|------|-------------|-------|
| **Homebrew** | macOS package manager | `brew install <package>` |

### Browsers

| Tool | Description | Usage |
|------|-------------|-------|
| **Firefox** | Mozilla Firefox | Open from Applications |
| **Google Chrome** | Google Chrome browser | Open from Applications |
| **Microsoft Edge** | Microsoft Edge browser | Open from Applications |

### Development Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **VS Code** | Code editor | `code .` or `code <file>` |
| **GitHub Desktop** | Git GUI client | Open from Applications |
| **GitKraken** | Advanced Git GUI | Open from Applications |
| **Docker Desktop** | Container runtime | `docker run <image>` |
| **Beyond Compare** | File comparison tool | Open from Applications |
| **Warp** | Modern terminal | Open from Applications |

### Programming Languages

| Tool | Version | Usage |
|------|---------|-------|
| **Python** | 3.13 | `python3`, `pip3` |
| **Node.js** | Latest | `node`, `npm` |
| **Go** | Latest | `go build`, `go run` |
| **.NET SDK** | Latest | `dotnet new`, `dotnet run` |
| **OpenJDK** | 21 | `java`, `javac` |

### Version Managers

| Tool | Description | Usage |
|------|-------------|-------|
| **pyenv** | Python version manager | `pyenv install 3.12`, `pyenv global 3.12` |
| **nvm** | Node.js version manager | `nvm install 20`, `nvm use 20` |

### Python Tools (via pipx)

| Tool | Description | Usage |
|------|-------------|-------|
| **poetry** | Dependency management | `poetry new myproject`, `poetry install` |
| **httpie** | HTTP client | `http GET https://api.example.com` |
| **litellm** | LLM proxy | `litellm --model gpt-4` |

### Infrastructure as Code

| Tool | Description | Usage |
|------|-------------|-------|
| **Terraform** | Infrastructure provisioning | `terraform init`, `terraform apply` |
| **Terraform-docs** | Generate TF documentation | `terraform-docs markdown .` |
| **Packer** | Image building | `packer build template.pkr.hcl` |

### Kubernetes

| Tool | Description | Usage |
|------|-------------|-------|
| **kubectl** | Kubernetes CLI | `kubectl get pods`, `kubectl apply -f` |
| **kubelogin** | Azure AD auth for AKS | `kubelogin convert-kubeconfig` |

### Azure & Cloud

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure CLI** | Azure management | `az login`, `az group list` |
| **azcopy** | Azure blob transfer | `azcopy copy src dest` |
| **azd** | Azure Developer CLI | `azd init`, `azd up` |
| **PowerShell** | Cross-platform shell | `pwsh` |
| **Azure Storage Explorer** | GUI for Azure Storage | Open from Applications |

### Database

| Tool | Description | Usage |
|------|-------------|-------|
| **PostgreSQL 16** | PostgreSQL client | `psql -h host -U user -d database` |
| **msodbcsql18** | SQL Server ODBC driver | Used by applications |
| **mssql-tools18** | SQL Server CLI | `sqlcmd -S server -U user` |

### LLM / AI Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Ollama** | Local LLM runner | See [Ollama Usage](#ollama-usage) |
| **LM Studio** | GUI model manager | Open from Applications |
| **Jan** | Privacy-focused chat | Open from Applications |
| **ChatGPT** | OpenAI desktop app | Open from Applications |
| **Claude** | Anthropic desktop app | Open from Applications |
| **Claude Code** | AI coding assistant | `claude` in terminal |

### Communication

| Tool | Description |
|------|-------------|
| **Slack** | Team messaging |
| **Signal** | Encrypted messaging |
| **Telegram** | Messaging app |
| **WhatsApp** | Messaging app |

### Productivity

| Tool | Description |
|------|-------------|
| **Notion** | Notes and docs |
| **1Password CLI** | Password manager (`op`) |
| **Adobe Acrobat Pro** | PDF editor |
| **Spotify** | Music streaming |
| **Snagit** | Screenshot tool |
| **Raycast** | Launcher (Spotlight replacement) |

### Shell Customization

| Tool | Description | Usage |
|------|-------------|-------|
| **oh-my-zsh** | Zsh framework | Automatic with zsh |
| **oh-my-posh** | Prompt theme engine | Configured in shell profile |
| **Nerd Fonts** | Icon fonts | FiraCode, Meslo, JetBrains Mono |

### Mac App Store Apps

| App | Description |
|-----|-------------|
| **Xcode** | Apple development tools |
| **WireGuard** | VPN client |
| **Magnet** | Window manager |
| **Amphetamine** | Prevent sleep |
| **Vimari** | Vim for Safari |
| **CleanMyMac X** | System cleanup |
| **Paste** | Clipboard manager |
| **CapCut** | Video editor |

## Ollama Usage

### Basic Commands

```bash
# Start Ollama server
ollama serve

# List downloaded models
ollama list

# Download a model
ollama pull qwen2.5-coder:32b

# Chat with a model
ollama run qwen2.5-coder:32b

# Show running models
ollama ps

# Remove a model
ollama rm <model>
```

### Recommended Models for 64GB+ RAM

```bash
# Coding (Best)
ollama pull qwen2.5-coder:32b          # 18GB - Best local coding model
ollama pull deepseek-coder-v2:16b      # 9GB  - Fast code completion
ollama pull codellama:34b              # 19GB - Meta's code model

# General Purpose
ollama pull llama3.3:70b-instruct-q4_K_M  # 40GB - Most capable
ollama pull qwen2.5:32b                   # 18GB - Excellent all-around
ollama pull mixtral:8x7b                  # 26GB - Fast MoE model

# Fast/Small
ollama pull llama3.2:3b                # 2GB  - Very fast
ollama pull qwen2.5-coder:7b           # 4GB  - Good balance

# Specialized
ollama pull nomic-embed-text           # 274MB - Embeddings for RAG
ollama pull llava:34b                  # 19GB  - Vision model
```

### API Usage

```bash
# Generate text
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "Write a Python function to reverse a string",
  "stream": false
}'

# Chat format
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:32b",
  "messages": [{"role": "user", "content": "Hello"}]
}'
```

## MLX Usage (Apple Silicon Native)

```bash
# Download model from Hugging Face
huggingface-cli download mlx-community/Qwen2.5-Coder-32B-Instruct-4bit

# Generate text
mlx_lm.generate --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --prompt "Hello"

# Start OpenAI-compatible server
mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080
```

## VS Code Extensions Installed

- `ms-python.python` - Python support
- `ms-python.vscode-pylance` - Python language server
- `ms-azuretools.vscode-docker` - Docker support
- `hashicorp.terraform` - Terraform support
- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - Copilot Chat
- `continue.continue` - Local LLM integration
- `ms-dotnettools.csharp` - C# support
- `golang.go` - Go support
- `esbenp.prettier-vscode` - Code formatter
- `eamodio.gitlens` - Git visualization

## Troubleshooting

### Homebrew not found

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

### Ollama not starting

```bash
# Start manually to see errors
ollama serve

# Check if port is in use
lsof -i :11434
```

### Docker not starting

```bash
# Start Docker Desktop from Applications
# Or via CLI:
open -a Docker
```

## Related Documentation

- [Mac Dev Workstation](mac-dev-workstation.md) - Standard dev setup without LLM tools
- [Main Documentation](README.md) - All scripts overview
