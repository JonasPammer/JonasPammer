# Hugo to Jekyll Migration Plan

**Date:** 2025-11-18
**Goal:** Migrate blog from Hugo to Jekyll for better Asciidoctor support, less boilerplate, and more community plugins

## Executive Summary

### Why Jekyll?

**Better Asciidoctor Integration:**
- Official `jekyll-asciidoc` plugin maintained by Asciidoctor team
- Native attribute promotion to front matter (no manual YAML parsing needed)
- Less CSS hacks required for Asciidoctor-generated HTML
- Direct support for Asciidoctor extensions

**Hugo's Limitations:**
- Requires external process execution with limited configuration
- No way to pass custom arguments to asciidoctor binary without wrapper scripts
- Issues with include directives, syntax highlighting, and admonition icons
- Global attributes must be defined in every `.adoc` file

**Community Ecosystem:**
- Mature plugin ecosystem (15+ years)
- Minimal Mistakes theme has 12k+ stars, actively maintained
- Better integration with GitHub Pages (native Ruby support)

## Theme Selection: Minimal Mistakes

**Features Included:**
- ✅ Search (Lunr.js)
- ✅ Comments (Giscus supported)
- ✅ Syntax highlighting (Rouge/Pygments)
- ✅ Reading time estimates
- ✅ Copy-to-clipboard (Clipboard.js)
- ✅ SEO optimization
- ✅ Responsive design
- ✅ Multiple color skins

**Requires Custom Implementation:**
- PWA support (manifest + service worker)
- Diagram support (asciidoctor-kroki extension)
- PhotoSwipe lightbox integration
- YouTube/Codepen embed shortcodes

## Migration Steps

### Phase 1: Project Setup

1. **Create new Jekyll project structure**
   ```bash
   cd blog-jekyll  # New directory
   bundle init
   ```

2. **Install dependencies**
   ```ruby
   # Gemfile
   gem "jekyll", "~> 4.3"
   gem "minimal-mistakes-jekyll"
   gem "jekyll-asciidoc"
   gem "asciidoctor"
   gem "asciidoctor-kroki"
   gem "rouge"
   gem "jekyll-include-cache"
   gem "jekyll-feed"
   gem "jekyll-sitemap"
   gem "jekyll-seo-tag"
   ```

3. **Configure _config.yml**
   - Set theme: minimal-mistakes-jekyll
   - Configure jekyll-asciidoc plugin
   - Set asciidoctor attributes (Kroki, Rouge)
   - Configure Minimal Mistakes features

### Phase 2: Content Migration

1. **Directory structure mapping**
   ```
   Hugo                          → Jekyll
   ────────────────────────────────────────
   blog/content/posts/           → _posts/
   blog/content/pages/           → _pages/
   blog/static/                  → assets/
   blog/layouts/                 → _includes/ + _layouts/
   ```

2. **Front matter transformation**
   - Hugo YAML → Jekyll YAML (mostly compatible)
   - Convert date format if needed
   - Map Hugo-specific variables to Jekyll equivalents

3. **AsciiDoc file migration**
   - Copy all `.adoc` files
   - Update image paths (static/images → /assets/images/)
   - Update internal links if necessary
   - Rename posts to Jekyll convention: YYYY-MM-DD-title.adoc

### Phase 3: Feature Parity

1. **Giscus Comments**
   - Configure in _config.yml
   - Minimal Mistakes has built-in Giscus support

2. **Search**
   - Enable Lunr search in Minimal Mistakes config
   - Create search.md page

3. **Copy-to-Clipboard**
   - Port existing copy-to-clipboard.js
   - Adapt for Jekyll's HTML structure
   - Include in _includes/head/custom.html

4. **Diagram Support (Kroki)**
   - Configure asciidoctor-kroki in _config.yml
   - Set imagesdir and imagesoutdir
   - Add Kroki server URL (Docker Compose)
   - Test PlantUML, Mermaid, etc.

5. **PWA Support**
   - Create manifest.webmanifest
   - Add service worker
   - Include in head with meta tags

6. **PhotoSwipe Lightbox**
   - Include PhotoSwipe CSS/JS
   - Create _includes for gallery shortcode
   - Adapt image-gallery.html logic

7. **YouTube/Codepen Embeds**
   - Create Jekyll includes: _includes/youtube.html
   - Create Jekyll includes: _includes/codepen.html
   - Use Liquid syntax: {% include youtube.html id="..." %}

### Phase 4: Styling & Customization

1. **Port custom CSS**
   - Copy custom.css → assets/css/main.scss (with imports)
   - Copy asciidoc-fixes.css
   - Copy copy-button.css
   - Adapt for Minimal Mistakes SCSS structure

