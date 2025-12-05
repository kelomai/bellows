# Claude Code Preferences

## Git Operations

- **NEVER push without explicit consent** - Always ask before pushing, even after commits
- Commit frequently with clear, descriptive messages
- Use conventional commit style when appropriate

## Code Style

- Scripts should be fully automated with no interactive prompts
- Suppress non-critical errors cleanly (use try/catch, proper redirects)
- Check if items exist before trying to remove/disable them
- Keep output clean - users shouldn't see harmless "not found" warnings

## Branding

- Use Kelomai branding in scripts:
  - Author: 🧙‍♂️ Kelomai (https://kelomai.io)
  - Box characters for banners: ╔═╗║╚╝╠╣
  - Welcome/closing messages with emojis

## Communication

- Be concise - short responses preferred
- Ask before making major architectural decisions
- Test changes incrementally when possible

## Project Structure

- This repo contains workstation setup scripts for:
  - macOS (mac-setup/)
  - Windows 11 (win11-setup/)
  - Ubuntu (ubuntu-setup/)
- Package manifests are in packages.json files, separate from install scripts
