# Windows 11 Workstation Setup

Automated setup scripts for Windows 11 workstations. Choose between **Developer** or **Client** configurations.

## Directory Structure

```text
win11-setup/
├── Debloat-Windows.ps1                      # Remove bloatware & telemetry
├── dev-workstation/
│   ├── Install-DevWorkstation.ps1           # Full dev environment + LLM stack
│   └── packages.json                        # Package manifest (customize this!)
└── client-workstation/
    ├── Install-ClientWorkstation.ps1        # Productivity apps only
    └── packages.json                        # Package manifest (customize this!)
```

---

## Quick Start

### Developer Workstation

Full development environment with programming languages, containers, and local LLM stack.

```powershell
# Run as Administrator
.\dev-workstation\Install-DevWorkstation.ps1

# Preview without making changes
.\dev-workstation\Install-DevWorkstation.ps1 -DryRun

# Remote execution
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex
```

### Client Workstation

Productivity-focused setup for general business use. No development tools.

```powershell
# Run as Administrator
.\client-workstation\Install-ClientWorkstation.ps1

# Preview without making changes
.\client-workstation\Install-ClientWorkstation.ps1 -DryRun

# Remote execution
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
```

### Windows Debloat (Common)

Run before either setup to remove bloatware and telemetry.

```powershell
# Run as Administrator
.\Debloat-Windows.ps1

# Remote execution
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/Debloat-Windows.ps1 | iex
```

---

## Customization

Package lists are defined in `packages.json` files, separate from the install scripts. To customize what gets installed:

### Option 1: Edit packages.json locally

```powershell
# Clone the repo
git clone https://github.com/kelomai/bellows.git
cd bellows/win11-setup/dev-workstation

# Edit packages.json to add/remove packages
notepad packages.json

# Run the script (it will use local packages.json)
.\Install-DevWorkstation.ps1
```

### Option 2: Use a custom manifest

```powershell
# Use your own packages.json file
.\Install-DevWorkstation.ps1 -ManifestPath C:\path\to\my-packages.json
```

### Option 3: Remote execution (uses default packages)

```powershell
# Fetches packages.json from GitHub automatically
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex
```

---

## Developer Workstation Packages

### GUI Applications

| Category | Apps |
|----------|------|
| **Browsers** | Firefox, Chrome, Edge |
| **Code Editors** | VS Code |
| **Git Tools** | GitHub Desktop, GitKraken |
| **Terminals** | Windows Terminal, Warp |
| **Containers** | Docker Desktop |
| **LLM/AI Tools** | LM Studio, Ollama, ChatGPT, Claude |
| **Microsoft/Azure** | PowerShell 7, Azure Storage Explorer |
| **Fonts** | Fira Code Nerd Font, JetBrains Mono Nerd Font |

### CLI Tools

| Category | Tools |
|----------|-------|
| **Core Dev** | git, gh (GitHub CLI), curl, jq |
| **Languages** | Python 3.13, Node.js, Go, .NET SDK 8, OpenJDK 21 |
| **IaC** | Terraform, Packer |
| **Kubernetes** | kubectl, Helm |
| **Azure** | azure-cli, azd |
| **Database** | PostgreSQL, SQL Server Management Studio |
| **Security** | GitGuardian (ggshield) |
| **Shell** | oh-my-posh |

### VS Code Extensions

- Python, Pylance
- Docker
- Terraform
- GitHub Copilot + Chat
- Continue (local LLM integration)
- C#, Go
- Prettier, GitLens

### Local LLM Stack

```powershell
# Start Ollama server
ollama serve

# Recommended models
ollama pull qwen2.5-coder:32b      # 18GB - Best coding model
ollama pull llama3.2:3b            # 2GB - Fast, small model
ollama pull llama3.3:70b           # 40GB - Most capable
```

---

## Client Workstation Packages

Lightweight setup for business users.

### Included Applications

| Category | Apps |
|----------|------|
| **Browsers** | Chrome |
| **Microsoft 365** | Office, OneDrive, PowerShell 7, Windows Terminal |
| **Communication** | Slack, Zoom |
| **Productivity** | 1Password, Notion, Adobe Acrobat Reader |
| **Utilities** | 7-Zip |
| **Fonts** | Cascadia Code Nerd Font |

---

## Windows Debloat

Prepare a clean Windows 11 image for development or corporate use.

### What It Removes

- **Bloatware**: Bing apps, Xbox, Solitaire, Teams, Clipchamp, etc.
- **OneDrive**: Complete removal including Explorer integration
- **Telemetry**: Data collection, activity history, diagnostics
- **Consumer Features**: Automatic app installs, suggestions, tips
- **Cortana**: Disabled along with web search in Start Menu
- **Unnecessary Services**: Xbox services, retail demo, telemetry services

### What It Disables

- Advertising ID
- Location tracking
- Feedback notifications
- Windows Spotlight
- Game DVR

---

## Shell Configuration

Both setup scripts configure PowerShell with **oh-my-posh**:

- Custom Bellows theme
- PSReadLine with history-based predictions
- Developer workstation adds aliases: `k` (kubectl), `tf` (terraform), `g` (git)

Theme location: `~\.config\oh-my-posh\bellows.omp.json`

---

## Requirements

- Windows 11
- PowerShell 5.1+ (or PowerShell 7)
- Administrator privileges
- winget (App Installer from Microsoft Store)

---

## Troubleshooting

### winget not found

```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### oh-my-posh icons not displaying

Set your terminal font to a Nerd Font (Fira Code, JetBrains Mono, or Cascadia Code).

### Ollama not starting

```powershell
ollama serve  # Run manually to see errors
```
