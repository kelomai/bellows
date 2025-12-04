# Ubuntu Headless

CLI-only development environment for servers, WSL2, and Docker containers. Optimized for coding with Claude Code.

## Quick Start

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

## Tools Installed

### Core Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Git** | Version control | `git clone`, `git commit` |
| **build-essential** | C/C++ compilers | `gcc`, `make` |
| **curl** | HTTP client | `curl https://example.com` |
| **wget** | File downloader | `wget https://example.com/file` |

### Programming Languages

| Tool | Version | Usage |
|------|---------|-------|
| **Python 3** | System default | `python3`, `pip3` |
| **Node.js** | 22.x LTS | `node`, `npm` |
| **Go** | 1.23.4 | `go build`, `go run` |
| **.NET SDK** | Latest STS | `dotnet new`, `dotnet run` |

### Claude Code

| Tool | Description | Usage |
|------|-------------|-------|
| **Claude Code** | AI coding assistant | `claude` |

```bash
# Start Claude Code
claude

# Show help
claude --help

# Start in a specific directory
cd /path/to/project && claude
```

### Cloud CLIs

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure CLI** | Azure management | `az login`, `az group list` |
| **AWS CLI** | AWS management | `aws configure`, `aws s3 ls` |
| **Google Cloud CLI** | GCP management | `gcloud init`, `gcloud projects list` |
| **GitHub CLI** | GitHub operations | `gh auth login`, `gh pr create` |

### DevOps & Containers

| Tool | Description | Usage |
|------|-------------|-------|
| **Docker** | Container runtime | `docker run`, `docker-compose up` |
| **Terraform** | Infrastructure as Code | `terraform init`, `terraform apply` |
| **kubectl** | Kubernetes CLI (1.32) | `kubectl get pods` |
| **Helm** | Kubernetes packages | `helm install`, `helm list` |
| **k9s** | Kubernetes TUI | `k9s` |

### Shell & Terminal

| Tool | Description | Usage |
|------|-------------|-------|
| **Zsh** | Modern shell | Default shell after install |
| **Oh My Zsh** | Zsh framework | Automatic |
| **tmux** | Terminal multiplexer | `tmux`, `tmux attach` |
| **Nerd Fonts** | Icon fonts | FiraCode, MesloLGS |

### Utilities

| Tool | Description | Usage |
|------|-------------|-------|
| **jq** | JSON processor | `cat file.json \| jq '.key'` |
| **htop** | Process viewer | `htop` |
| **tree** | Directory tree | `tree -L 2` |
| **ripgrep** | Fast search | `rg "pattern"` |

### Networking Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **dig** | DNS lookup | `dig example.com` |
| **nslookup** | DNS lookup | `nslookup example.com` |
| **whois** | Domain info | `whois example.com` |
| **traceroute** | Route tracing | `traceroute google.com` |
| **mtr** | Live traceroute | `mtr google.com` |
| **nmap** | Port scanner | `nmap -p 22,80 host` |
| **netcat** | TCP/UDP tool | `nc host port` |

### Database

| Tool | Description | Usage |
|------|-------------|-------|
| **psql** | PostgreSQL client | `psql -h host -U user -d db` |

### Remote Access

| Tool | Port | Description |
|------|------|-------------|
| **SSH** | 22 | `ssh user@ip` |

## Common Commands

### Claude Code

```bash
claude                       # Start Claude Code
claude --help                # Show help
claude --version             # Show version
```

### Docker

```bash
docker ps                    # List running containers
docker images                # List images
docker run hello-world       # Test Docker
docker-compose up -d         # Start compose stack
docker exec -it <id> bash    # Shell into container
```

### Kubernetes

```bash
kubectl get pods             # List pods
kubectl get nodes            # List nodes
kubectl apply -f file.yaml   # Apply config
k9s                         # Launch k9s TUI
helm list                   # List Helm releases
```

### Terraform

```bash
terraform init               # Initialize
terraform plan               # Preview changes
terraform apply              # Apply changes
terraform destroy            # Destroy resources
```

### Cloud CLIs

```bash
# Azure
az login                     # Login (browser opens)
az login --use-device-code   # Login (device code for headless)
az account list              # List subscriptions

# AWS
aws configure                # Configure credentials
aws s3 ls                    # List S3 buckets
aws sts get-caller-identity  # Check identity

# Google Cloud
gcloud init                  # Initialize
gcloud auth login            # Login
gcloud projects list         # List projects

# GitHub
gh auth login                # Login to GitHub
gh pr list                   # List PRs
gh pr create                 # Create PR
```

### tmux

```bash
tmux                         # Start new session
tmux new -s name             # Start named session
tmux attach                  # Attach to last session
tmux attach -t name          # Attach to named session
tmux ls                      # List sessions

# Inside tmux:
# Ctrl+b c     - New window
# Ctrl+b n     - Next window
# Ctrl+b p     - Previous window
# Ctrl+b %     - Split vertical
# Ctrl+b "     - Split horizontal
# Ctrl+b d     - Detach
```

## Shell Configuration

The installation configures Zsh with:

- **Theme**: robbyrussell (oh-my-zsh default)
- **Plugins**: git, docker, kubectl, terraform, aws, gcloud, gh, zsh-autosuggestions, zsh-syntax-highlighting

### Aliases Configured

```bash
k       # kubectl
tf      # terraform
g       # git
ll      # ls -la
dps     # docker ps
```

## Environment Variables

The following are added to `~/.profile`:

```bash
# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# .NET
export DOTNET_ROOT=/usr/local/dotnet
export PATH=$PATH:$DOTNET_ROOT

# k9s
export PATH=$PATH:$HOME/.local/bin
```

## Updating Packages

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash
```

Or manually:

```bash
sudo apt update && sudo apt upgrade -y  # APT packages
sudo npm update -g                      # NPM globals (Claude Code)
```

## Troubleshooting

### Docker permission denied

```bash
# Log out and back in, or:
newgrp docker
```

### Go not found

```bash
source ~/.profile
# Or add to current session:
export PATH=$PATH:/usr/local/go/bin
```

### .NET not found

```bash
source ~/.profile
# Or add to current session:
export PATH=$PATH:/usr/local/dotnet
```

### Zsh not default shell

```bash
chsh -s $(which zsh)
# Log out and back in
```

## Use Cases

### WSL2

Perfect for Windows users who want Linux dev tools:

```bash
# In WSL2 terminal:
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

### Docker Container

For creating dev containers:

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y wget
RUN wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

### Remote Server

For cloud VMs or dedicated servers:

```bash
ssh user@server
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/headless/install-headless.sh | bash
```

## Related Documentation

- [Ubuntu Dev Workstation](ubuntu-dev-workstation.md) - Full GUI setup
- [Main Documentation](README.md) - All scripts overview
