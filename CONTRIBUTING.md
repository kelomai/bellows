# 🤝 Contributing to Bellows

Thank you for your interest in contributing to Bellows! This document provides guidelines and instructions for contributing.

## 📜 Code of Conduct

Be respectful, inclusive, and constructive. We welcome contributors of all experience levels.

## 💻 System Requirements

Bellows scripts are designed for and tested on:

| Platform | Minimum Version |
|----------|-----------------|
| 🍎 **macOS** | 26+ (Tahoe) |
| 🐧 **Ubuntu** | 25+ (Plucky Puffin) |
| 🪟 **Windows** | 11 |
| ⚡ **PowerShell** | Core 7.5.4+ |

> **Note:** PowerShell scripts require PowerShell Core (pwsh), not Windows PowerShell 5.x.

## 🚀 How to Contribute

### 🐛 Reporting Issues

1. Check existing issues to avoid duplicates
2. Use a clear, descriptive title
3. Include:
   - OS and version (Windows 11, macOS, Ubuntu)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs or screenshots

### 📝 Submitting Changes

1. **Fork** the repository
2. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```
3. **Make your changes** following our coding standards
4. **Test** your changes thoroughly
5. **Commit** with clear messages:
   ```bash
   git commit -m "Add: description of new feature"
   git commit -m "Fix: description of bug fix"
   git commit -m "Update: description of update"
   ```
6. **Push** to your fork
7. **Open a Pull Request** with:
   - Clear description of changes
   - Reference to related issues
   - Screenshots if applicable

## 📋 Coding Standards

### 🪟 PowerShell Scripts

- **Target PowerShell Core 7.5.4+** (not Windows PowerShell 5.x)
- Add `#Requires -Version 7.5` at the top of scripts
- Use `#Requires -RunAsAdministrator` when needed
- Include proper help documentation (`.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`)
- Follow PowerShell naming conventions (Verb-Noun)
- Use `$ErrorActionPreference = "Continue"` for graceful error handling
- Support `-DryRun` parameter for previewing changes

### 🐧 Bash Scripts

- Include shebang: `#!/usr/bin/env bash`
- Use `set -euo pipefail` for strict mode
- Support `--dry-run` flag
- Use functions for modularity
- Include clear logging with color output

### ⚙️ General Guidelines

- Keep scripts idempotent (safe to run multiple times)
- Check for existing installations before installing
- Provide clear, actionable error messages
- Support both interactive and automated execution
- Document all parameters and flags

## 📂 Project Structure

```
bellows/
├── mac-setup/                    # macOS workstation setup
│   ├── llm-workstation/          # LLM workstation setup
│   └── dev-workstation/          # Dev workstation setup
├── win11-setup/                  # Windows 11 workstation setup
│   ├── Debloat-Windows.ps1       # Windows debloat script
│   ├── dev-workstation/          # Developer setup
│   └── client-workstation/       # Client/business setup
├── ubuntu-setup/                 # Ubuntu workstation setup
│   ├── dev-workstation/          # Desktop setup
│   └── headless/                 # CLI-only setup
├── cli/                          # Shell themes and configs
├── docs/                         # Documentation
├── tests/                        # Script validation tests
├── LICENSE                       # MIT License
├── CONTRIBUTING.md               # This file
└── README.md                     # Project overview
```

## 🧪 Testing

Before submitting a PR:

1. **Dry run** your scripts to ensure they preview correctly
2. **Test on a fresh VM** when possible
3. **Verify idempotency** by running scripts multiple times
4. **Check for regressions** in existing functionality

### Testing with Forks and Feature Branches

All install scripts support `--repo` and `--branch` flags to fetch remote resources (like `packages.json`) from your fork and branch instead of `kelomai/bellows:main`. This allows contributors to test changes before submitting a PR.

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--repo <org/repo>` | `kelomai/bellows` | GitHub repository (supports forks) |
| `--branch <branch>` | `main` | Git branch name |

**Testing from your fork:**

```bash
# 1. Fork the repo on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/bellows.git
cd bellows

# 2. Create and push your feature branch
git checkout -b feature/my-changes
git add .
git commit -m "Add: my changes"
git push -u origin feature/my-changes

# 3. Test remote install from your fork
# macOS:
curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/bellows/feature/my-changes/mac-setup/dev-workstation/install-dev-workstation.sh | bash -s -- --repo YOUR-USERNAME/bellows --branch feature/my-changes

# Ubuntu:
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/bellows/feature/my-changes/ubuntu-setup/dev-workstation/install-dev-workstation.sh | bash -s -- --repo YOUR-USERNAME/bellows --branch feature/my-changes

# Or run locally with flags:
./mac-setup/dev-workstation/install-dev-workstation.sh --repo YOUR-USERNAME/bellows --branch feature/my-changes
```

**Windows (PowerShell):**

```powershell
# Test from your fork
.\win11-setup\dev-workstation\Install-DevWorkstation.ps1 -Repo "YOUR-USERNAME/bellows" -Branch "feature/my-changes"

# Or for maintainers testing from kelomai repo
.\win11-setup\dev-workstation\Install-DevWorkstation.ps1 -Branch "feature/my-changes"
```

**Testing from kelomai repo (maintainers):**

```bash
# For branches on the main repo, only -Branch is needed
./mac-setup/dev-workstation/install-dev-workstation.sh --branch feature/my-changes
```

**What these flags do:**

- `--repo` sets the GitHub org/repo for fetching remote resources
- `--branch` sets the branch name
- Remote resources (`packages.json`, themes, etc.) are fetched from the specified repo/branch
- Allows full end-to-end testing without merging to main

## 🔄 Pull Request Process

1. Update documentation if needed
2. Update READMEs for any changed scripts
3. Ensure all tests pass
4. Request review from maintainers
5. Address feedback promptly

## ➕ Adding New Scripts

When adding a new setup script:

1. Follow the existing naming conventions
2. Include comprehensive help documentation
3. Support dry-run mode
4. Add entry to relevant README
5. Update the main project README if needed

## ❓ Questions?

- Open an issue for questions about contributing
- Tag it with `question` label

🙏 Thank you for contributing to Bellows!
