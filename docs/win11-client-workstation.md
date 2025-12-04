# Windows 11 Client Workstation

Productivity setup for business users and client workstations.

## Quick Start

```powershell
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
```

### Run with Options

```powershell
# Download and run with dry-run
$script = irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1
& ([scriptblock]::Create($script)) -DryRun
```

## Tools Installed

### Browser

| Tool | Description |
|------|-------------|
| **Google Chrome** | Web browser |

### Microsoft 365

| Tool | Description |
|------|-------------|
| **Microsoft Office** | Word, Excel, PowerPoint, Outlook |
| **OneDrive** | Cloud storage and sync |

### Communication

| Tool | Description |
|------|-------------|
| **Slack** | Team messaging |
| **Zoom** | Video conferencing |

### Productivity

| Tool | Description |
|------|-------------|
| **1Password** | Password manager |
| **Notion** | Notes and documentation |
| **Adobe Acrobat Reader** | PDF viewer |

### Utilities

| Tool | Description |
|------|-------------|
| **7-Zip** | Archive tool |

### Shell Customization

| Tool | Description |
|------|-------------|
| **oh-my-posh** | Prompt theme engine |
| **Nerd Fonts** | Icon fonts |

## Common Tasks

### OneDrive Setup

1. Sign in with your Microsoft account
2. Choose folders to sync
3. Enable Files On-Demand for space savings

### 1Password Setup

1. Sign in to your 1Password account
2. Install browser extension in Chrome
3. Enable Windows Hello for quick unlock

### Slack Setup

1. Sign in to your workspace
2. Configure notifications
3. Set status and availability

### Zoom Setup

1. Sign in with your account
2. Test audio and video
3. Configure virtual background (optional)

## Shell Configuration

PowerShell is configured with:

- **oh-my-posh** for a modern prompt
- **Cascadia Code NF** font for icons

### PowerShell Profile Location

```powershell
$PROFILE
# C:\Users\<user>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

## Keyboard Shortcuts

### Windows 11

| Shortcut | Action |
|----------|--------|
| `Win+E` | File Explorer |
| `Win+I` | Settings |
| `Win+L` | Lock screen |
| `Win+D` | Show desktop |
| `Win+Tab` | Task view |
| `Alt+Tab` | Switch windows |
| `Win+Shift+S` | Screenshot |

### Microsoft Office

| Shortcut | Action |
|----------|--------|
| `Ctrl+N` | New document |
| `Ctrl+O` | Open |
| `Ctrl+S` | Save |
| `Ctrl+P` | Print |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |

## Troubleshooting

### winget not found

```powershell
# Install App Installer from Microsoft Store
# Or run Windows Update
```

### OneDrive not syncing

1. Check internet connection
2. Verify account is signed in
3. Check available disk space
4. Restart OneDrive

### Office activation issues

1. Sign out and sign back in
2. Run Office repair from Settings > Apps
3. Contact IT for license issues

## Updates

Applications installed via winget can be updated with:

```powershell
winget upgrade --all
```

## Related Documentation

- [Windows Dev Workstation](win11-dev-workstation.md) - Developer setup
- [Debloat Windows](win11-debloat.md) - Remove bloatware
- [Main Documentation](README.md) - All scripts overview
