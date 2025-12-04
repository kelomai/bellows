# Windows 11 Developer Workstation

Full development environment for Windows 11.

## Quick Start

```powershell
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex
```

### Run with Options

```powershell
# Download and run with dry-run
$script = irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1
& ([scriptblock]::Create($script)) -DryRun

# Or download first
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1" -OutFile "Install-DevWorkstation.ps1"
.\Install-DevWorkstation.ps1 -DryRun
```

## Tools Installed

### Package Manager

| Tool | Description | Usage |
|------|-------------|-------|
| **winget** | Windows Package Manager | `winget install <package>` |

### Browsers

| Tool | Description |
|------|-------------|
| **Google Chrome** | Web browser |
| **Mozilla Firefox** | Web browser |
| **Microsoft Edge** | Default browser (updated) |

### Development Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **VS Code** | Code editor | `code .` or `code <file>` |
| **Visual Studio 2022** | Full IDE | Open from Start Menu |
| **Git** | Version control | `git clone`, `git commit` |
| **GitHub Desktop** | Git GUI client | Open from Start Menu |
| **GitKraken** | Advanced Git GUI | Open from Start Menu |
| **Docker Desktop** | Container runtime | `docker run <image>` |
| **Windows Terminal** | Modern terminal | `wt` |
| **Postman** | API testing | Open from Start Menu |

### Programming Languages

| Tool | Version | Usage |
|------|---------|-------|
| **Python** | Latest | `python`, `pip` |
| **Node.js** | LTS | `node`, `npm` |
| **Go** | Latest | `go build`, `go run` |
| **.NET SDK** | Latest | `dotnet new`, `dotnet run` |
| **OpenJDK** | Latest | `java`, `javac` |

### Cloud CLIs

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure CLI** | Azure management | `az login`, `az group list` |
| **Azure PowerShell** | Az module | `Connect-AzAccount` |
| **AWS CLI** | AWS management | `aws configure` |
| **GitHub CLI** | GitHub operations | `gh auth login` |

### DevOps Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Terraform** | Infrastructure as Code | `terraform init`, `terraform apply` |
| **kubectl** | Kubernetes CLI | `kubectl get pods` |
| **Helm** | Kubernetes packages | `helm install` |

### Database Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **Azure Data Studio** | SQL editor | Open from Start Menu |
| **SQL Server Management Studio** | SQL Server GUI | Open from Start Menu |
| **DBeaver** | Multi-database GUI | Open from Start Menu |

### Utilities

| Tool | Description | Usage |
|------|-------------|-------|
| **7-Zip** | Archive tool | Right-click menu |
| **Notepad++** | Text editor | `notepad++ <file>` |
| **PowerToys** | Windows utilities | Run at startup |
| **WinSCP** | SFTP client | Open from Start Menu |
| **PuTTY** | SSH client | Open from Start Menu |

### Shell Customization

| Tool | Description | Usage |
|------|-------------|-------|
| **oh-my-posh** | Prompt theme engine | Configured in PowerShell profile |
| **Nerd Fonts** | Icon fonts | Cascadia Code NF |

## Common Commands

### PowerShell Profile

Your PowerShell profile is configured at:
```
$PROFILE
# Usually: C:\Users\<user>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

### Docker

```powershell
docker ps                    # List running containers
docker images                # List images
docker run hello-world       # Test Docker
docker-compose up -d         # Start compose stack
```

### Kubernetes

```powershell
kubectl get pods             # List pods
kubectl get nodes            # List nodes
kubectl apply -f file.yaml   # Apply config
helm list                    # List Helm releases
```

### Azure

```powershell
# Azure CLI
az login                     # Login
az account list              # List subscriptions
az group list                # List resource groups

# Azure PowerShell
Connect-AzAccount            # Login
Get-AzSubscription           # List subscriptions
Get-AzResourceGroup          # List resource groups
```

### Terraform

```powershell
terraform init               # Initialize
terraform plan               # Preview changes
terraform apply              # Apply changes
terraform destroy            # Destroy resources
```

### Git

```powershell
git clone <url>              # Clone repository
git status                   # Check status
git add .                    # Stage all changes
git commit -m "message"      # Commit
git push                     # Push to remote
```

## Windows Terminal Configuration

Windows Terminal is configured with:

- **Default Profile**: PowerShell
- **Font**: Cascadia Code NF (for oh-my-posh icons)
- **Color Scheme**: One Half Dark

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Alt+Shift+D` | Split pane |

## Environment Setup

### Add to PATH

```powershell
# Add directory to PATH for current session
$env:PATH += ";C:\path\to\bin"

# Add permanently (user)
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\path\to\bin", "User")
```

### Environment Variables

```powershell
# Set for current session
$env:MY_VAR = "value"

# Set permanently (user)
[Environment]::SetEnvironmentVariable("MY_VAR", "value", "User")
```

## Troubleshooting

### winget not found

```powershell
# Install App Installer from Microsoft Store
# Or run Windows Update
```

### Docker not starting

1. Ensure Hyper-V is enabled
2. Ensure WSL2 is installed
3. Restart Docker Desktop

### PowerShell execution policy

```powershell
# Allow scripts (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### oh-my-posh icons not showing

1. Install Cascadia Code NF font
2. Set Windows Terminal font to "Cascadia Code NF"

## Related Documentation

- [Windows Client Workstation](win11-client-workstation.md) - Business user setup
- [Debloat Windows](win11-debloat.md) - Remove bloatware
- [Main Documentation](README.md) - All scripts overview
