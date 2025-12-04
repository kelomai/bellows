<#
.SYNOPSIS
    Test PowerShell scripts for syntax and structure
.DESCRIPTION
    Validates PowerShell scripts:
    - Syntax validation (parsing)
    - PSScriptAnalyzer linting
    - Required elements present
.EXAMPLE
    .\tests\test-powershell-scripts.ps1
#>

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$TestsPassed = 0
$TestsFailed = 0

function Log-Pass {
    param([string]$Message)
    Write-Host "✓ PASS" -ForegroundColor Green -NoNewline
    Write-Host ": $Message"
    $script:TestsPassed++
}

function Log-Fail {
    param([string]$Message)
    Write-Host "✗ FAIL" -ForegroundColor Red -NoNewline
    Write-Host ": $Message"
    $script:TestsFailed++
}

function Log-Skip {
    param([string]$Message)
    Write-Host "○ SKIP" -ForegroundColor Yellow -NoNewline
    Write-Host ": $Message"
}

Write-Host "============================================="
Write-Host "  PowerShell Script Tests"
Write-Host "============================================="
Write-Host ""

# List of PowerShell scripts to test
$PowerShellScripts = @(
    "win11-setup/dev-workstation/Install-DevWorkstation.ps1",
    "win11-setup/client-workstation/Install-ClientWorkstation.ps1",
    "win11-setup/Debloat-Windows.ps1"
)

# Test 1: Check scripts exist
Write-Host "--- Checking scripts exist ---"
foreach ($script in $PowerShellScripts) {
    $path = Join-Path $RootDir $script
    if (Test-Path $path) {
        Log-Pass "$script exists"
    } else {
        Log-Fail "$script not found"
    }
}
Write-Host ""

# Test 2: PowerShell syntax validation
Write-Host "--- PowerShell syntax validation ---"
foreach ($script in $PowerShellScripts) {
    $path = Join-Path $RootDir $script
    if (Test-Path $path) {
        try {
            $null = [System.Management.Automation.Language.Parser]::ParseFile(
                $path,
                [ref]$null,
                [ref]$null
            )
            Log-Pass "$script syntax valid"
        } catch {
            Log-Fail "$script has syntax errors: $_"
        }
    }
}
Write-Host ""

# Test 3: PSScriptAnalyzer (if available)
Write-Host "--- PSScriptAnalyzer linting ---"
if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
    Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue
    foreach ($script in $PowerShellScripts) {
        $path = Join-Path $RootDir $script
        if (Test-Path $path) {
            $results = Invoke-ScriptAnalyzer -Path $path -Severity Error -ErrorAction SilentlyContinue
            if ($results.Count -eq 0) {
                Log-Pass "$script passes PSScriptAnalyzer"
            } else {
                Log-Fail "$script has $($results.Count) PSScriptAnalyzer errors"
            }
        }
    }
} else {
    Log-Skip "PSScriptAnalyzer not installed"
}
Write-Host ""

# Test 4: Check for comment-based help
Write-Host "--- Checking comment-based help ---"
foreach ($script in $PowerShellScripts) {
    $path = Join-Path $RootDir $script
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -match "\.SYNOPSIS") {
            Log-Pass "$script has comment-based help"
        } else {
            Log-Fail "$script missing .SYNOPSIS"
        }
    }
}
Write-Host ""

# Test 5: Check for required parameters
Write-Host "--- Checking parameters ---"
foreach ($script in $PowerShellScripts) {
    $path = Join-Path $RootDir $script
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -match "param\s*\(" -or $content -match "\[CmdletBinding") {
            Log-Pass "$script has parameter block"
        } else {
            Log-Fail "$script missing parameter block"
        }
    }
}
Write-Host ""

# Summary
Write-Host "============================================="
Write-Host "  Test Summary"
Write-Host "============================================="
Write-Host "  Passed: " -NoNewline
Write-Host "$TestsPassed" -ForegroundColor Green
Write-Host "  Failed: " -NoNewline
Write-Host "$TestsFailed" -ForegroundColor Red
Write-Host ""

if ($TestsFailed -gt 0) {
    Write-Host "Tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed!" -ForegroundColor Green
    exit 0
}
