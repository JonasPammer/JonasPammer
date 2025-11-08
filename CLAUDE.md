# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal GitHub profile repository containing:
- GitHub profile README (README.adoc in AsciiDoc format)
- Personal documentation (JOURNEY.adoc, SETUP.adoc)
- Educational/Blog articles (`./demystifying`)
- Windows PC provisioning scripts (`./provisioner-windows`)
- Automated GitHub metrics via GitHub Actions

## Development Commands

### Initial Setup
```bash
# Install pre-commit hooks
pip install -r requirements-dev.txt
pre-commit install

# Validate YAML files
pre-commit run yamllint --all-files
```

### GitHub Actions
```bash
# Manually trigger metrics workflow
gh workflow run metrics.yml

# View workflow status
gh run list --workflow=metrics.yml
```

### PowerShell Script Execution
```powershell
# Required before running any provisioning scripts
Set-ExecutionPolicy Bypass -Scope Process -Force

# Bootstrap (initial PC setup from fresh Windows)
Invoke-Expression ((New-Object net.webclient).DownloadString('https://raw.githubusercontent.com/JonasPammer/JonasPammer/master/provisioner-windows/bootstrap.ps1'))

# Main automated setup (run from provisioner-windows directory)
./pc-setup.ps1

# Semi-automated setup (requires user interaction)
./pc-setup-other.ps1

# Repair Windows issues
./pc-repair.ps1
```

## Architecture & Key Concepts

### Document Format
All primary documentation uses **AsciiDoc** (.adoc), not Markdown:
- AsciiDoc syntax: `= Heading`, `== Subheading`, `link:url[text]`
- README.adoc is the main GitHub profile page
- Supports collapsible sections, image embedding, rich formatting
- Cross-references: `@provisioner-windows/README.adoc`

### Windows Provisioner System

**Dependencies & Flow:**
1. All scripts import `utils.ps1` for shared functions (Show-Output, InitializeYAMLConfig, etc.)
2. Configuration cascade: `config.yml` (git-ignored) ← `config.example.yml`
3. Application management via `applications.yml` validated against `applications.schema.json`
4. Scripts create `downloads/` and `logs/` directories for artifacts

**Script Dependencies:**
- `bootstrap.ps1`: Standalone, installs Chocolatey → Git → clones repo
- `pc-setup.ps1`: Requires utils.ps1, config.yml, applications.yml
- `pc-setup-other.ps1`: Requires 1Password CLI (`op`), user interaction for GPG/SSH
- `pc-repair.ps1`: Windows repair utilities, requires admin privileges

**Application Management:**
- `applications.yml`: Custom, Schema-validated, Declarative list using Chocolatey, Winget, or custom installers

### Educational Articles (`./demystifying`)
Self-contained AsciiDoc articles explaining complex topics:
- `conventional_commits.adoc` - Commit message standards
- `linters_and_formatters.adoc` - Code quality tools
- `module_bundlers.adoc` - JavaScript bundling concepts
- `transpilers.adoc` - Language compilation/transformation

### GitHub Actions Workflows

**Metrics Workflow (`.github/workflows/metrics.yml`):**
- Triggers: Daily at midnight UTC, push to master, manual dispatch
- Dependencies: `METRICS_TOKEN` and `WAKATIME_TOKEN` repository secrets
- Output: Updates `github-metrics.svg` with auto-commit
- Skip CI: Uses `[skip ci]` in commit message to prevent recursive triggers

## Commit Message Convention

Follow conventional commits:
- `docs:` - Documentation changes
- `chore:` - Maintenance (especially "chore: update metrics [skip ci]")
- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code restructuring
- Append `[skip ci]` to prevent GitHub Actions runs

**AI-specific requirement:** When making commits, ALWAYS include "(ai)" after the type prefix to identify AI-generated commits.

## Pre-commit Hooks

Configured checks:
- **File conflicts:** check-case-conflict, check-symlinks
- **Line endings:** mixed-line-ending, trailing-whitespace
- **Security:** detect-secrets (excludes .cruft.json)
- **YAML validation:** yamllint with custom config (.yamllint)

Run manually: `pre-commit run --all-files`