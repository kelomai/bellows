#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Install-DevWorkstation.ps1 - Windows 11 Developer Workstation Setup
.DESCRIPTION
    Automated setup script for a Windows 11 development workstation.
    Installs development tools, programming languages, containers, and local LLM stack.

    Includes:
    - Development tools (VS Code, Git, Docker, etc.)
    - Programming languages (Python, Node.js, Go, .NET, Java)
    - Infrastructure as Code (Terraform, Packer)
    - Cloud tools (Azure CLI, kubectl, Helm)
    - Local LLM stack (Ollama, LM Studio)
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
    .\Install-DevWorkstation.ps1
    Run the full installation interactively
.EXAMPLE
    .\Install-DevWorkstation.ps1 -DryRun
    Preview all installations without making changes
.EXAMPLE
    .\Install-DevWorkstation.ps1 -ManifestPath .\my-packages.json
    Use a custom package manifest
.EXAMPLE
    .\Install-DevWorkstation.ps1 -Repo "myuser/bellows" -Branch "my-feature"
    Test from a forked repo and branch
.LINK
    https://github.com/kelomai/bellows
.NOTES
    Author: 🧙‍♂️ Kelomai (https://kelomai.io)
    License: MIT

    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/dev-workstation/Install-DevWorkstation.ps1 | iex
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
$GithubManifestUrl = "https://raw.githubusercontent.com/$Repo/$Branch/win11-setup/dev-workstation/packages.json"

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
Write-Host "║     Windows 11 Dev Workstation Setup        ║" -ForegroundColor DarkGray
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
Write-Step "[1/8] Loading package manifest..."
$manifest = Get-PackageManifest -LocalPath $ManifestPath -RemoteUrl $GithubManifestUrl
Write-Success "Package manifest loaded"

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

# Check for winget
Write-Step "[2/8] Checking winget..."
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-Success "winget available"

# Collect all packages first to show total count
$allPackages = @()
$guiCategories = @("browsers", "development", "ai_llm", "communication", "microsoft_azure", "productivity", "fonts")
$cliCategories = @("cli_core", "cli_languages", "cli_iac", "cli_kubernetes", "cli_azure", "cli_database", "cli_shell")

foreach ($category in ($guiCategories + $cliCategories)) {
    $packages = $manifest.winget.$category
    if ($packages) {
        $allPackages += $packages
    }
}

$totalPackages = $allPackages.Count

# Install GUI Applications
Write-Step "[3/8] Installing GUI applications..."
Write-Info "Found $totalPackages total packages to install"
Write-Host ""

$current = 0
foreach ($category in $guiCategories) {
    $packages = $manifest.winget.$category
    if ($packages) {
        foreach ($pkg in $packages) {
            $current++
            Install-WingetPackage -Id $pkg.id -Name $pkg.name -Current $current -Total $totalPackages
        }
    }
}

# Install CLI Tools
Write-Step "[4/8] Installing CLI tools..."
foreach ($category in $cliCategories) {
    $packages = $manifest.winget.$category
    if ($packages) {
        foreach ($pkg in $packages) {
            $current++
            Install-WingetPackage -Id $pkg.id -Name $pkg.name -Current $current -Total $totalPackages
        }
    }
}

# =============================================================================
# LOCAL LLM SETUP
# =============================================================================
Write-Step "[5/8] Setting up Local LLM stack..."

if ($DryRun) {
    Write-Info "[DRY RUN] Would install Ollama and LM Studio"
}
else {
    Write-Success "Ollama and LM Studio installed (see end instructions for model downloads)"
}

# =============================================================================
# PYTHON SETUP
# =============================================================================
Write-Step "[6/8] Configuring Python environment..."

if ($DryRun) {
    Write-Info "[DRY RUN] Would install pipx and poetry"
}
else {
    # Refresh PATH to pick up newly installed tools (Python, etc.)
    Write-Info "Refreshing PATH..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Check if Python is available
    if (!(Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Warn "Python not found in PATH. You may need to restart PowerShell and run pipx setup manually."
    }
    else {
        # Install pipx
        if (Get-Command pipx -ErrorAction SilentlyContinue) {
            Write-Success "pipx already installed"
        }
        else {
            Write-Info "Installing pipx..."
            python -m pip install --user pipx 2>$null
            python -m pipx ensurepath 2>$null
            # Refresh PATH again after pipx ensurepath
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }

        # Install packages via pipx
        if ($manifest.pipx_packages -and (Get-Command pipx -ErrorAction SilentlyContinue)) {
            foreach ($pkg in $manifest.pipx_packages) {
                $pkgInstalled = pipx list 2>$null | Select-String $pkg
                if ($pkgInstalled) {
                    Write-Success "$pkg already installed"
                }
                else {
                    Write-Info "Installing $pkg..."
                    pipx install $pkg 2>$null
                }
            }
        }
    }
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh)
# =============================================================================
Write-Step "[7/8] Configuring PowerShell with oh-my-posh..."

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

# Aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform
Set-Alias -Name g -Value git

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
# VS CODE EXTENSIONS
# =============================================================================
Write-Step "[8/8] Installing VS Code extensions..."

if ($DryRun) {
    if ($manifest.vscode_extensions) {
        foreach ($ext in $manifest.vscode_extensions) {
            Write-Info "[DRY RUN] Would install extension: $ext"
        }
    }
}
else {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        if ($manifest.vscode_extensions) {
            foreach ($ext in $manifest.vscode_extensions) {
                Write-Info "Installing $ext..."
                code --install-extension $ext --force 2>$null
            }
        }
        Write-Success "VS Code extensions installed"
    }
    else {
        Write-Warn "VS Code CLI not found, skipping extensions"
    }
}

# =============================================================================
# COMPLETE
# =============================================================================
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║     ✅ Setup complete!                                  ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Restart PowerShell to load oh-my-posh" -ForegroundColor White
Write-Host ""
Write-Host "  2. Download a model for local LLM:" -ForegroundColor White
Write-Host ""
Write-Host "     Ollama:" -ForegroundColor Yellow
Write-Host "       ollama pull qwen2.5-coder:32b" -ForegroundColor Gray
Write-Host "       ollama pull llama3.2:3b" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Run your model:" -ForegroundColor White
Write-Host ""
Write-Host "       ollama serve              # Start the server" -ForegroundColor Gray
Write-Host "       ollama run qwen2.5-coder  # Chat with model" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Use with VS Code:" -ForegroundColor White
Write-Host "     - Continue extension is installed" -ForegroundColor Gray
Write-Host "     - Configure it to use Ollama at http://localhost:11434" -ForegroundColor Gray
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" -ForegroundColor DarkGray
Write-Host "║              https://kelomai.io                         ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
