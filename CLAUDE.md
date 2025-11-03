# CLAUDE.md

## Repository Overview

This is a personal GitHub profile repository containing:
- GitHub profile README (README.adoc in AsciiDoc format)
- Personal About-Me's (JOURNEY.adoc, SETUP.adoc)
- Educational/Blog articles (`./demystifying`)
- Windows PC provisioning scripts (`./provisioner-windows`)
- Automated GitHub metrics via GitHub Actions (`gh workflow run metrics.yml`)

### Documents Format
All primary documentation files use **AsciiDoc** (.adoc) format, not Markdown. When editing or creating documentation:
- Use AsciiDoc syntax (e.g., `= Heading`, `== Subheading`, `link:url[text]`)
- README.adoc is the main profile page displayed on GitHub
- Supports image embedding, collapsible sections, and rich formatting

### Windows Provisioner Scripts

The PowerShell provisioning system (`provisioner-windows/`) follows this structure:

**Configuration:**
- `config.yml` (git-ignored) - Runtime configuration, auto-created from `config.example.yml`
- `applications.yml` - Declarative list of applications to install/update
- `applications.schema.json` - JSON schema for application definitions

**Core Scripts:**
- `bootstrap.ps1` - Initial setup (installs Chocolatey, Git, clones repo)
- `pc-setup.ps1` - Main automated setup (Windows Update, applications, WSL, tweaks)
- `pc-setup-other.ps1` - Semi-automated tasks requiring user interaction (GPG, 1Password)
- `pc-repair.ps1` - Windows repair/troubleshooting utilities
- `utils.ps1` - Shared utility functions

**Setup Flow:**
1. Bootstrap → Install tooling → Clone repository
2. Main setup → System updates → Application installation → Configuration
3. Semi-automatic setup → Security/credential configuration
4. Manual post-setup → Sign-ins, license keys, OneDrive configuration

More Information: @provisioner-windows/README.adoc

### GitHub Actions Workflows

The `.github/workflows/metrics.yml` workflow:
- Runs daily at midnight (UTC) and on push to master
- Uses [lowlighter/metrics@latest](https://github.com/lowlighter/metrics) to generate `github-metrics.svg`
- Displays recent activity, starred repositories, and WakaTime coding stats
- Auto-commits with message "chore: update metrics [skip ci]"
- Requires `METRICS_TOKEN` and `WAKATIME_TOKEN` secrets

### Pre-commit Configuration

Configured hooks in `.pre-commit-config.yaml`:
- **General**: check-case-conflict, check-symlinks, mixed-line-ending, trailing-whitespace
- **Security**: detect-secrets (excludes .cruft.json)

### Commit Message Convention

Recent commits show a pattern of conventional commits:
- `docs:` for documentation changes
- `chore:` for maintenance tasks (especially metrics updates)
- Use `[skip ci]` suffix to prevent workflow runs for automated commits
