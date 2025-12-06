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
    - Microsoft 365 (Office, OneDrive, PowerShell 7)
    - Productivity (1Password)
    - Utilities (7-Zip)

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

    # Check for packages.json in script directory (only works when run from file, not irm | iex)
    $scriptName = $MyInvocation.ScriptName
    if ($scriptName) {
        $scriptDir = Split-Path -Parent $scriptName
    }
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
        [string]$Name,
        [int]$Current,
        [int]$Total
    )

    $progress = "[$Current/$Total]"

    if ($DryRun) {
        Write-Info "$progress [DRY RUN] Would install: $Name ($Id)"
        return
    }

    Write-Host "  $progress $Name ... " -ForegroundColor Cyan -NoNewline

    # Run winget synchronously (inherits admin privileges, no UAC prompts)
    $output = winget install --id $Id --accept-package-agreements --accept-source-agreements --silent 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "Done" -ForegroundColor Green
    }
    elseif ($output -match "already installed") {
        Write-Host "Already installed" -ForegroundColor DarkGray
    }
    else {
        Write-Host "Failed" -ForegroundColor Yellow
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
Write-Step "[1/3] Loading package manifest..."
$manifest = Get-PackageManifest -LocalPath $ManifestPath -RemoteUrl $GithubManifestUrl
Write-Success "Package manifest loaded"

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

# Check for winget
Write-Step "[2/3] Checking winget..."
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-Success "winget available"

# Install Applications
Write-Step "[3/3] Installing applications..."

# Collect all packages first to show total count
$allPackages = @()
$categories = @("browsers", "microsoft", "productivity", "utilities")
foreach ($category in $categories) {
    $packages = $manifest.winget.$category
    if ($packages) {
        $allPackages += $packages
    }
}

$totalPackages = $allPackages.Count
Write-Info "Found $totalPackages packages to install"
Write-Host ""

$current = 0
foreach ($pkg in $allPackages) {
    $current++
    Install-WingetPackage -Id $pkg.id -Name $pkg.name -Current $current -Total $totalPackages
}

# =============================================================================
# COMPLETE
# =============================================================================
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║     ✅ Setup complete!                                  ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║  Next steps:                                            ║" -ForegroundColor DarkGray
Write-Host "║    1. Sign into Microsoft 365 and OneDrive              ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" -ForegroundColor DarkGray
Write-Host "║              https://kelomai.io                         ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
