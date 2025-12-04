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
.PARAMETER DryRun
    Preview what would be installed without making changes
.EXAMPLE
    .\Install-ClientWorkstation.ps1
    Run the full installation interactively
.EXAMPLE
    .\Install-ClientWorkstation.ps1 -DryRun
    Preview all installations without making changes
.LINK
    https://github.com/kelomai/bellows
.NOTES
    Author: Bellows
    License: MIT

    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/client-workstation/Install-ClientWorkstation.ps1 | iex
#>

param(
    [switch]$DryRun
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Continue"

if ($DryRun) {
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "  DRY RUN MODE - No changes will be made" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Client Workstation Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# WINGET PACKAGES
# =============================================================================

$wingetApps = @(
    # --- Browsers ---
    @{id = "Google.Chrome"; name = "Chrome" }

    # --- Microsoft 365 ---
    @{id = "Microsoft.Office"; name = "Microsoft Office" }
    @{id = "Microsoft.OneDrive"; name = "OneDrive" }
    @{id = "Microsoft.PowerShell"; name = "PowerShell 7" }
    @{id = "Microsoft.WindowsTerminal"; name = "Windows Terminal" }

    # --- Communication ---
    @{id = "SlackTechnologies.Slack"; name = "Slack" }
    @{id = "Zoom.Zoom"; name = "Zoom" }

    # --- Productivity ---
    @{id = "AgileBits.1Password"; name = "1Password" }
    @{id = "Notion.Notion"; name = "Notion" }
    @{id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Acrobat Reader" }

    # --- Utilities ---
    @{id = "7zip.7zip"; name = "7-Zip" }

    # --- Fonts ---
    @{id = "NerdFonts.CascadiaCode"; name = "Cascadia Code Nerd Font" }
)

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

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

# Check for winget
Write-Step "[1/3] Checking winget..."
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-Success "winget available"

# Install Applications
Write-Step "[2/3] Installing applications ($($wingetApps.Count) apps)..."
foreach ($app in $wingetApps) {
    Install-WingetPackage -Id $app.id -Name $app.name
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh)
# =============================================================================
Write-Step "[3/3] Configuring PowerShell..."

$ompConfigDir = "$env:USERPROFILE\.config\oh-my-posh"
$ompConfig = "$ompConfigDir\bellows.omp.json"
$profilePath = $PROFILE.CurrentUserAllHosts

if ($DryRun) {
    Write-Info "[DRY RUN] Would download oh-my-posh theme"
    Write-Info "[DRY RUN] Would configure PowerShell profile"
}
else {
    # Install oh-my-posh
    $ompInstalled = winget list --id "JanDeDobbeleer.OhMyPosh" 2>$null | Select-String "OhMyPosh"
    if (!$ompInstalled) {
        Write-Info "Installing oh-my-posh..."
        winget install --id "JanDeDobbeleer.OhMyPosh" --accept-package-agreements --accept-source-agreements --silent
    }

    # Create config directory
    if (!(Test-Path $ompConfigDir)) {
        New-Item -ItemType Directory -Path $ompConfigDir -Force | Out-Null
    }

    # Download theme
    Write-Info "Downloading oh-my-posh theme..."
    $themeUrl = "https://raw.githubusercontent.com/kelomai/bellows/main/cli/bellows.omp.json"
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
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart PowerShell to load the new prompt" -ForegroundColor White
Write-Host "  2. Sign into Microsoft 365 and OneDrive" -ForegroundColor White
Write-Host "  3. Configure 1Password" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  winget upgrade --all     # Update all packages" -ForegroundColor Gray
Write-Host ""
