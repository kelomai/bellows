# macOS Developer Workstation

Standard development environment for MacBook Pro / MacBook Air / Mac Mini.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/kelomai/bellows/main/mac-setup/dev-workstation/install-dev-workstation.sh | bash
```

### Command Line Options

```bash
./install-dev-workstation.sh              # Full installation
./install-dev-workstation.sh --dry-run    # Preview without changes
./install-dev-workstation.sh --skip-mas   # Skip Mac App Store apps
./install-dev-workstation.sh --shells-only # Only configure shells
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

## Common Commands

### Docker

```bash
docker ps                    # List running containers
docker images                # List images
docker run -it ubuntu bash   # Run interactive container
docker-compose up -d         # Start compose stack
docker logs <container>      # View container logs
```

### Kubernetes

```bash
kubectl get pods             # List pods
kubectl get nodes            # List nodes
kubectl apply -f file.yaml   # Apply configuration
kubectl logs <pod>           # View pod logs
kubectl exec -it <pod> bash  # Shell into pod
```

### Terraform

```bash
terraform init               # Initialize
terraform plan               # Preview changes
terraform apply              # Apply changes
terraform destroy            # Destroy resources
```

### Azure CLI

```bash
az login                     # Login to Azure
az account list              # List subscriptions
az account set -s <id>       # Set subscription
az group list                # List resource groups
az aks get-credentials -g <rg> -n <cluster>  # Get AKS credentials
```

### Python

```bash
pyenv install 3.12           # Install Python version
pyenv global 3.12            # Set global version
poetry new myproject         # Create new project
poetry install               # Install dependencies
poetry shell                 # Activate virtual environment
```

## VS Code Extensions Installed

- `ms-python.python` - Python support
- `ms-python.vscode-pylance` - Python language server
- `ms-azuretools.vscode-docker` - Docker support
- `hashicorp.terraform` - Terraform support
- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - Copilot Chat
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

### Docker permission denied

```bash
# Restart Docker Desktop or:
docker context use default
```

### pyenv not working

```bash
# Ensure pyenv is in your PATH
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

## Related Documentation

- [Mac LLM Workstation](mac-llm-workstation.md) - Full LLM stack for Mac Ultra
- [Main Documentation](README.md) - All scripts overview