2. **Custom layouts/partials**
   - Reading time (Minimal Mistakes has built-in)
   - Custom header/footer modifications
   - Adapt giscus partial

### Phase 5: Build & Deploy

1. **GitHub Actions workflow**
   ```yaml
   - uses: ruby/setup-ruby@v1
     with:
       bundler-cache: true
   - name: Build with Jekyll
     run: bundle exec jekyll build
   - uses: peaceiris/actions-gh-pages@v4
   ```

2. **Test locally**
   ```bash
   bundle exec jekyll serve --livereload
   ```

3. **Verify all features**
   - Search functionality
   - Comments (Giscus)
   - Diagrams render correctly
   - Copy buttons work
   - PWA manifest loads
   - Lightbox images

### Phase 6: Cleanup & Documentation

1. **Update CLAUDE.md**
   - Remove Hugo-specific commands
   - Add Jekyll commands
   - Update project structure documentation
   - Document new development workflow

2. **Archive old Hugo blog**
   - Rename blog/ → blog-hugo-archive/
   - Rename blog-jekyll/ → blog/
   - Update .gitignore

## File Mapping Reference

### Critical Files to Port

| Current (Hugo) | New (Jekyll) | Notes |
|----------------|--------------|-------|
| config.yml | _config.yml | Different structure, see mapping below |
| Gemfile | Gemfile | Add jekyll-asciidoc, minimal-mistakes |
| layouts/partials/giscus.html | _includes/comments-providers/giscus.html | Minimal Mistakes structure |
| static/js/copy-to-clipboard.js | assets/js/copy-to-clipboard.js | Port with adaptations |
| layouts/shortcodes/youtube.html | _includes/youtube.html | Change to Liquid include |
| layouts/shortcodes/codepen.html | _includes/codepen.html | Change to Liquid include |
| layouts/shortcodes/image-gallery.html | _includes/image-gallery.html | Adapt to PhotoSwipe |

### Config Mapping

| Hugo (config.yml) | Jekyll (_config.yml) | Notes |
|-------------------|----------------------|-------|
| baseURL | url | Direct mapping |
| title | title | Direct mapping |
| markup.asciidocExt | asciidoctor | Different structure |
| params.* | Multiple locations | Some in _config.yml, some in front matter defaults |

## Asciidoctor Configuration Comparison

**Hugo (config.yml):**
```yaml
markup:
  asciidocExt:
    extensions:
      - asciidoctor-kroki
    attributes:
      kroki-server-url: http://localhost:8000
```

**Jekyll (_config.yml):**
```yaml
asciidoc:
  processor: asciidoctor
  ext: asciidoctor,adoc,ad
asciidoctor:
  base_dir: :docdir
  safe: unsafe
  attributes:
    kroki-server-url: http://localhost:8000
    kroki-fetch-diagram: true
    imagesdir: /assets/diagrams
    imagesoutdir: assets/diagrams
    source-highlighter: rouge
    rouge-style: github
    icons: font
```

## Benefits After Migration

1. **Less Boilerplate:**
   - No wrapper scripts needed for Asciidoctor
   - Automatic attribute promotion (no manual YAML parsing)
   - Simpler configuration

2. **Better Asciidoctor Support:**
   - Direct extension loading
   - Proper include directive support
   - Better admonition rendering
   - Less CSS hacks for styling

3. **Community Plugins:**
   - jekyll-seo-tag (automatic meta tags)
   - jekyll-sitemap (automatic sitemap)
   - jekyll-feed (RSS)
   - Minimal Mistakes ecosystem

4. **Maintained Theme:**
   - Active development (Minimal Mistakes)
   - Regular updates
   - Community support

## Potential Challenges

1. **Learning Curve:**
   - Different templating (Liquid vs Go templates)
   - Different directory structure
   - Different configuration approach

2. **Build Time:**
   - Jekyll is slower than Hugo (Ruby vs Go)
   - Mitigated by: smaller blog size, incremental builds

3. **Custom Features:**
   - Need to port custom JavaScript
   - PhotoSwipe integration requires manual setup
   - Service worker for PWA

## Timeline Estimate

- **Phase 1** (Setup): 30 minutes
- **Phase 2** (Content): 1 hour
- **Phase 3** (Features): 2-3 hours
- **Phase 4** (Styling): 1 hour
- **Phase 5** (Deploy): 30 minutes
- **Phase 6** (Cleanup): 30 minutes

**Total:** ~6 hours

## Decision: Proceed?

**Recommendation:** ✅ **PROCEED** with migration

The benefits (better Asciidoctor support, less hacks, mature ecosystem) outweigh the migration effort for a small blog. The 6-hour investment will save time in long-term maintenance.

**Next Steps:**
1. Get user approval
2. Create backup branch
3. Start Phase 1 (Project Setup)
