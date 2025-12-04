# 🎛️ Customizing Bellows

Learn how to customize Bellows to fit your team's specific needs. Add tools, remove bloat, or create entirely new workstation profiles.

---

## 🏗️ How Bellows Works

Bellows uses a **manifest-driven architecture** that separates configuration from logic:

```
┌─────────────────────────────────────────────────────────────────┐
│                        🔥 BELLOWS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   📄 packages.json          →     🔧 install-*.sh/.ps1          │
│   (What to install)               (How to install)             │
│                                                                 │
│   ┌─────────────────┐             ┌─────────────────┐          │
│   │ • taps          │             │ • Read manifest │          │
│   │ • casks         │      →      │ • Parse JSON    │          │
│   │ • formulae      │             │ • Install each  │          │
│   │ • vscode_ext    │             │ • Configure     │          │
│   │ • mas_apps      │             │ • Report status │          │
│   └─────────────────┘             └─────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| 📄 **Manifest** | JSON file defining what packages to install |
| 🔧 **Script** | Bash/PowerShell that reads manifest and installs packages |
| 📦 **Categories** | Logical groupings within the manifest (browsers, languages, etc.) |
| 🔄 **Idempotent** | Scripts can be run multiple times safely |

---

## 📄 Package Manifest Structure

Each workstation type has a `packages.json` manifest file. Here's the complete schema:

### 🍎 macOS Manifest (`packages.json`)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$comment": "Description of this workstation profile",

  "taps": [
    "hashicorp/tap",
    "jandedobbeleer/oh-my-posh"
  ],

  "casks": {
    "browsers": ["firefox", "google-chrome"],
    "development": ["visual-studio-code", "docker-desktop"],
    "ai_llm": ["ollama", "lm-studio"]
  },

  "formulae": {
    "core": ["git", "gh", "curl"],
    "languages": ["python@3.13", "node", "go"]
  },

  "mas_apps": {
    "497799835": "Xcode",
    "441258766": "Magnet"
  },

  "vscode_extensions": [
    "ms-python.python",
    "github.copilot"
  ],

  "zsh_plugins": [
    "zsh-users/zsh-autosuggestions"
  ],

  "pipx_packages": [
    "poetry",
    "httpie"
  ],

  "ollama_models": {
    "default": ["llama3.2:3b"],
    "coding": ["qwen2.5-coder:32b"]
  }
}
```

### 📦 Manifest Sections Explained

| Section | Description | Example |
|---------|-------------|---------|
| 🍺 `taps` | Homebrew tap repositories | `"hashicorp/tap"` |
| 📦 `casks` | GUI applications (grouped by category) | `"visual-studio-code"` |
| 🧪 `formulae` | CLI tools (grouped by category) | `"git"`, `"python@3.13"` |
| 🍎 `mas_apps` | Mac App Store apps (ID → Name) | `"497799835": "Xcode"` |
| 💻 `vscode_extensions` | VS Code extension IDs | `"ms-python.python"` |
| 🐚 `zsh_plugins` | oh-my-zsh plugins (GitHub repos) | `"zsh-users/zsh-autosuggestions"` |
| 📦 `pipx_packages` | Python CLI tools via pipx | `"poetry"` |
| 🤖 `ollama_models` | LLM models for Ollama | `"llama3.2:3b"` |

---

## ✏️ Customization Examples

### ➕ Adding a New Package

**Add a Homebrew cask (GUI app):**

```json
"casks": {
  "development": [
    "visual-studio-code",
    "docker-desktop",
    "postman"           // ← Add new app here
  ]
}
```

**Add a Homebrew formula (CLI tool):**

```json
"formulae": {
  "core": [
    "git",
    "gh",
    "jq"               // ← Add new tool here
  ]
}
```

**Add a VS Code extension:**

```json
"vscode_extensions": [
  "ms-python.python",
  "bradlc.vscode-tailwindcss"   // ← Add extension ID
]
```

### ➖ Removing a Package

Simply delete the line from the manifest:

```json
"casks": {
  "communication": [
    "slack",
    // "telegram",     // ← Removed (or just delete the line)
    "whatsapp"
  ]
}
```

### 📁 Adding a New Category

Create a new category within `casks` or `formulae`:

```json
"casks": {
  "browsers": [...],
  "development": [...],
  "security": [           // ← New category!
    "1password",
    "little-snitch",
    "micro-snitch"
  ]
}
```

### 🤖 Customizing Ollama Models

The LLM workstation supports categorized Ollama models:

