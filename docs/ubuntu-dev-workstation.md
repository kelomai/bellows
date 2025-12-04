# Ubuntu Developer Workstation

Full GUI development environment for Ubuntu Desktop on Proxmox VMs.

## Quick Start

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash
```

## Tools Installed

### Core Applications

| Tool | Description | Usage |
|------|-------------|-------|
| **Git** | Version control | `git clone`, `git commit` |
| **Microsoft Edge** | Web browser | Open from Applications |
| **GitKraken** | Git GUI client | Open from Applications |
| **VS Code** | Code editor | `code .` or `code <file>` |
| **Postman** | API testing | Open from Applications |

### Programming Languages

| Tool | Version | Usage |
|------|---------|-------|
| **Python 3** | System default | `python3`, `pip3` |
| **Node.js** | 22.x LTS | `node`, `npm` |
| **Go** | Latest (snap) | `go build`, `go run` |
| **.NET SDK** | Latest | `dotnet new`, `dotnet run` |
| **PowerShell** | Latest (snap) | `pwsh` |

### Cloud CLIs

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure CLI** | Azure management | `az login`, `az group list` |
| **AWS CLI** | AWS management | `aws configure`, `aws s3 ls` |
| **Google Cloud CLI** | GCP management | `gcloud init`, `gcloud projects list` |
| **GitHub CLI** | GitHub operations | `gh auth login`, `gh pr create` |

### Azure Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure PowerShell** | Az module | `pwsh -Command "Connect-AzAccount"` |
| **Azure Storage Explorer** | GUI for Storage | Open from Applications |

### DevOps & Containers

| Tool | Description | Usage |
|------|-------------|-------|
| **Docker** | Container runtime | `docker run`, `docker-compose up` |
| **Terraform** | Infrastructure as Code | `terraform init`, `terraform apply` |
| **kubectl** | Kubernetes CLI | `kubectl get pods` |
| **Helm** | Kubernetes packages | `helm install`, `helm list` |
| **k9s** | Kubernetes TUI | `k9s` |

### Database

| Tool | Description | Usage |
|------|-------------|-------|
| **psql** | PostgreSQL client | `psql -h host -U user -d db` |
| **DBeaver** | Database GUI | Open from Applications |

### Shell & Terminal

| Tool | Description | Usage |
|------|-------------|-------|
| **Zsh** | Modern shell | Default shell after install |
| **Oh My Zsh** | Zsh framework | Automatic |
| **Oh My Posh** | Prompt theme | Configured automatically |
| **Nerd Fonts** | Icon fonts | FiraCode |

### Utilities

| Tool | Description | Usage |
|------|-------------|-------|
| **jq** | JSON processor | `cat file.json \| jq '.key'` |
| **htop** | Process viewer | `htop` |
| **tree** | Directory tree | `tree -L 2` |
| **ripgrep** | Fast search | `rg "pattern"` |
| **build-essential** | C/C++ compilers | `gcc`, `make` |

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
| **tcpdump** | Packet capture | `sudo tcpdump -i eth0` |
| **iftop** | Bandwidth monitor | `sudo iftop` |

### Proxmox VM Integration

| Tool | Description |
|------|-------------|
| **qemu-guest-agent** | VM management from Proxmox |
| **spice-vdagent** | Clipboard sharing, display resize |

### Remote Access

| Tool | Port | Description |
|------|------|-------------|
| **SSH** | 22 | `ssh user@ip` |
| **xrdp** | 3389 | Remote Desktop (RDP) |

### Other Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Claude Code** | AI coding assistant | `claude` |
| **1Password CLI** | Password manager | `op signin`, `op item get` |

## Common Commands

### Docker

```bash
docker ps                     # List running containers
docker images                 # List images
docker run hello-world        # Test Docker
docker-compose up -d          # Start compose stack
docker logs <container>       # View logs
```

### Kubernetes

```bash
kubectl get pods              # List pods
kubectl get nodes             # List nodes
k9s                          # Launch k9s TUI
helm list                    # List Helm releases
```

### Azure

```bash
az login                     # Login to Azure CLI
az account list              # List subscriptions
pwsh -Command "Connect-AzAccount"  # Login via PowerShell
```

### AWS

```bash
aws configure                # Configure credentials
aws s3 ls                    # List S3 buckets
aws ec2 describe-instances   # List EC2 instances
aws sts get-caller-identity  # Check identity
```

### Google Cloud

```bash
gcloud init                  # Initialize and login
gcloud auth login            # Login to GCP
gcloud projects list         # List projects
gcloud config set project ID # Set active project
```

### DNS & Networking

```bash
dig google.com               # DNS lookup
dig +short google.com        # Short answer
nslookup google.com          # Alternative lookup
whois example.com            # Domain info
mtr google.com               # Live traceroute
nmap -p 22,80,443 host       # Scan ports
sudo iftop                   # Monitor bandwidth
```

## Connecting to the VM

### SSH

```bash
ssh user@vm-ip-address
```

### RDP (Remote Desktop)

Connect using any RDP client to port 3389:

- **Windows**: Built-in Remote Desktop Connection
- **macOS**: Microsoft Remote Desktop
- **Linux**: Remmina

## Updating Packages

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash
```

Or manually:

```bash
sudo apt update && sudo apt upgrade -y  # APT packages
sudo snap refresh                       # Snap packages
sudo npm update -g                      # NPM globals
pwsh -Command "Update-Module Az"        # Azure PowerShell
```

## Troubleshooting

### Docker permission denied

```bash
# Log out and back in, or:
newgrp docker
```

### Snap apps not found

```bash
source /etc/profile.d/apps-bin-path.sh
```

### Proxmox clipboard not working

```bash
sudo systemctl restart spice-vdagent
```

## Related Documentation

- [Ubuntu Headless](ubuntu-headless.md) - CLI-only setup
- [Main Documentation](README.md) - All scripts overview
