<#
.SYNOPSIS
    Pester tests for Bellows PowerShell scripts
.DESCRIPTION
    Validates PowerShell scripts using Pester framework:
    - Syntax validation
    - PSScriptAnalyzer rules
    - Comment-based help presence
    - Required parameters
.EXAMPLE
    Invoke-Pester -Path ./tests/Bellows.Tests.ps1
#>

BeforeAll {
    $RootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    if (-not $RootDir) {
        $RootDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    }

    $PowerShellScripts = @(
        "win11-setup/dev-workstation/Install-DevWorkstation.ps1",
        "win11-setup/client-workstation/Install-ClientWorkstation.ps1",
        "win11-setup/Debloat-Windows.ps1"
    )
}

Describe "PowerShell Script Validation" {

    Context "Script Files Exist" {
        It "Should have <_> script file" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            $path | Should -Exist
        }
    }

    Context "Script Syntax" {
        It "Should have valid syntax in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $errors = $null
                $null = [System.Management.Automation.Language.Parser]::ParseFile(
                    $path,
                    [ref]$null,
                    [ref]$errors
                )
                $errors.Count | Should -Be 0
            }
        }
    }

    Context "Comment-Based Help" {
        It "Should have .SYNOPSIS in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                $content | Should -Match "\.SYNOPSIS"
            }
        }

        It "Should have .DESCRIPTION in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                $content | Should -Match "\.DESCRIPTION"
            }
        }

        It "Should have .EXAMPLE in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                $content | Should -Match "\.EXAMPLE"
            }
        }
    }

    Context "Script Structure" {
        It "Should have param block or CmdletBinding in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                ($content -match "param\s*\(" -or $content -match "\[CmdletBinding") | Should -BeTrue
            }
        }

        It "Should have proper shebang or header in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $firstLine = (Get-Content $path -First 1).Trim()
                # Should start with comment block or requires statement
                ($firstLine -match "^#" -or $firstLine -match "^<#") | Should -BeTrue
            }
        }
    }
}

Describe "PSScriptAnalyzer Rules" -Skip:(-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {

    BeforeAll {
        Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue
    }

    Context "No Critical Errors" {
        It "Should pass PSScriptAnalyzer error rules for <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $results = Invoke-ScriptAnalyzer -Path $path -Severity Error -ErrorAction SilentlyContinue
                $results.Count | Should -Be 0 -Because ($results | ForEach-Object { $_.Message } | Out-String)
            }
        }
    }

    Context "No Critical Warnings" {
        It "Should have minimal PSScriptAnalyzer warnings for <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $results = Invoke-ScriptAnalyzer -Path $path -Severity Warning -ErrorAction SilentlyContinue
                # Allow some warnings but flag if excessive
                $results.Count | Should -BeLessOrEqual 10 -Because "Too many warnings: $($results | ForEach-Object { $_.RuleName } | Out-String)"
            }
        }
    }
}

Describe "Script Content Validation" {

    Context "Security Checks" {
        It "Should not contain hardcoded credentials in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                $content | Should -Not -Match "password\s*=\s*['""][^'""]+['""]"
                $content | Should -Not -Match "secret\s*=\s*['""][^'""]+['""]"
            }
        }

        It "Should not use Invoke-Expression with user input in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $content = Get-Content $path -Raw
                # Check for dangerous patterns (Invoke-Expression with variables)
                $content | Should -Not -Match "Invoke-Expression\s+\`$"
            }
        }
    }

    Context "Best Practices" {
        It "Should use approved verbs in function names in <_>" -ForEach $PowerShellScripts {
            $path = Join-Path $RootDir $_
            if (Test-Path $path) {
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$null)
                $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

                $approvedVerbs = (Get-Verb).Verb
                foreach ($func in $functions) {
                    $verb = $func.Name -replace "-.*$"
                    if ($verb -ne $func.Name) {
                        # Only check if it looks like Verb-Noun format
                        $verb | Should -BeIn $approvedVerbs -Because "Function '$($func.Name)' uses unapproved verb '$verb'"
                    }
                }
            }
        }
    }
}