```json
"ollama_models": {
  "default": [
    "llama3.2:3b"           // Always installed
  ],
  "coding": [
    "qwen2.5-coder:32b",    // Best for code
    "deepseek-coder-v2:16b"
  ],
  "general": [
    "llama3.3:70b-instruct-q4_K_M"  // Large general-purpose
  ],
  "fast": [
    "llama3.2:3b",          // Quick responses
    "qwen2.5-coder:7b"
  ]
}
```

---

## 🏭 Creating a Custom Profile

### Step 1: Copy an Existing Profile

```bash
# Create a new workstation type
cp -r mac-setup/dev-workstation mac-setup/data-science-workstation
```

### Step 2: Customize the Manifest

Edit `packages.json` to add data science tools:

```json
{
  "$comment": "Mac Data Science Workstation",

  "casks": {
    "data_science": [
      "anaconda",
      "jupyter-notebook-viewer",
      "db-browser-for-sqlite"
    ]
  },

  "formulae": {
    "data_science": [
      "jupyterlab",
      "pandas",
      "numpy"
    ]
  },

  "pipx_packages": [
    "jupyter",
    "pandas",
    "scikit-learn",
    "matplotlib"
  ]
}
```

### Step 3: Update the Script Header

Edit the script to reference your new profile:

```bash
# install-data-science-workstation.sh

# Remote URL:
#   curl -fsSL https://raw.githubusercontent.com/YOUR-ORG/bellows/main/mac-setup/data-science-workstation/install-data-science-workstation.sh | bash
```

---

## 🔍 Finding Package Names

### 🍺 Homebrew Packages

```bash
# Search for casks (GUI apps)
brew search --cask postman

# Search for formulae (CLI tools)
brew search terraform

# Get package info
brew info visual-studio-code
```

### 🍎 Mac App Store Apps

```bash
# Search Mac App Store (requires mas)
mas search Xcode

# List installed apps with IDs
mas list
```

### 💻 VS Code Extensions

```bash
# List installed extensions
code --list-extensions

# Search marketplace: https://marketplace.visualstudio.com/
```

### 🌐 Edge Extensions

Find extension IDs from the Edge Add-ons store URL:
```
https://microsoftedge.microsoft.com/addons/detail/ublock-origin/odfafepnkmbhccpbejgmiehpchacaeak
                                                              └── This is the extension ID ──┘
```

---

## 🧪 Testing Your Changes

### 🏃 Dry Run Mode

Test without installing anything:

```bash
# macOS
./install-dev-workstation.sh --dry-run

# Windows
.\Install-DevWorkstation.ps1 -DryRun
```

### ✅ Validate JSON Syntax

```bash
# Check for JSON errors
jq . packages.json > /dev/null && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

# Pretty-print to verify structure
jq . packages.json
```

### 🧪 Run Tests

```bash
# Bash script validation
./tests/test-bash-scripts.sh

# PowerShell script validation
pwsh ./tests/test-powershell-scripts.ps1
```

---

## 🔄 Keeping Manifests Updated

### 📥 Update All Packages

After customizing, you can update all installed packages:

```bash
# macOS
brew update && brew upgrade && brew upgrade --cask

# Ubuntu
wget -qO- https://raw.githubusercontent.com/kelomai/bellows/main/ubuntu-setup/update.sh | bash
```

### 🔍 Check for Outdated Packages

```bash
# Homebrew
brew outdated

# pipx
pipx upgrade-all

# VS Code extensions
code --list-extensions --show-versions
```

---

## 💡 Tips & Best Practices

### ✅ Do

- 📝 **Comment your changes** - Add `$comment` fields to document custom additions
- 🧪 **Test with dry-run first** - Validate before installing
- 📂 **Group related packages** - Keep categories logical and organized
- 🔄 **Pin versions when needed** - Use `"python@3.13"` instead of `"python"` for stability

### ❌ Don't

- 🚫 **Don't remove core tools** - Things like `git`, `jq`, `curl` are needed by the scripts
- 🚫 **Don't mix platforms** - macOS manifests won't work on Windows
- 🚫 **Don't use trailing commas** - JSON doesn't allow them

---

## 🤝 Contributing Custom Profiles

Have a useful workstation profile? Consider contributing it back!

1. 🍴 Fork the repository
2. 📁 Add your profile to the appropriate `*-setup/` folder
3. 📄 Document it in `docs/`
4. 🧪 Test with `--dry-run`
5. 📤 Open a Pull Request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

---

## 📚 Related Documentation

- 🔥 [Main README](../README.md) - Project overview
- 🍎 [Mac Dev Workstation](mac-dev-workstation.md) - Standard Mac setup
- 🤖 [Mac LLM Workstation](mac-llm-workstation.md) - AI/ML focused setup
- 🐧 [Ubuntu Headless](ubuntu-headless.md) - CLI-only setup
- 🪟 [Windows Dev Workstation](win11-dev-workstation.md) - Windows setup
