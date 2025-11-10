# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal GitHub profile repository containing:
- GitHub profile README (README.adoc in AsciiDoc format)
- Personal documentation (JOURNEY.adoc, SETUP.adoc)
- Educational/Blog articles (`./demystifying`)
- Windows PC provisioning scripts (`./provisioner-windows`)
- Hugo + AsciiDoc blog (`./blog`)
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

### Hugo Blog Development
```bash
cd blog

# Start Kroki containers before building (required for diagram generation)
docker-compose up -d

# Start local development server
hugo server --buildDrafts --disableFastRender

# Create new post (choose based on needs):
hugo new posts/YYYY-MM-DD-title.adoc # Text-only post (single file, named after post)
hugo new posts/YYYY-MM-DD-title/index.adoc # Image-heavy post (page bundle, images in same folder)

hugo --gc --minify # Build for production

# Stop Kroki containers (optional after build)
docker-compose down
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

### Hugo + AsciiDoc Blog (`./blog`)

**Tech Stack:**
- Hugo Extended (static site generator)
- Asciidoctor (semantic markup with native diagram support)
- GitHub Pages (deployment target)
- GitHub Actions (automated build and deploy)
- Minimalist theme (Git submodule: `blog/themes/PaperMod`)

**Key Features:**
- Client-Side search
- Giscus comments (GitHub Discussions)
- Syntax highlighting (light/dark) 
- Copy-to-clipboard buttons on code blocks (hover to reveal)
- PWA support
- Reading time estimates
- Less important: Lightbox (images/videos), Image gallery, YouTube embeds (privacy-friendly), Codepen embeds, Share buttons

**File Structure:**
```
                                        #
blog/
├── config.toml                         # Hugo + AsciiDoc configuration
├── Gemfile                             # Asciidoctor dependencies
├── content/
│   ├── posts/
│   │   ├── my-text-post.adoc           # Single file (text-only posts)
│   │   └── image-heavy-post/           # Page bundle (with images)
│   │       ├── index.adoc
│   │       ├── image1.jpg
│   │       └── image2.jpg
│   ├── about.adoc
│   └── search.md
├── layouts/
│   ├── _default/
│   │   └── index.json                   # Search index generator
│   ├── partials/                        # head-end, footer-end, giscus, etc.
│   ├── shortcodes/                      # image-gallery, youtube, codepen
│   └── search/
├── static/
│   ├── js/
│   │   ├── lightbox.js
│   │   └── copy-to-clipboard.js         # From Asciidoctor Docs UI
│   └── css/
│       ├── lightbox.css
│       └── copy-button.css              # From Asciidoctor Docs UI
└── themes/PaperMod/                     # Git submodule
```

**Hybrid Post Structure:**

Hugo supports two content organization approaches (see [official documentation](https://gohugo.io/content-management/page-bundles/)):

- **Single-file pages**: Create as standalone `.adoc` files (e.g., `posts/2025-01-15-my-thoughts.adoc`)
  - Simple, flat structure with file named after post
  - Best for: Text-only articles, posts using external/remote images
  - Resources must be in `static/` folder

- **Leaf bundles**: Create as directories with `index.adoc` (e.g., `posts/2025-01-15-gallery/index.adoc`)
  - Groups content and resources (images, PDFs) together
  - Best for: Tutorials with screenshots, photo galleries, posts with many local images
  - Resources accessible via Hugo's `.Resources` method for image processing

Reference: https://gohugo.io/content-management/organization/ and https://gohugo.io/content-management/page-bundles/

**Source Verification:**

Never hallucinate code. Always use `git clone` + `cp` commands to fetch real implementations.

All source files include single-line attribution: `{{/* Source: https://... */}}` or `// Source: https://...`

**Code Blocks:**

Features:
- Hover to reveal copy button in top-right corner
- Smart console command extraction (strips `$` prompts, joins with `&&`)
- Language label display (e.g., "BASH | 📋")
- Conditional disable via `role="nocopy"` attribute

**Diagram Support:**

The blog uses Kroki for diagram generation. **Historical Context:**

**Original Problem (Resolved):**
1. `asciidoctor-diagram-plantuml` gem was broken with Java reflection error:
   ```
   Cannot invoke java.lang.reflect.Method.invoke because
   org.asciidoctor.diagram.plantuml.PlantUML.SET_LOCAL_IMAGE_LIMIT is null
   ```
2. Diagrams were generating in wrong location (blog root instead of `static/diagrams/`)

**Solution Implemented:**
- Use Kroki server (Docker containers) for ALL diagram types
- **Gemfile:** `asciidoctor-kroki` (NOT `asciidoctor-diagram` or `asciidoctor-diagram-plantuml`)
- **docker-compose.yml:** 4 services (kroki + mermaid + excalidraw)
- **config.toml:**
  - Extension: `asciidoctor-kroki`
  - Attributes: `kroki-server-url = "http://localhost:8000"`, `kroki-fetch-diagram = true`
  - Diagram output: `imagesoutdir = "static/diagrams"`, `imagesdir = "/blog/diagrams"`
- **Gitignored:** `/static/diagrams/` (regenerated at build time)

**Syntax Highlighting:**
- Asciidoctor uses Rouge for syntax highlighting (`source-highlighter = "rouge"`)
- Theme: `rouge-style = "github"` (GitHub's syntax colors)
- Rendering: `rouge-css = "style"` (inline styles, no external CSS needed)
- Inline styles avoids needing to generate and commit rougify's CSS files for specific theme for all

**Deployment:**
- Automatic via GitHub Actions on push to master
- Workflow uses peaceiris/actions-hugo@v3 and ruby/setup-ruby@v1

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