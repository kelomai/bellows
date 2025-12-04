#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Install-ClientWorkstation.ps1 - Windows 11 Client Workstation Setup
.DESCRIPTION
    Automated setup script for a Windows 11 client/business workstation.
    Installs productivity applications for general business use.
    No development tools or programming languages included.

    Includes:
    - Web browser (Chrome)
    - Microsoft 365 (Office, OneDrive)
    - Communication (Slack, Zoom)
    - Productivity (1Password, Notion, Adobe Reader)
    - Shell customization (oh-my-posh)

    Package configuration is loaded from packages.json (local file or GitHub).
.PARAMETER DryRun
    Preview what would be installed without making changes
.PARAMETER ManifestPath
    Path to a local packages.json file (optional, defaults to GitHub)
.PARAMETER Repo
    GitHub repository in org/repo format (default: kelomai/bellows)
.PARAMETER Branch
    Git branch name (default: main)
.EXAMPLE
    .\Install-ClientWorkstation.ps1
    Run the full installation interactively
.EXAMPLE
    .\Install-ClientWorkstation.ps1 -DryRun
    Preview all installations without making changes
.EXAMPLE
    .\Install-ClientWorkstation.ps1 -ManifestPath .\my-packages.json
    Use a custom package manifest
.EXAMPLE
    .\Install-ClientWorkstation.ps1 -Repo "myuser/bellows" -Branch "my-feature"
    Test from a forked repo and branch
.LINK
    https://github.com/kelomai/bellows
.NOTES
    Author: 🧙‍♂️ Kelomai (https://kelomai.io)
    License: MIT

    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
#>

param(
    [switch]$DryRun,
    [string]$ManifestPath,
    [string]$Repo = "kelomai/bellows",
    [string]$Branch = "main"
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Continue"
$GithubManifestUrl = "https://raw.githubusercontent.com/$Repo/$Branch/win11-setup/client-workstation/packages.json"

if ($DryRun) {
    Write-Host "╔═════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║   🔍 DRY RUN MODE - No changes will be made ║" -ForegroundColor DarkGray
    Write-Host "╚═════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "╔═════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║        Welcome 👋 to 🧙‍♂️ Kelomai 🚀          ║" -ForegroundColor DarkGray
Write-Host "║           https://kelomai.io                ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║    Windows 11 Client Workstation Setup      ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Get-PackageManifest {
    param(
        [string]$LocalPath,
        [string]$RemoteUrl
    )

    # Try local file first
    if ($LocalPath -and (Test-Path $LocalPath)) {
        Write-Info "Loading manifest from: $LocalPath"
        try {
            $content = Get-Content $LocalPath -Raw
            return $content | ConvertFrom-Json
        }
        catch {
            Write-Warn "Failed to parse local manifest: $_"
        }
    }

    # Check for packages.json in script directory
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    if ($scriptDir) {
        $localManifest = Join-Path $scriptDir "packages.json"
        if (Test-Path $localManifest) {
            Write-Info "Loading manifest from: $localManifest"
            try {
                $content = Get-Content $localManifest -Raw
                return $content | ConvertFrom-Json
            }
            catch {
                Write-Warn "Failed to parse local manifest: $_"
            }
        }
    }

    # Fall back to GitHub
    Write-Info "Fetching manifest from GitHub..."
    try {
        $response = Invoke-WebRequest -Uri $RemoteUrl -UseBasicParsing
        return $response.Content | ConvertFrom-Json
    }
    catch {
        Write-Host "  ERROR: Failed to load package manifest: $_" -ForegroundColor Red
        exit 1
    }
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$Name
    )

    if ($DryRun) {
        Write-Info "[DRY RUN] Would install: $Name ($Id)"
        return
    }

    # Check if already installed
    $installed = winget list --id $Id 2>$null | Select-String $Id
    if ($installed) {
        Write-Success "$Name already installed"
    }
    else {
        Write-Info "Installing $Name..."
        winget install --id $Id --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed"
        }
        else {
            Write-Warn "Failed to install $Name"
        }
    }
}

function Install-WingetCategory {
    param(
        [array]$Packages,
        [string]$CategoryName
    )

    if ($null -eq $Packages -or $Packages.Count -eq 0) {
        return
    }

    foreach ($pkg in $Packages) {
        Install-WingetPackage -Id $pkg.id -Name $pkg.name
    }
}

# =============================================================================
# LOAD PACKAGE MANIFEST
# =============================================================================
Write-Step "[1/4] Loading package manifest..."
$manifest = Get-PackageManifest -LocalPath $ManifestPath -RemoteUrl $GithubManifestUrl
Write-Success "Package manifest loaded"

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

# Check for winget
Write-Step "[2/4] Checking winget..."
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-Success "winget available"

# Install Applications
Write-Step "[3/4] Installing applications..."
$categories = @("browsers", "microsoft", "communication", "productivity", "utilities", "fonts", "shell")
foreach ($category in $categories) {
    $packages = $manifest.winget.$category
    Install-WingetCategory -Packages $packages -CategoryName $category
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh)
# =============================================================================
Write-Step "[4/4] Configuring PowerShell..."

$ompConfigDir = "$env:USERPROFILE\.config\oh-my-posh"
$ompConfig = "$ompConfigDir\bellows.omp.json"
$profilePath = $PROFILE.CurrentUserAllHosts

if ($DryRun) {
    Write-Info "[DRY RUN] Would download oh-my-posh theme"
    Write-Info "[DRY RUN] Would configure PowerShell profile"
}
else {
    # Create config directory
    if (!(Test-Path $ompConfigDir)) {
        New-Item -ItemType Directory -Path $ompConfigDir -Force | Out-Null
    }

    # Download theme
    Write-Info "Downloading oh-my-posh theme..."
    $themeUrl = "https://raw.githubusercontent.com/kelomai/bellows/main/cli/oh-my-posh/bellows.omp.json"
    try {
        Invoke-WebRequest -Uri $themeUrl -OutFile $ompConfig -UseBasicParsing
        Write-Success "Theme downloaded to $ompConfig"
    }
    catch {
        Write-Warn "Failed to download theme: $_"
    }

    # Create/update PowerShell profile
    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $ompInit = @"

# oh-my-posh prompt (Bellows theme)
oh-my-posh init pwsh --config "`$env:USERPROFILE\.config\oh-my-posh\bellows.omp.json" | Invoke-Expression

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@

    if (Test-Path $profilePath) {
        $existingProfile = Get-Content $profilePath -Raw
        if ($existingProfile -notmatch "oh-my-posh init pwsh") {
            Add-Content -Path $profilePath -Value $ompInit
            Write-Success "Added oh-my-posh to PowerShell profile"
        }
        else {
            Write-Success "PowerShell profile already configured"
        }
    }
    else {
        Set-Content -Path $profilePath -Value $ompInit
        Write-Success "Created PowerShell profile with oh-my-posh"
    }
}

# =============================================================================
# COMPLETE
# =============================================================================
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║     ✅ Setup complete!                                  ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║  Next steps:                                            ║" -ForegroundColor DarkGray
Write-Host "║    1. Restart PowerShell to load the new prompt         ║" -ForegroundColor DarkGray
Write-Host "║    2. Sign into Microsoft 365 and OneDrive              ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" -ForegroundColor DarkGray
Write-Host "║              https://kelomai.io                         ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
