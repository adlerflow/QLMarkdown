# TextDown → Standalone Markdown Editor/Viewer

## ⚠️ CRITICAL ARCHITECTURE CHANGE - November 2025

**WICHTIG**: Das Projekt hat eine fundamentale Architekturänderung durchlaufen:

### Alte Architektur (vor 2025-11-02) ❌ OBSOLETE
- **Server-side Syntax Highlighting**: wrapper_highlight + libhighlight (C++/Go)
- **Lua-basierte Themes**: 97 .theme files in Resources/highlight/themes/
- **Language Detection**: Enry (Go) + libmagic für unnamed code blocks
- **Bundle Dependencies**: libwrapper_highlight.dylib (26M), Lua interpreter, Boost libraries
- **Build Complexity**: 10-15 min clean build, 5 build stages

### Neue Architektur (ab 2025-11-02) ✅ CURRENT
- **Markdown Parser**: swift-markdown 0.5.0 (Pure Swift, Apple's library)
- **Custom Extensions**: 8 Swift Rewriters (967 LOC, replacing 4.1K LOC C/C++)
- **Client-side Syntax Highlighting**: highlight.js v11.11.1 (JavaScript in WKWebView)
- **CSS-basierte Themes**: 12 .min.css files in BundleResources/highlight.js/styles/
- **Language Detection**: highlight.js auto-detection (JavaScript heuristics)
- **Build Complexity**: ~30-45 seconds clean build (pure Swift + SPM)

**Migration Impact (2 Phases)**:
- **Phase 1 (Syntax Highlighting)**: Build Time 15 min → 2 min (87% reduction)
- **Phase 2 (swift-markdown)**: Build Time 2 min → 30-45 sec (75% reduction)
- **Total**: Build Time 15 min → 30-45 sec (95% reduction)
- Bundle Size: 50M → 50M (no change, offset by swift-markdown vs cmark-gfm)
- Code Deleted: -9,761 LOC (C/C++), +1,413 LOC (Swift) = **-8,348 net LOC**
- Dependencies Removed: wrapper_highlight/, GoUtils/, cmark-gfm/, cmark-extra/, pcre2/, jpcre2/, Lua, Boost, Enry

**Betroffene Dokumentationsabschnitte**:
- ✅ "Markdown Extensions" - NOW Pure Swift Rewriters (was C/C++ cmark-extra)
- ✅ "Rendering Pipeline" - NOW swift-markdown + Rewriters (was cmark-gfm)
- ✅ "Theme System" - CSS themes (was Lua themes)
- ✅ "Build-Time Dependencies" - Xcode only (was Go, Lua, Boost, autoconf, CMake)
- ✅ "Bridging Header" - DELETED (pure Swift, no C interop)

---

## Projektziel

Transformation von TextDown (QuickLook Extension) zu einem eigenständigen Markdown Editor/Viewer mit Split-View Architektur: Raw Markdown Editor (links) | Live Preview (rechts).

**Repository**: `/Users/home/GitHub/QLMarkdown`
**Branch**: `main`
**Migration-Branch**: `feature/standalone-editor`

---

## ✅ IMPLEMENTED: Swift-Markdown Migration (November 2025)

**Status**: ✅ COMPLETED (Branch: `feature/swift-markdown-migration`)
**Date**: 2025-11-02
**Commits**: a140381, bb46b5b (+ 4 cleanup commits)

The cmark-gfm + custom C/C++ extensions architecture has been successfully replaced with Apple's swift-markdown library, achieving a pure Swift codebase with significantly reduced build times and improved maintainability.

### Migration Documents

**Comprehensive Migration Plan**:
- **[SWIFT_MARKDOWN_MIGRATION_PLAN.md](docs/migration/SWIFT_MARKDOWN_MIGRATION_PLAN.md)** (1,245 lines) - Complete analysis, risks, recommendations
  - Executive Summary with **CONDITIONAL PROCEED** recommendation
  - Feature-by-feature migration analysis (9 custom extensions)
  - Critical gaps & showstoppers (math/highlight/sub/sup custom delimiters)
  - Build system impact (eliminate 4 Legacy Targets, -75% build time)
  - Hybrid approach recommendation (keep cmark-gfm for math only)

**Technical Implementation**:
- **[IMPLEMENTATION_GUIDE.md](docs/migration/IMPLEMENTATION_GUIDE.md)** (1,190 lines) - Production-ready code templates
  - 8 MarkupRewriter implementations with full source code
  - HeadingIDFormatter (custom HTMLFormatter subclass)
  - MarkdownRenderer orchestration layer
  - Error handling, performance optimization strategies

**Execution Plan**:
- **[PHASED_ROLLOUT.md](PHASED_ROLLOUT.md)** - 4-week implementation timeline
  - Phase 1: Foundation (swift-markdown SPM, GFM baseline)
  - Phase 2: Low-risk extensions (heads, inlineimage, emoji)
  - Phase 3: High-risk extensions (math, highlight, sub/sup, mention)
  - Phase 4: Cleanup (remove Legacy Targets, C/C++ code)

**Quality Assurance**:
- **[TESTING_STRATEGY.md](TESTING_STRATEGY.md)** - Comprehensive test coverage plan
  - Unit tests (200+ per-rewriter test cases)
  - Integration tests (end-to-end rendering)
  - Regression test suite (markdown fixtures)
  - Performance benchmarks

**Alternative Solutions**:
- **[ALTERNATIVE_APPROACHES.md](ALTERNATIVE_APPROACHES.md)** - Options analysis
  - Hybrid architecture (swift-markdown + cmark-gfm math only)
  - Feature deferral matrix
  - Upstream contribution path (fork swift-markdown)
  - Trade-off analysis

### Achieved Metrics ✅

| Metric | Before (cmark-gfm) | After (swift-markdown) | Impact |
|--------|---------------------|------------------------|--------|
| **Build Time (clean)** | ~2 minutes | ~30-45 seconds | **-75%** ✅ |
| **Custom Extension LOC** | ~4,100 (C/C++) | ~967 (Swift) | **-76%** ✅ |
| **Legacy Targets** | 4 (cmark, pcre2, jpcre2, magic) | 0 | **-100%** ✅ |
| **C Dependencies** | 3 (libpcre2, libjpcre2, libmagic) | 0 | **-100%** ✅ |
| **Bridging Header** | Required (5 imports) | Deleted | **-100%** ✅ |
| **Bundle Size** | ~50 MB | ~50 MB | 0% (no change) |
| **Code Deleted** | N/A | -9,761 lines (C/C++) | **-91%** ✅ |
| **AppConfiguration+Rendering.swift** | 861 lines (90% comments) | 91 lines (pure Swift) | **-89%** ✅ |

### Implementation Summary

**Core Implementation (6 Commits):**
1. `a140381` - swift-markdown rendering pipeline with 8 custom extensions (+1,192 LOC)
2. `3923659` - Removed Legacy Build Target schemes (-346 LOC)
3. `e58e284` - Removed Bridging-Header and moved test files (-18 files)
4. `702d585` - Extracted old cmark-gfm code to AppConfiguration+Rendering.txt.ref (-770 lines)
5. `bb46b5b` - YAML header processing for R Markdown/Quarto (+221 LOC)
6. Total: **-9,761 LOC removed**, **+1,413 LOC added** = **-8,348 net LOC**

**New Architecture (Pure Swift):**
- **MarkdownRenderer.swift** (265 LOC) - Main orchestration class
- **8 Rewriters** (967 LOC total):
  1. EmojiRewriter (143 LOC) - :smile: → 😄
  2. HighlightRewriter (70 LOC) - ==text== → `<mark>`
  3. SubSupRewriter (82 LOC) - ~sub~ / ^sup^
  4. MentionRewriter (79 LOC) - @username → GitHub links
  5. InlineImageRewriter (157 LOC) - Base64 + magic bytes
  6. MathRewriter (151 LOC) - $ → MathJax (FRAGILE regex)
  7. HeadingIDGenerator (78 LOC) - URL-safe anchor IDs
  8. YamlHeaderProcessor (183 LOC) - R Markdown/Quarto support
- **GFM Built-in**: Tables, Strikethrough, Task Lists, Autolinks (via swift-markdown)

**Known Limitations (Accepted Trade-offs):**
- ⚠️ MathRewriter uses FRAGILE regex (documented with 50+ line warning)
- ⚠️ hardBreakOption / noSoftBreakOption not supported (cmark-gfm specific)
- ⚠️ Nested/escaped delimiters may break (e.g., `$$nested $math$$`)
- ⚠️ Multi-line math requires single paragraph

**Build Status:**
- ✅ Clean build: 30-45 seconds (was 2 minutes)
- ✅ All features working (verified via screenshot testing)
- ✅ App launches and renders correctly
- ⚠️ 2 unit tests fail (hardBreak/noSoftBreak not supported)

**Files Reference:**
- Old implementation preserved: `TextDown/Core/AppConfiguration+Rendering.txt.ref` (772 lines)
- Migration documentation: `SWIFT_MARKDOWN_MIGRATION_PLAN.md`, `IMPLEMENTATION_GUIDE.md`

### Removed Components (swift-markdown Migration)

**cmark-gfm/** (126 C files, ~15K LOC):
- Core markdown parser (CommonMark + GitHub extensions)
- Removed in commits: `3923659`, `e58e284`

**cmark-extra/** (47 C/C++ files, ~4.1K LOC):
- 9 custom extensions:
  - emoji.c, emoji_utils.cpp (197 LOC)
  - heads.c (164 LOC)
  - inlineimage.c, b64.c (312 LOC)
  - math_ext.c (98 LOC)
  - highlight.c (71 LOC)
  - sub_ext.c, sup_ext.c (143 LOC)
  - mention.c (76 LOC)
  - checkbox.c (54 LOC)
- Removed in commit: `3923659`

**dependencies/** (Git submodules):
- pcre2/ (~50K LOC, regex library)
- jpcre2/ (C++ wrapper)
- Removed in commit: `3923659`

**TextDown-Bridging-Header.h**:
- 5 C header imports
- Removed in commit: `e58e284`

**Total Removal**: -9,761 LOC of C/C++ code

See migration documents for complete technical analysis.

---

## Aktuelle Projektstruktur (Post-Migration)

### TextDown.app - Standalone Editor
**Bundle ID**: `org.advison.TextDown`
**Primary Function**: Markdown Editor with Live Preview

**Kernklassen**:
- `ViewControllers/DocumentViewController.swift` (~617 LOC) - Split-View Editor
  - Markdown Input: NSTextView (linke Seite)
  - Preview: WKWebView (rechte Seite, Live-Update)
  - Debounced Rendering (0.5s delay)
  - Direct access to AppConfiguration.shared (@Observable)
- `Models/MarkdownDocument.swift` (180 LOC) - NSDocument Subclass
- `ViewControllers/MarkdownWindowController.swift` (82 LOC) - Window Management
- `Core/AppDelegate.swift` - App Lifecycle, Sparkle Updates
- `Core/AppConfiguration.swift` (~40 Properties, @Observable) - Single Source of Truth
- `Core/AppConfiguration+Rendering.swift` - Haupt-Rendering-Engine
- `Core/AppConfiguration+Persistence.swift` - Standalone Persistenz (JSON in Application Support)
- `Views/Settings/*.swift` (5 SwiftUI Views) - Settings UI with @Bindable bindings

**Wichtige Properties in AppConfiguration.swift**:
````
// GitHub Flavored Markdown
useGitHubStyleLineBreaks: Bool
enableTable: Bool
enableStrikethrough: Bool
enableAutolink: Bool
enableTaskList: Bool

// Custom Extensions
enableEmoji: Bool                    // :smile: → 😄
enableMath: Bool                     // $E=mc^2$ → MathJax
enableSyntaxHighlighting: Bool       // ```python → colored
enableInlineImage: Bool              // ![](local.png) → Base64
enableHeads: Bool                    // Auto-Anchor IDs für Headlines

// Syntax Highlighting
syntaxTheme: String                  // "solarized-dark", "github", etc.
syntaxUseTheme: Bool
syntaxPrintLineNumbers: Bool
syntaxWrapLines: Bool

// Appearance
appearance: Appearance               // .light, .dark, .auto
customCSSCode: String                // Custom CSS override
````

### Entfernte Komponenten (Phase 1 + 2)

**TextDownXPCHelper.xpc** (Phase 1 - ✅ Entfernt):
- XPC Service für Settings Persistenz
- 8 Dateien gelöscht

**TextDown Extension.appex** (Phase 2 - ✅ Entfernt):
- QuickLook Extension
- PreviewViewController.swift (~500 LOC)
- 5 Dateien gelöscht, 8.8M Bundle-Größe

**TextDown Shortcut Extension.appex** (Phase 2 - ✅ Entfernt):
- Shortcuts Integration (macOS 15.2+)
- MdToHtml_Extension.swift
- 5 Dateien gelöscht, 19M Bundle-Größe

**external-launcher.xpc** (Phase 2 - ✅ Entfernt):
- XPC Service für URL-Opening
- 5 Dateien gelöscht

**Gesamt-Reduktion**: 27M Bundle-Größe (35%), 6 Targets → 1 Target

---

## Markdown Extensions (swift-markdown Rewriters)

**Implementierte Extensions** (Pure Swift):

| Extension | File | Function | Dependencies | Status |
|-----------|------|----------|--------------|--------|
| **emoji** | EmojiRewriter.swift | `:smile:` → 😄 | Static emoji map (65 mappings) | ✅ Active |
| **heads** | HeadingIDGenerator.swift | Auto-Anchor `## Hello` → `id="hello"` | SwiftSoup (post-processing) | ✅ Active |
| **inlineimage** | InlineImageRewriter.swift | `![](local.png)` → Base64 Data URL | Magic byte sniffing (8 formats) | ✅ Active |
| **math** | MathRewriter.swift | `$E=mc^2$` → MathJax `\(...\)` | Regex (⚠️ FRAGILE) | ✅ Active |
| **highlight** | HighlightRewriter.swift | `==marked text==` → `<mark>` | - | ✅ Active |
| **sub/sup** | SubSupRewriter.swift | `~sub~` und `^sup^` | - | ✅ Active |
| **mention** | MentionRewriter.swift | GitHub `@username` | - | ✅ Active |
| **yaml** | YamlHeaderProcessor.swift | R Markdown/Quarto frontmatter | Yams library | ✅ Active |

**WICHTIG**: Syntax Highlighting erfolgt nun **client-side via highlight.js** (siehe Rendering Pipeline).

**GitHub Core Extensions** (swift-markdown built-in):
- table, strikethrough, autolink, tasklist, tagfilter (no rewriter needed)

---

## Rendering Pipeline (swift-markdown)

**Pure Swift Architecture**: swift-markdown (AST manipulation) + Client-side highlight.js (JavaScript)

````
Markdown Input String (.md, .rmd, .qmd)
  ↓
AppConfiguration+Rendering.swift: render(text:filename:forAppearance:baseDir:)
  ↓
MarkdownRenderer.render(markdown:filename:baseDirectory:appearance:)
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 1: YAML Header Processing (Swift)    │
├─────────────────────────────────────────────┤
│ YamlHeaderProcessor.extractYamlHeader()    │
│                                             │
│ IF yamlExtension + (.rmd OR .qmd):         │
│   - Regex: (?s)((?<=---\n).*?(?>\n(?:---|\\.\\.\\.)\n))
│   - Parse YAML using Yams library          │
│   - Render as HTML table (nested support)  │
│   - Remove YAML block from markdown        │
│   - Fallback: ```yaml code block if fail  │
│                                             │
│ Output: (processedMarkdown, yamlHeaderHTML)│
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 2: Parse Options Configuration       │
├─────────────────────────────────────────────┤
│ var parseOptions: ParseOptions = []       │
│                                             │
│ IF !smartQuotesOption:                     │
│   parseOptions.insert(.disableSmartOpts)   │
│                                             │
│ Note: GFM extensions enabled by default    │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 3: Parse Markdown → AST (Swift)      │
├─────────────────────────────────────────────┤
│ let document = Document(parsing: markdown, │
│                        options: parseOptions)│
│                                             │
│ AST Nodes: Heading, Paragraph, CodeBlock,  │
│            List, Table, Image, Strikethrough│
│            etc. (swift-markdown types)      │
│                                             │
│ GFM Features (built-in):                    │
│ - Tables, Strikethrough, Task Lists,       │
│   Autolinks                                 │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 4: Apply Rewriters (Swift)           │
├─────────────────────────────────────────────┤
│ var transformed = document as Markup       │
│                                             │
│ Sequential rewriter pipeline:               │
│ 1. EmojiRewriter: :smile: → 😄             │
│ 2. HighlightRewriter: ==text== → <mark>    │
│ 3. SubSupRewriter: ~sub~ ^sup^             │
│ 4. MentionRewriter: @user → GitHub link    │
│ 5. InlineImageRewriter: ![](local) → Base64│
│ 6. MathRewriter: $ → MathJax delimiters    │
│                                             │
│ Each rewriter: MarkupRewriter protocol     │
│   - visitText() / visitImage()             │
│   - Modifies AST in-place                  │
│   - Returns transformed Markup             │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 5: HTML Rendering (Swift)            │
├─────────────────────────────────────────────┤
│ let htmlBody = HTMLFormatter.format(       │
│                   transformed)              │
│                                             │
│ HTMLFormatter (swift-markdown):             │
│ - visitTable() → <table><tr><td>           │
│ - visitStrikethrough() → <del>             │
│ - visitListItem() → <li><input checkbox>   │
│ - visitCodeBlock() → <pre><code>           │
│   (UNSTYLED - highlight.js adds later)     │
│                                             │
│ Output: HTML fragment (no <html> wrapper)  │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 6: Post-Processing (Swift)           │
├─────────────────────────────────────────────┤
│ postProcessHTML(htmlBody, yamlHeader, ...) │
│                                             │
│ SwiftSoup operations:                       │
│ 1. addHeadingIDs() - URL-safe anchor IDs   │
│    (HeadingIDGenerator: "Hello World" →    │
│     "hello-world", collision detection)    │
│                                             │
│ 2. buildCompleteHTML():                     │
│    - Inject base CSS (default.css)         │
│    - Inject custom CSS (customCSSCode)     │
│    - Add highlight.js CSS theme            │
│    - Add MathJax CDN (if math detected)    │
│    - Add debug info table (if enabled)     │
│    - Prepend YAML header HTML              │
│    - Append about footer (if enabled)      │
│    - Add highlight.js JavaScript           │
│                                             │
│ Output: Complete HTML5 document            │
└─────────────────────────────────────────────┘
  ↓
Complete HTML String → WKWebView.loadHTMLString()
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 7: Client-Side Rendering (JavaScript)│
├─────────────────────────────────────────────┤
│ WKWebView executes embedded JavaScript:    │
│                                             │
│ document.querySelectorAll('pre code')      │
│   .forEach(block => {                      │
│     hljs.highlightElement(block);          │
│   });                                       │
│                                             │
│ highlight.js v11.11.1:                      │
│ - Auto-detects language if not specified   │
│ - Applies CSS theme classes                │
│ - Syntax highlighting executed in browser  │
│                                             │
│ MathJax (if present):                       │
│ - Renders \(...\) as inline math           │
│ - Renders \[...\] as display math          │
│                                             │
│ Result: Fully styled HTML with syntax      │
│         highlighting and math rendering    │
└─────────────────────────────────────────────┘
  ↓
Final Rendered Markdown in WKWebView
````

**Critical Functions**:
- `Document(parsing:options:)` - Entry Point (swift-markdown)
- `HTMLFormatter.format(_:)` - AST → HTML Body Fragment (swift-markdown)
- `MarkdownRenderer.render()` - Main orchestration layer (Swift)
- `AppConfiguration+Rendering.swift:render()` - Delegation to MarkdownRenderer (Swift)
- `hljs.highlightElement()` - Client-side syntax highlighting (JavaScript)

**Performance Notes**:
- Server-side: swift-markdown parsing ~5-10ms for typical documents
- Rewriters: ~2-5ms additional (8 sequential passes)
- Client-side: highlight.js processing ~20-50ms (runs in WKWebView)
- Total rendering time: ~30-70ms (comparable to cmark-gfm)
- **Advantage**: Offloads CPU work to WKWebView process, keeps main app responsive

---

## Theme System

**Location**: `BundleResources/highlight.js/styles/` (CSS Themes)

**Structure**:
````
highlight.js/
├── lib/
│   └── highlight.min.js                 # Core library (77 KB)
└── styles/
    ├── github.min.css                   # Light themes
    ├── github-dark.min.css
    ├── atom-one-dark.min.css            # Dark themes
    ├── monokai.min.css
    ├── nord.min.css
    ├── vs2015.min.css
    ├── xcode.min.css
    └── [5 more themes]                  # Total: 12 themes
````

**Theme Format** (CSS):
````css
/* atom-one-dark.min.css */
.hljs {
  color: #abb2bf;
  background: #282c34;
}
.hljs-keyword,
.hljs-operator {
  color: #c678dd;
}
.hljs-string {
  color: #98c379;
}
/* ... Weitere CSS-Klassen */
````

**Theme Statistics**:
- **Total**: 12 Themes (highlight.js default collection)
- **Light Themes**: 6 (github, xcode, stackoverflow-light, etc.)
- **Dark Themes**: 6 (github-dark, atom-one-dark, monokai, nord, vs2015, etc.)
- **File Size**: ~6-12 KB per theme (minified CSS)

**Theme Selection**:
- User Settings:
  - `AppConfiguration.syntaxThemeLightOption` (String) - Theme für Light Mode
  - `AppConfiguration.syntaxThemeDarkOption` (String) - Theme für Dark Mode
- Appearance-Based: Auto-Switch via `forAppearance:` parameter
  - macOS Light Mode → `syntaxThemeLightOption` (default: "github")
  - macOS Dark Mode → `syntaxThemeDarkOption` (default: "github-dark")

**Implementation** (AppConfiguration+Rendering.swift:592-639):
````swift
if self.syntaxHighlightExtension {
    let hlTheme = appearance == .light ? self.syntaxThemeLightOption : self.syntaxThemeDarkOption

    if let jsPath = self.resourceBundle.path(forResource: "highlight.min", ofType: "js", inDirectory: "highlight.js/lib"),
       let cssPath = self.resourceBundle.path(forResource: hlTheme + ".min", ofType: "css", inDirectory: "highlight.js/styles") {

        let jsContent = try String(contentsOfFile: jsPath, encoding: .utf8)
        let cssContent = try String(contentsOfFile: cssPath, encoding: .utf8)

        // Inline CSS + JS into HTML <head> and <script> tags
    }
}
````

**Migration Notes**:
- **Old System** (❌ Removed Nov 2025): Lua tables in Resources/highlight/themes/ (97 themes)
- **New System** (✅ Current): CSS files in BundleResources/highlight.js/styles/ (12 themes)
- **Compatibility**: No migration needed - themes are independent of markdown files

---

## Build Configuration (Xcode)

### Architectures
- **Universal Binary**: x86_64 + arm64
- **Deployment Target**:
  - x86_64: macOS 10.15 (Catalina)
  - arm64: macOS 11.0 (Big Sur)

### Build Settings (wichtig)
````
SWIFT_VERSION = 5.x

ONLY_ACTIVE_ARCH = YES (Debug) / NO (Release)

LD_RUNPATH_SEARCH_PATHS = @loader_path/../Frameworks
````

**❌ NO LONGER REQUIRED** (swift-markdown migration, Nov 2025):
- ~~SWIFT_OBJC_BRIDGING_HEADER~~ - Deleted (pure Swift, no C interop)
- ~~CLANG_CXX_LANGUAGE_STANDARD~~ - No C++ code
- ~~CLANG_CXX_LIBRARY~~ - No C++ code

### Bridging Header

**❌ DELETED** (swift-markdown migration, Nov 2025):
- `TextDown/TextDown-Bridging-Header.h` removed in commit `e58e284`
- Pure Swift codebase requires no Objective-C bridging

### Entitlements (Pre-Migration)

**TextDown.app**:
````xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.cs.allow-jit</key>
<true/>
````

### Entitlements (aktuell - alle Extensions entfernt)
Standalone Editor benötigt:
````xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>  <!-- File Open/Save Dialogs -->
<key>com.apple.security.network.client</key>
<true/>  <!-- Für MathJax CDN, Emoji GitHub API -->
<key>com.apple.security.cs.allow-jit</key>
<true/>  <!-- Für JavaScript in WKWebView -->
````

---

## SPM Dependencies (Exakt)

**swift-markdown** - Markdown Parser ✅ NEW (Nov 2025)
- Version: 0.5.0
- Repository: https://github.com/apple/swift-markdown
- Size: ~1 MB
- Usage: Core markdown parsing with GFM support
- Transitive: swift-cmark (Apple's Swift wrapper)

**Sparkle** - Auto-Update Framework
- Version: 2.7.0
- Repository: https://github.com/sparkle-project/Sparkle
- Revision: `0ca3004e98712ea2b39dd881d28448630cce1c99`
- Size: ~3 MB
- Used By: TextDown.app only (nicht Extensions)

**SwiftSoup** - HTML Parser
- Version: 2.8.7
- Repository: https://github.com/scinfu/SwiftSoup
- Revision: `bba848db50462894e7fc0891d018dfecad4ef11e`
- Size: ~500 KB
- Usage: HTML Post-Processing (CSS Injection, Inline Images)

**Yams** - YAML Parser
- Version: 4.0.6
- Repository: https://github.com/jpsim/Yams
- Revision: `9ff1cc9327586db4e0c8f46f064b6a82ec1566fa`
- Size: ~300 KB
- Usage: R Markdown YAML Headers (.rmd, .qmd)

---

## Bundle Struktur (Post-Migration - Stand Nov 2025)
````
TextDown.app/
├── Contents/
│   ├── MacOS/
│   │   └── TextDown                 # Main Binary (~10M)
│   ├── Frameworks/
│   │   └── Sparkle.framework          # Auto-Update (~3M)
│   └── Resources/
│       ├── highlight.js/
│       │   ├── lib/
│       │   │   └── highlight.min.js   # Core library (77 KB)
│       │   └── styles/
│       │       └── *.min.css          # 12 CSS Themes (~6-12 KB each)
│       ├── default.css                # Base CSS (14 KB)
│       └── magic.mgc                  # libmagic Database (800 KB)
````

**Size Breakdown (Nov 2025 - Post-Optimization)**:
- **Total Bundle**: ~40M (projected, down from 50M)
- MacOS Binary: ~10M
- Sparkle.framework: ~3M
- Resources: ~1.5M (highlight.js 150 KB, default.css 14 KB, magic.mgc 800 KB, other assets ~500 KB)
- **Reduction vs Phase 2**: -10M (libwrapper_highlight.dylib 26M + Resources/highlight/ 10M removed, highlight.js 150 KB added)

**Entfernt (Phase 2)**:
- PlugIns/ (QLExtension.appex 8.8M)
- Extensions/ (Shortcut Extension.appex 19M)
- XPCServices/ (TextDownXPCHelper.xpc)
- Resources/qlmarkdown_cli

**Entfernt (Nov 2025 - Optimization + swift-markdown Migration)**:
- ❌ Frameworks/libwrapper_highlight.dylib (26M) - Replaced by highlight.js (77 KB)
- ❌ Resources/highlight/ (10M) - 386 files (Lua language definitions, themes, plugins)
- ❌ cmark-gfm/ (126 C files, ~15K LOC) - Replaced by swift-markdown
- ❌ cmark-extra/ (47 C/C++ files, ~4.1K LOC) - Replaced by 8 Swift Rewriters
- ❌ dependencies/pcre2 (Git submodule) - No longer needed
- ❌ dependencies/jpcre2 (Git submodule) - No longer needed
- ❌ TextDown-Bridging-Header.h - Pure Swift, no bridging needed

---

## Build-Time Dependencies (detailliert)

### Required Tools
````
Xcode 16.x                  # Primary IDE
Command Line Tools          # clang, make, git
````

**❌ NO LONGER REQUIRED** (Removed Nov 2025):
- ~~Go 1.14+~~ - Enry language detection (replaced by highlight.js)
- ~~Lua 5.4~~ - Lua interpreter for theme system (replaced by CSS)
- ~~Boost C++ Libraries~~ - Required by libhighlight (no longer used)
- ~~autoconf/automake/libtool~~ - Required for libpcre2/libmagic (removed with cmark-gfm)
- ~~CMake~~ - Required for cmark-gfm (removed)

### Build-Time Legacy Targets

**❌ ALL REMOVED** (swift-markdown migration, Nov 2025):
- ~~cmark-headers~~ - Deleted with cmark-gfm removal
- ~~libpcre2~~ - Deleted with cmark-gfm removal
- ~~libjpcre2~~ - Deleted with cmark-gfm removal
- ~~magic.mgc~~ - Still present, but not a build target anymore

**Current Build Targets**: 1 (TextDown.app only)

**Total Clean Build Time**: ~30-45 seconds (was 2 min with cmark-gfm, 10-15 min with highlight-wrapper)

---

## Language Detection (Client-Side)

**Modern Approach** (Nov 2025): highlight.js Auto-Detection

### highlight.js Heuristics
**Function**: `hljs.highlightAuto(code)`
**Implementation**: JavaScript (runs in WKWebView)
**Algorithm**: Statistical analysis + keyword matching
**Accuracy**: ~95% for common languages
**Usage**: Automatic für code blocks ohne language tag

**Example**:
````markdown
```
#!/usr/bin/env python
print("Hello")
```
````
→ highlight.js detektiert: "python" (via shebang + print syntax)

**Fenced Code Blocks mit Language Tag**:
````markdown
```python
print("hi")
```
````
→ Language = "python" (explizit, keine Detection nötig)

**Performance**:
- Detection: ~5-15ms per code block (JavaScript)
- Runs in WKWebView process (non-blocking)
- **Advantage**: No server-side dependencies (Enry/libmagic)

---

## Architektur-Entscheidungen

### Was wurde entfernt (✅ COMPLETED)
- ✅ QuickLook Extension (QLExtension.appex) - Phase 2
- ✅ Shortcuts Integration (Shortcut Extension.appex) - Phase 2
- ✅ external-launcher (XPC Service) - Phase 2
- ✅ TextDownXPCHelper (XPC Service) - Phase 1

### Was bleibt erhalten (nach swift-markdown Migration)
- **Rendering-Engine**: ✅ Migrated to swift-markdown + 8 custom Swift Rewriters (emoji, heads, inlineimage, math, highlight, sub, sup, mention, yaml)
- **Syntax Highlighting**: ✅ Client-side highlight.js v11.11.1 (JavaScript in WKWebView)
- **Theme System**: ✅ 12 CSS-based themes (highlight.js/styles/)
- **Settings-Logik**: AppConfiguration.swift mit AppConfiguration+Persistence.swift (JSON Persistenz)
- **SPM Dependencies**: swift-markdown, Sparkle (Auto-Update), SwiftSoup, Yams

### Neue Komponenten (✅ IMPLEMENTED)
- ✅ **DocumentViewController**: Split-View mit NSTextView + WKWebView (Phase 3)
- ✅ **MarkdownDocument**: NSDocument subclass für File Open/Save/Auto-Save (Phase 3)
- ✅ **MarkdownWindowController**: NSWindowController für Multi-Window Management (Phase 3)
- ✅ **SwiftUI Preferences Window**: 4-Tab Settings UI mit Apply/Cancel Pattern (Phase 4)
- ✅ **AppConfigurationViewModel**: Combine-based State Management für 40 Properties (Phase 4)
- ✅ **Live Rendering**: Debounced text change detection (0.5s) (Phase 3)

---

## SwiftUI Preferences Window (Phase 4)

### Architecture
- **Pattern**: Apply/Cancel with draft Settings copy (JSON encode/decode for deep copy)
- **State Management**: Swift @Observable + @Bindable bindings (no Combine, no ViewModel)
- **Window**: NSHostingController bridge to AppKit

### Components
- `TextDownSettingsView.swift` - Main window with TabView + Apply/Cancel toolbar
- `GeneralSettingsView.swift` - CSS, appearance, links (8 properties)
- `ExtensionsSettingsView.swift` - GFM + custom extensions (17 properties)
- `SyntaxSettingsView.swift` - Highlighting, themes, line numbers (7 properties)
- `AdvancedSettingsView.swift` - Parser options, reset (8 properties)

### Settings Properties (40 Total)
- **GFM** (6): table, autolink, tagfilter, tasklist, yaml
- **Custom** (11): emoji, heads, highlight, inlineimage, math, mention, sub, sup, strikethrough, checkbox
- **Syntax** (7): highlighting, line numbers, tab width, word wrap, themes, guess engine
- **Parser** (6): footnotes, hard breaks, unsafe HTML, smart quotes, validate UTF-8
- **Appearance** (8): custom CSS, appearance mode, debug, window size

### Persistence
- **Location**: `~/Library/Containers/org.advison.TextDown/Data/Library/Application Support/settings.json`
- **Format**: Pretty-printed JSON, atomic writes
- **Sync**: DistributedNotificationCenter for multi-window updates

---

## Key Files

**Rendering**: `MarkdownRenderer.swift` (265 LOC), `Core/AppConfiguration+Rendering.swift` (91 LOC), `Core/AppConfiguration.swift` (40 properties), `Core/AppConfiguration+Persistence.swift`

**Rewriters** (967 LOC total):
- `EmojiRewriter.swift` (143 LOC)
- `HighlightRewriter.swift` (70 LOC)
- `SubSupRewriter.swift` (82 LOC)
- `MentionRewriter.swift` (79 LOC)
- `InlineImageRewriter.swift` (157 LOC)
- `MathRewriter.swift` (151 LOC)
- `HeadingIDGenerator.swift` (78 LOC)
- `YamlHeaderProcessor.swift` (183 LOC)

**UI**: `ViewControllers/DocumentViewController.swift` (617 LOC), `Models/MarkdownDocument.swift` (180 LOC), `ViewControllers/MarkdownWindowController.swift` (82 LOC), `Views/Settings/*.swift` (5 views), `Core/AppDelegate.swift`

**Build**: `TextDown.xcodeproj/project.pbxproj`

**Reference**: `AppConfiguration+Rendering.txt.ref` (772 LOC - old cmark-gfm implementation preserved)

---

## Success Metrics (✅ ACHIEVED - Phase 2 Complete)

### Targets
- **Before**: 10 Targets (6 Native + 4 Legacy)
- **After**: 5 Targets (1 Native + 4 Legacy) ✅
- **Reduction**: 50% (5 Targets entfernt)

### Bundle Size
- **Before**: 77M (mit allen Extensions)
- **After**: 50M (nur Editor) ✅
- **Reduction**: 27M (35%)
- **Breakdown After**:
  - Resources: 10M (themes, langDefs, CSS)
  - MacOS Binary: 10M
  - Sparkle.framework: 3M

### Code Complexity
- **Before**: ~8,000 LOC Swift
- **After**: ~5,500 LOC Swift (900 LOC added, 448 LOC removed)
- **Added**: MarkdownDocument, MarkdownWindowController, AppConfigurationViewModel, 4 SwiftUI Views
- **Removed**: XPCHelper, 3 Extensions, CLI

### Build Time
- **Clean Build**: ~2 min (was 15 min, 87% reduction after wrapper_highlight removal)
- **Incremental Build**: ~30s
- **Speedup**: Removed Go compilation (Enry), Lua compilation, Boost C++ compilation, libhighlight linking

### project.pbxproj
- **Before**: 2,581 lines
- **After**: 1,577 lines ✅
- **Reduction**: 1,004 lines (39%)

---

## Pre-Migration Baseline

### Project Structure (Original)

**Xcode Targets (10 Total)**:

**Native Targets (6)**:
1. TextDown - Main Application (Bundle ID: org.advison.TextDown)
2. Markdown QL Extension - QuickLook Extension (.appex)
3. TextDown Shortcut Extension - Shortcuts Integration (.appex)
4. qlmarkdown_cli - Command Line Interface Binary
5. TextDownXPCHelper - Settings Persistence XPC Service (.xpc)
6. external-launcher - URL Opening XPC Service (.xpc)

**Legacy Build Targets (4)**:
7. libpcre2 - PCRE2 Regular Expression Library
8. libjpcre2 - JPCRE2 C++ Wrapper
9. cmark-headers - Markdown Parser + Extensions
10. magic.mgc - MIME Database Compiler

### Build Configuration (Original)
- **Architectures**: Universal Binary (x86_64 + arm64)
- **Deployment Target**: macOS 10.15+ (x86_64), macOS 11.0+ (arm64)
- **Swift Version**: 5.x
- **C++ Standard**: C++17
- **Build Time**: 10-15 min (clean build)

### Critical Files (Original)
- `TextDown/Core/AppConfiguration.swift` - 40+ Properties
- `TextDown/Core/AppConfiguration+Rendering.swift` - Main Rendering Engine
- `TextDown/Core/AppConfiguration+XPC.swift` - XPC Communication
- `TextDown/Core/AppConfiguration+Persistence.swift` - Direct UserDefaults Fallback
- `TextDown/ViewController.swift` - Settings UI (1200+ LOC)
- `TextDown/Core/AppDelegate.swift` - Lifecycle + Sparkle

### Bundle Size (Original)
- **Total**: ~77 MB
- **libwrapper_highlight.dylib**: ~36 MB (26M in bundle, 36M source)
- **Extensions**: ~28 MB (QLExtension 8.8M + Shortcuts 19M)
- **Resources/highlight/**: ~10 MB (386 files: langDefs, themes, plugins)
- **Sparkle.framework**: ~3 MB

### Markdown Extensions Status (Original)
All extensions present and functional:
- ✅ GitHub Flavored Markdown (table, strikethrough, autolink, tasklist)
- ✅ Emoji (emoji.c)
- ✅ Math (math_ext.c)
- ⚠️ Syntax Highlighting (syntaxhighlight.c + libhighlight) - LATER REMOVED
- ✅ Inline Images (inlineimage.c)
- ✅ Auto Anchors (heads.c)
- ✅ Highlight/Sub/Sup/Mention/Checkbox

### Theme System (Original)
- **Total Themes**: 97
- **Location**: Resources/highlight/themes/
- **Format**: Lua-based (.theme files)
- **Note**: Later replaced by 12 CSS themes (Nov 2025)

---

## Migration Status

**Phase 0**: Rebranding to TextDown ✅ COMPLETED
- [x] Rename all files, bundle IDs, documentation

#### Detailed Commit History

**Duration**: 2025-10-30
**Total Commits**: 10
**Files Changed**: 164
**Net Change**: +781 insertions, -750 deletions

**Commit 0.1** (`9fffa39`): Feature Branch Creation
- Created `feature/standalone-editor` branch
- Added comprehensive CLAUDE.md documentation (697 lines)

**Commit 0.2** (`0b23c48`): Initial Rebranding (sbarex → advison)
- Bundle IDs: `org.sbarex.*` → `org.advison.*`
- Author: `Sbarex` → `adlerflow` (62 files)
- Removed donation features (stats.html, "buy me a coffee")
- 62 files changed (+225, -186)

**Commit 0.3** (`e373e84`): UI Cleanup
- Removed "Buy me a coffee" toolbar from Main.storyboard
- Cleaned up project.pbxproj references
- Updated Xcode toolsVersion: 23727 → 24412
- 2 files changed (+115, -242)

**Commit 0.4** (`6084027`): Development Configuration
- Updated all schemes: LastUpgradeVersion 1630 → 2610
- Relaxed sandbox entitlements (development only, not App Store)
- Added cmark version fallback
- 17 files changed (+81, -53)

**Commit 0.5** (`d109a85`): Code Rebranding
- Bundle IDs: `org.advison.QLMarkdown.*` → `org.advison.TextDown.*`
- Notifications: `QLMarkdownSettingsUpdated` → `TextDownSettingsUpdated`
- UserDefaults: `org.advison.qlmarkdown-*` → `org.advison.textdown-*`
- Updated 27 Swift + 28 C/C++ file headers
- Folder: `qlmarkdown_cli/` → `textdown_cli/`
- 59 files changed (+217, -217)

**Commit 0.6** (`7ed1540`): Documentation Rebranding
- Updated CLAUDE.md (26 references)
- Updated MIGRATION_LOG.md (10 references)
- 2 files changed (+37, -37)

**Commit 0.7** (`6309ea7`): Xcode Project Rename
- `QLMarkdown.xcodeproj/` → `TextDown.xcodeproj/`
- Updated all 9 .xcscheme container references
- 13 files changed (+25, -25)
- Git history preserved (99-100% similarity)

**Commit 0.8** (`821f480`): Source Folder Rename
- `QLMarkdown/` → `TextDown/` (68 files)
- `QLMarkdownXPCHelper/` → `TextDownXPCHelper/` (7 files)
- Bridging header: `QLMarkdown-Bridging-Header.h` → `TextDown-Bridging-Header.h`
- 79 files changed (+16, -16)
- Git history preserved (100% similarity)

**Commit 0.9** (`5e8a4b4`): Extension Folder Rename
- `QLExtension/` → `Extension/` (5 files)
- Bundle ID: `*.QLExtension` → `*.Extension`
- 6 files changed (+7, -7)

**Commit 0.10** (`0ebda1f`): Scheme Regeneration
- Regenerated Xcode schemes with TextDown names
- Fixed typo: `QLMardown.xcscheme` → `TextDown.xcscheme`
- 5 files changed (+164 insertions)

**Phase 0.5**: Code Modernization ✅ COMPLETED
- [x] Fix bridging header and build paths
- [x] Modernize APIs (UniformTypeIdentifiers)
- [x] Remove deprecation warnings

#### Detailed Commit History

**Duration**: 2025-10-31
**Total Commits**: 6
**Files Changed**: 11
**Net Change**: +116 insertions, -183 deletions

**Commit 0.11** (`a545e0d`): Bridging Header Fix
- Removed direct `#import "config.h"` from bridging header
- Note: config.h auto-included by cmark headers
- Fixed build warning
- 1 file changed (-1)

**Commit 0.12** (`f01d018`): Post-Rebranding Path Fixes
- Fixed Extension.entitlements path
- Fixed Shortcut Extension.entitlements path
- Updated magic.mgc build tool path (qlmarkdown_cli → textdown_cli)
- Added wrapper_highlight to search paths
- 1 file changed (+4, -4)

**Commit 0.13** (`c66cefa`): Modernize ViewController APIs
- Added `import UniformTypeIdentifiers`
- Replaced deprecated `String(contentsOf:)` with `String(contentsOf:encoding:.utf8)`
- Migrated 6 file dialogs from `allowedFileTypes` to `allowedContentTypes`
- Used `UTType(filenameExtension:)` for .md, .rmd, .qmd, .html, .css
- **Result**: All 6 deprecation warnings resolved
- 1 file changed (+7, -6)

**Commit 0.14** (`76cc903`): Remove Legacy WebView Code
- Deleted deprecated MyWebView class (macOS 10.14)
- Removed legacy preview path (macOS 11 compatibility)
- Simplified loadView() from 85 → 32 lines (-53 lines)
- Replaced `preferences.javaScriptEnabled` with `defaultWebpagePreferences.allowsContentJavaScript`
- Deleted preparePreviewOfFile() method
- Removed WebFrameLoadDelegate extension
- **Result**: -115 lines (51% reduction), zero deprecation warnings
- 1 file changed (+23, -138)

**Commit 0.15** (`7e1234c`): Collapsible Settings Panel
- Added height constraint to TabView (220pt)
- Added toggle button with SF Symbol `chevron.up.chevron.down`
- Implemented `@IBAction func toggleSettings(_:)` with animation (0.25s)
- Dynamic tooltip update
- 2 files changed (+21, -6)

**Commit 0.16** (`f638528`): Fix TabView Overflow Rendering
- **Problem**: Bottom-row elements visible when collapsed to height=0
- **Root Cause**: NSTabView doesn't clip subviews by default
- **Solution**: Show TabView BEFORE expand, hide AFTER collapse
- Modified toggleSettings() with isHidden state management
- **Result**: Settings panel fully hidden when collapsed
- 1 file changed (+11, -1)

**Key Achievements**:
- 🎯 Zero deprecation warnings
- 🎯 51% code reduction in PreviewViewController
- 🎯 Modernized file dialogs (UTType)
- 🎯 Smooth animated settings toggle (0.25s)

**Phase 0.75**: UI Cleanup ✅ COMPLETED
- [x] Remove footer bar from Main.storyboard
- [x] Comment out Settings TabView (875 lines)
- [x] Implement auto-refresh and auto-save

#### Detailed Commit History

**Duration**: 2025-10-31
**Total Commits**: 4
**Files Changed**: 8
**Net Change**: +71 insertions, -1,142 deletions

**Commit 0.17** (`0b0daee`): Footer Bar Removal
- Removed entire footer bar stack view
- Deleted 8 UI elements:
  - Horizontal separator, Reset, Revert, Save buttons
  - Elapsed time label, Appearance toggle, Settings toggle, Refresh button
- Removed 42 Auto Layout constraints
- **Result**: Clean split-view layout (Raw Markdown | Rendered Preview)
- 1 file changed (+2, -178)

**Commit 0.18** (`e197268`): Settings TabView Cleanup
- ViewController.swift: Commented out 875 lines
  - All settings IBOutlets (tabView, popup buttons)
  - All settings popup initialization methods
  - All IBAction handlers for settings controls
- Main.storyboard: Removed Settings TabView
  - Deleted TabView with 6 tabs
  - Removed 35+ controls
- Simplified to core editor: NSTextView + WKWebView
- 2 files changed (+40, -960)

**Commit 0.19** (`1dcf912`): Auto-Refresh and Auto-Save
- Added NSTextViewDelegate extension
- Implemented textDidChange(_:) for auto-refresh
- 0.5s debounce via perform(_:with:afterDelay:)
- Integrated with existing autoRefresh preference
- Auto-save already present via isAutoSaving property
- **Result**: Live preview updates 0.5s after typing stops
- 1 file changed (+19 insertions)

**Commit 0.20** (`5009714`): Repository Cleanup
- Updated .gitignore with comprehensive Xcode patterns
- Removed 1,190 tracked build artifacts:
  - build/ directory (1,186 files)
  - .DS_Store files (4 files)
- **Result**: Clean working tree
- 2 files changed (+10, -4)

**Key Achievements**:
- 🎯 Footer bar removed (simplified UI)
- 🎯 875 lines Settings UI isolated
- 🎯 Live preview (0.5s debounce)
- 🎯 1,190 files removed from repo

**Phase 1**: XPC Elimination ✅ COMPLETED
- [x] Remove TextDownXPCHelper target
- [x] Switch to Settings+NoXPC exclusively
- [x] Test Settings persistence (JSON file)
- [x] Git commit: 5f7cb01

#### Detailed Commit History

**Duration**: 2025-10-31
**Commit**: `5f7cb01`
**Files Changed**: 10
**Net Change**: +50 insertions, -450 deletions

**Changes**:
- **Deleted Files** (8 total):
  - TextDownXPCHelper/ folder (entire XPC service):
    - Info.plist, main.swift, TextDownXPCHelper.swift
    - TextDownXPCHelperProtocol.swift, TextDownXPCHelper.entitlements
  - TextDown/Core/AppConfiguration+XPC.swift (XPC wrapper)
  - TextDown/XPCWrapper.swift (XPC communication layer)

- **Modified Files**:
  - TextDown.xcodeproj/project.pbxproj: Removed TextDownXPCHelper target
  - TextDown/Core/AppConfiguration.swift: Switched to AppConfiguration+Persistence.swift exclusively
  - TextDown/Info.plist: Removed XPCServices declarations

- **Persistence Method**: JSON file in Application Support
  - Path: `~/Library/Containers/org.advison.TextDown/Data/Library/Application Support/settings.json`
  - Format: Pretty-printed JSON with sorted keys
  - Atomic writes for data integrity

**Key Achievements**:
- 🎯 XPC architecture eliminated
- 🎯 Simplified settings persistence
- 🎯 Reduced memory overhead (no XPC process)
- 🎯 Direct JSON file-based storage
- 🎯 Targets: 10 → 9

**Phase 2**: Extension Elimination ✅ COMPLETED
- [x] Delete TextDown Extension target (QuickLook)
- [x] Delete TextDown Shortcut Extension target (Shortcuts)
- [x] Delete external-launcher target (XPC service)
- [x] Remove 2 embed build phases
- [x] Delete Extension/ folder (5 files)
- [x] Delete Shortcut Extension/ folder (5 files)
- [x] Delete external-launcher/ folder (5 files)
- [x] UUID cleanup validation
- [x] Clean build verification
- [x] Bundle size reduction: 77M → 50M (27M / 35%)
- [x] Git commit: 69394e7
- [x] Git tags: phase2-pre-removal, phase2-complete

#### Detailed Execution Process

**Duration**: 2025-10-31 (55 minutes)
**Strategy**: Hybrid (Xcode GUI + Manual cleanup)
**Commit**: `69394e7`
**Files Changed**: 18 deleted, 1 modified
**Bundle Reduction**: 77M → 50M (-27M / -35%)

**Baseline Measurement (Pre-Removal)**:
- Total Bundle: 77M
- PlugIns/: 8.8M (TextDown Extension.appex - QuickLook)
- Extensions/: 19M (TextDown Shortcut Extension.appex)
- Removable: 27.8M total

**8-Step Execution Process**:

**Step 2.0**: Baseline Measurement ✅
- Measured current bundle: 77M
- Identified removable components: 27.8M
- Documented structure for comparison

**Step 2.1**: Rollback Point Created ✅
- Created git tag: `phase2-pre-removal`
- Commit: `035457a` (Phase 4 completion)

**Step 2.2**: Deleted 3 Targets via Xcode GUI ✅
- TextDown Extension.appex (UUID: 831A8C3E258ABADA00E36182)
- TextDown Shortcut Extension.appex (UUID: 8320D5892D1C25B1005868BD)
- external-launcher.xpc (UUID: 83F1FE40259CEE7400257DAC)
- **Result**: Xcode automatically removed all UUID references

**Step 2.3**: Removed 2 Embed Build Phases ✅
- Removed: `Embed Foundation Extensions` (UUID: 831A8C4C258ABADA00E36182)
- Removed: `Embed ExtensionKit Extensions` (UUID: 8320D5952D1C25B1005868BD)
- **Method**: Manual sed editing of project.pbxproj
- **Result**: Clean buildPhases array in TextDown target

**Step 2.4-2.5**: Deleted Extension Folders & Schemes ✅
```bash
git rm -r "Extension/" "Shortcut Extension/" "external-launcher/"
```
- Extension/ (5 files): PreviewViewController.swift, Info.plist, etc.
- Shortcut Extension/ (5 files): MdToHtml_Extension.swift, etc.
- external-launcher/ (5 files): external_launcher.swift, etc.
- 3 .xcscheme files auto-removed by git

**Step 2.6**: UUID Cleanup Validation ✅
- Searched for orphaned target UUIDs: **0 found** ✅
- Searched for orphaned embed phase UUIDs: **0 found** ✅
- Verified project structure integrity: **102 closing braces** ✅
- Verified remaining targets: **1 native + 4 legacy** ✅

**Step 2.7**: Clean Build + Testing ✅
**Core Tests** (4/4 passed):
1. ✅ Clean build succeeds (Release configuration)
2. ✅ App launches without crash
3. ✅ Settings persistence verified (AppConfiguration+Persistence.swift)

**Extended Tests** (Manual verification pending):
- ⚠️ Settings roundtrip test (requires GUI)
- ⚠️ Theme stress test (97 themes)
- ⚠️ Multi-document test (3+ windows)

**Step 2.8**: Final Metrics + Commit ✅
- Final bundle: **50M** (was 77M)
- Reduction: **27M** (35%)
- Committed with comprehensive message
- Created tag: `phase2-complete`

#### Impact Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **Total Bundle** | 77M | 50M | -27M (-35%) |
| **Targets** | 8 | 5 | -3 |
| **Native Targets** | 4 | 1 | -3 |
| **Legacy Targets** | 4 | 4 | 0 |
| **project.pbxproj Lines** | 2,581 | 1,577 | -1,004 (-39%) |
| **Source Files** | - | - | -18 deleted |

#### Files Deleted (18 total)

**Extension/** (5 files):
- PreviewViewController.swift (~500 LOC - QuickLook implementation)
- AppConfiguration+Themes.swift (12 LOC)
- PreviewViewController.xib, Info.plist, Extension.entitlements

**Shortcut Extension/** (5 files):
- MdToHtml_Extension.swift (~200 LOC - App Intent)
- MdToHtmlCode_Extension.swift (~150 LOC)
- Localizable.xcstrings, Info.plist, Shortcut_Extension.entitlements

**external-launcher/** (5 files):
- external_launcher.swift (~100 LOC)
- external_launcherProtocol.swift (~50 LOC)
- external_launcher_delegate.swift (~80 LOC)
- main.swift (~30 LOC), Info.plist

**.xcscheme files** (3 files):
- TextDown Extension.xcscheme
- TextDown Shortcut Extension.xcscheme
- external-launcher.xcscheme

#### project.pbxproj Changes

**Removed Sections**:
- 3 PBXNativeTarget definitions (~100 lines)
- 2 PBXCopyFilesBuildPhase definitions (~20 lines)
- 10+ PBXBuildFile entries
- 15+ PBXFileReference entries
- Multiple PBXTargetDependency entries
- Build configuration lists for deleted targets
- **Total**: 1,004 lines removed (39% reduction)

**Modified Sections**:
- TextDown.app buildPhases: Removed 2 embed phase references
- Build target attributes: Cleaned up deleted target entries

#### Testing Results

**Build Verification**:
```
xcodebuild -scheme TextDown -configuration Release clean build
** BUILD SUCCEEDED **
```

**Bundle Verification**:
```bash
$ du -sh TextDown.app
50M	TextDown.app

$ ls TextDown.app/Contents/PlugIns
ls: PlugIns: No such file or directory  # ✅ Removed

$ ls TextDown.app/Contents/Extensions
ls: Extensions: No such file or directory  # ✅ Removed
```

**Runtime Verification**:
- ✅ App launches successfully
- ✅ Split-view editor functional
- ✅ Live preview working
- ✅ Settings persistence confirmed
- ✅ Sparkle.framework linked (2.7.0)

**Key Achievements**:
- 🎯 Clean target removal (zero orphaned references)
- 🎯 35% bundle size reduction
- 🎯 39% project.pbxproj reduction
- 🎯 Zero orphaned UUIDs
- 🎯 Build + runtime success
- 🎯 Rollback points created

**Phase 3**: NSDocument Architecture ✅ COMPLETED
- [x] Create MarkdownDocument.swift (NSDocument subclass)
- [x] Create MarkdownWindowController.swift
- [x] Rename ViewController → DocumentViewController
- [x] Implement split-view layout (NSTextView + WKWebView)
- [x] Add live preview with debounced rendering
- [x] Multi-window and tabs support
- [x] Fix AboutViewController crash
- [x] Git commits: f6831b6, ebedeaf

#### Detailed Commit History

**Duration**: 2025-10-31
**Total Commits**: 3
**Files Changed**: 12
**Net Change**: +435 insertions, -250 deletions

**Commit 3.1** (`f6831b6`): NSDocument Implementation ✅
**Message**: `feat: Migrate to NSDocument architecture with multi-window support`

**New Files Created**:
- MarkdownDocument.swift (180 LOC)
  - NSDocument subclass for .md, .rmd, .qmd files
  - read(from:ofType:) implementation
  - write(to:ofType:) implementation
  - Auto-save and version management
- MarkdownWindowController.swift (82 LOC)
  - NSWindowController subclass
  - Window title management
  - Document synchronization

**Renamed Files** (git mv):
- ViewController.swift → DocumentViewController.swift
- Preserved full git history (100% similarity)

**Modified Files**:
- DocumentViewController.swift:
  - Added document property (weak reference)
  - Implemented loadDocument(_:) method
  - Added textDidChange(_:) for document updates
  - Split-view layout with NSTextView + WKWebView
  - Live preview with 0.5s debounce
  - Integrated with Settings via NoXPC

- AppDelegate.swift:
  - Removed hardcoded window creation
  - NSDocumentController handles window management
  - Multi-window support via NSDocument

- Main.storyboard:
  - Removed Initial View Controller connection
  - NSDocument creates windows dynamically
  - Document-based File menu

- Info.plist:
  - Added Document Types:
    - Markdown (.md, .markdown)
    - R Markdown (.rmd)
    - Quarto Markdown (.qmd)
  - Role: Editor
  - Class: MarkdownDocument
  - LSHandlerRank: Owner

**Result**: Multi-window, tabs, auto-save, full NSDocument lifecycle
8 files changed (+350, -120)

**Commit 3.2** (`ebedeaf`): Storyboard Fix ✅
**Message**: `fix: Resolve storyboard errors and AboutViewController crash`

**Changes**:
- Fixed AboutViewController crash:
  - Added proper UI layout (labels for app name, version, build, copyright)
  - Connected outlets properly
  - Implemented version string formatting

- Cleaned up Main.storyboard:
  - Removed unreachable "Highlight View Controller" scene
  - Fixed segue connections
  - Validated all outlet connections

**Result**: AboutViewController functional, storyboard warnings resolved
2 files changed (+85, -130)

**Commit 3.3**: External Launcher Removal ✅
(Combined with Phase 1 XPC elimination in commit `5f7cb01`)
- Removed external-launcher.xpc (URL opening XPC service)
- No longer needed after QuickLook Extension removal
- Simplified URL handling via NSWorkspace

**Key Achievements**:
- 🎯 NSDocument architecture implemented
- 🎯 Multi-window support (Cmd+N)
- 🎯 Native tabs (Window → Merge All Windows)
- 🎯 Auto-save after 5 seconds
- 🎯 Dirty state tracking (red dot)
- 🎯 Split-view editor (NSTextView | WKWebView)
- 🎯 Live preview with 0.5s debounce

**Phase 4**: SwiftUI Preferences Window ✅ COMPLETED
- [x] Fix Settings JSON persistence (AppConfiguration+Persistence.swift)
- [x] Implement CSS theme scanning (AppConfiguration+Themes.swift)
- [x] Create AppConfigurationViewModel.swift (327 LOC)
- [x] Create 4 SwiftUI Settings views
- [x] Update AppDelegate with showPreferences()
- [x] Wire up Preferences menu (Cmd+,)
- [x] Test Apply/Cancel functionality
- [x] Test persistence across app restarts
- [x] Clean up DocumentViewController (removed 448 lines)
- [x] Git commit: 0ec1bd0

#### Detailed Commit History

**Duration**: 2025-10-31
**Commit**: `0ec1bd0`
**Message**: `feat: Implement SwiftUI Preferences window with Apply/Cancel pattern`
**Files Changed**: 21
**Net Change**: +1,556 insertions, -736 deletions

**New Files Created** (11 files):

1. **AppConfigurationViewModel.swift** (327 LOC)
   - @MainActor ObservableObject
   - 40 @Published properties for reactive state
   - Combine-based change tracking with hasUnsavedChanges flag
   - apply() method: saves to AppConfiguration.shared + JSON file
   - cancel() method: restores from originalSettings
   - resetToDefaults() method: factory reset

2. **Views/Settings/TextDownSettingsView.swift**
   - Main SwiftUI window with TabView
   - Apply/Cancel buttons in toolbar
   - Apply disabled when no changes
   - Environment(\.dismiss) for window closing

3. **Views/Settings/GeneralSettingsView.swift** (8 properties)
   - About footer toggle, CSS theme override
   - Inline links behavior, Debug mode
   - QuickLook window size (width/height)

4. **Views/Settings/ExtensionsSettingsView.swift** (17 properties)
   - GitHub Flavored Markdown (6): Tables, Autolink, Tag filter, Task lists, YAML headers
   - Custom Extensions (11): Emoji, Heads, Highlight, Inline images, Math, Mentions, Subscript, Superscript, Strikethrough, Custom checkbox styling

5. **Views/Settings/SyntaxSettingsView.swift** (7 properties)
   - Syntax highlighting enable/disable
   - Line numbers option, Tab width, Word wrap
   - Language detection: None / Simple (libmagic) / Accurate (Enry)

6. **Views/Settings/AdvancedSettingsView.swift** (8 properties)
   - cmark Parser Options: Footnotes, Hard breaks, No soft breaks, Unsafe HTML, Smart quotes, Validate UTF-8
   - Render as code toggle
   - Reset to Factory Defaults button

**Bug Fixes**:

- **AppConfiguration+Persistence.swift**:
  - Implemented settingsFromSharedFile() with JSON decoding
  - Implemented saveToSharedFile() with atomic writes
  - Added directory creation if doesn't exist
  - Added error logging via os_log(.settings)

- **AppConfiguration+Themes.swift**:
  - Fixed getAvailableStyles() to scan filesystem correctly
  - Returns sorted array of .css files
  - Creates themes directory if missing

- **AppConfiguration.swift**:
  - Added JSON Codable conformance
  - Implemented settingsFileURL property
  - Added DistributedNotificationCenter for multi-window sync
  - Added os_log statements for debugging

- **OSLog.swift**:
  - Added .settings OSLog category

**Code Cleanup**:

- **DocumentViewController.swift**:
  - Removed 448 lines of commented Settings UI code
  - Removed all TODO comments related to deleted outlets
  - File size: 1420 → 972 lines (32% reduction)
  - Clean code, no commented blocks

**UI Integration**:

- **AppDelegate.swift**:
  - Added `import SwiftUI`
  - Added `private var preferencesWindow: NSWindow?`
  - Implemented showPreferences(_:) method:
    - Creates NSHostingController with TextDownSettingsView
    - Creates NSWindow with floating level
    - Centers and brings to front
    - Reuses existing window if already open
  - Added NSWindowDelegate extension:
    - Cleans up preferencesWindow reference on close

- **Main.storyboard**:
  - Added Preferences menu item
  - Keyboard shortcut: Cmd+,
  - Connected to showPreferences: action in AppDelegate

**Documentation**:
- Updated CLAUDE.md with Phase 4 section
- Updated MIGRATION_LOG.md with completion details

**Testing Performed**:
- ✅ Clean build succeeds without warnings
- ✅ Preferences window opens with Cmd+,
- ✅ All 40 settings properties display correctly
- ✅ Apply button disabled when no changes
- ✅ Cancel button restores original values
- ✅ Reset to Defaults requires Apply to persist
- ✅ Settings persist across app restarts
- ✅ JSON file created in Container sandbox
- ✅ Multi-window synchronization works

**Key Achievements**:
- 🎯 SwiftUI Settings scene (4 tabs)
- 🎯 Apply/Cancel button pattern
- 🎯 Reactive state management (Combine)
- 🎯 JSON file persistence
- 🎯 NSHostingController bridge
- 🎯 Multi-window synchronization
- 🎯 Code cleanup (448 lines removed)
- 🎯 40 Settings Properties Managed

**Current Status**: All phases completed (0, 0.5, 0.75, 1, 2, 3, 4) ✅
**Last Updated**: 2025-10-31
**Branch**: feature/standalone-editor
**Latest Commit**: 69394e7

---

## Migration History & Execution Log

### Phase Execution Summary

| Phase | Duration | Status | Commit | LOC Change | Key Achievement |
|-------|----------|--------|--------|------------|-----------------|
| **0** | 2025-10-30 | ✅ | `9fffa39`-`0ebda1f` | +781, -750 | Complete rebranding to TextDown |
| **0.5** | 2025-10-30 | ✅ | `a545e0d`-`f638528` | +116, -183 | API modernization, deprecation fixes |
| **0.75** | 2025-10-30 | ✅ | `0b0daee`-`5009714` | +71, -1,142 | UI cleanup, split-view prep |
| **1** | 2025-10-31 | ✅ | `5f7cb01` | +50, -450 | XPC Service elimination |
| **2** | 2025-10-31 | ✅ | `69394e7` | +1, -1,679 | Extension elimination (QuickLook + Shortcuts) |
| **3** | 2025-10-31 | ✅ | `f6831b6`, `ebedeaf` | +435, -250 | NSDocument architecture |
| **4** | 2025-10-31 | ✅ | `0ec1bd0` | +1,556, -736 | SwiftUI Preferences window |

**Total Impact**: +3,010 insertions, -5,190 deletions = **-2,180 net LOC** (code simplified)

---

### Phase 2: Extension Elimination (Detailed)

**Execution Strategy**: Hybrid (Xcode GUI + Manual cleanup)
**Duration**: 55 minutes
**Bundle Reduction**: 77M → 50M (27M / 35%)

**8-Step Execution Process**:

1. **Baseline Measurement**: Documented 77M bundle, 27.8M removable
2. **Rollback Point**: Created tag `phase2-pre-removal`
3. **Xcode GUI Deletion**: Removed 3 targets (automatic UUID cleanup)
   - TextDown Extension.appex (QuickLook)
   - TextDown Shortcut Extension.appex (Shortcuts)
   - external-launcher.xpc (XPC service)
4. **Manual Embed Phase Removal**: Deleted 2 embed build phases from project.pbxproj
5. **Folder Deletion**: `git rm -r` for Extension/, Shortcut Extension/, external-launcher/
6. **UUID Validation**: Verified 0 orphaned references
7. **Build & Test**: Clean build + 4 core tests passed
8. **Final Commit**: Tagged as `phase2-complete`

**Files Deleted**: 18 total (5 + 5 + 5 source files + 3 .xcscheme files)
**project.pbxproj Impact**: 2,581 → 1,577 lines (1,004 lines removed, 39% reduction)

**Testing Results**:
- ✅ Clean build succeeds (Release configuration)
- ✅ App launches without crash
- ✅ Settings persistence verified (AppConfiguration+Persistence.swift)

---

## ✅ COMPLETED: Tier 3 Folder Reorganization (November 2025)

**Status**: ✅ COMPLETED (Branch: `refactor/folder-reorganization`)
**Date**: 2025-11-03
**Commit**: `57388a2`

Comprehensive folder reorganization with logical groupings to improve code discoverability and maintainability. All 90 files moved with preserved git history.

### New Folder Structure

```
/Users/home/GitHub/QLMarkdown/
├── TextDown/                           # Main app target
│   ├── Core/                           # App lifecycle & configuration (NEW)
│   │   ├── AppDelegate.swift
│   │   ├── AppConfiguration.swift
│   │   ├── AppConfiguration+Rendering.swift
│   │   ├── AppConfiguration+Persistence.swift
│   │   └── AppConfiguration+Themes.swift
│   │
│   ├── Models/                         # Data layer (NEW)
│   │   └── MarkdownDocument.swift
│   │
│   ├── ViewControllers/                # AppKit controllers (NEW)
│   │   ├── DocumentViewController.swift
│   │   ├── MarkdownWindowController.swift
│   │   └── AboutViewController.swift
│   │
│   ├── Views/                          # SwiftUI components (NEW)
│   │   └── Settings/                   # Renamed from Preferences/
│   │       ├── TextDownSettingsView.swift
│   │       ├── GeneralSettingsView.swift
│   │       ├── ExtensionsSettingsView.swift
│   │       ├── SyntaxSettingsView.swift
│   │       └── AdvancedSettingsView.swift
│   │
│   ├── Utilities/                      # Helpers (NEW)
│   │   ├── Helpers.swift
│   │   ├── NSColor.swift
│   │   └── OSLog.swift
│   │
│   ├── Resources/                      # Xcode managed resources (NEW)
│   │   ├── Assets.xcassets
│   │   └── Base.lproj/
│   │       └── Main.storyboard
│   │
│   ├── Rendering/                      # Markdown pipeline (KEPT)
│   │   ├── MarkdownRenderer.swift
│   │   ├── HeadingIDGenerator.swift
│   │   ├── YamlHeaderProcessor.swift
│   │   └── Rewriters/
│   │       ├── EmojiRewriter.swift
│   │       ├── HighlightRewriter.swift
│   │       ├── SubSupRewriter.swift
│   │       ├── MentionRewriter.swift
│   │       ├── InlineImageRewriter.swift
│   │       └── MathRewriter.swift
│   │
│   ├── Info.plist                      # ROOT (Xcode standard)
│   └── TextDown.entitlements           # ROOT
│
├── BundleResources/                    # Runtime resources (RENAMED from Resources/)
│   ├── default.css
│   └── highlight.js/
│       ├── lib/
│       │   └── highlight.min.js
│       └── styles/
│           └── *.min.css (12 themes)
│
├── docs/                               # Documentation (NEW)
│   └── migration/
│       ├── SWIFT_MARKDOWN_MIGRATION_PLAN.md
│       ├── IMPLEMENTATION_GUIDE.md
│       └── REDUCTION_LOG.md
│
├── TextDownTests2/                     # Test suite
│   ├── Core/                           # NEW
│   │   └── SettingsTests.swift
│   ├── Rendering/                      # NEW (placeholder)
│   └── Snapshots/                      # NEW (baseline HTML files)
│
├── CLAUDE.md                           # Kept at root for discoverability
├── TODO.md                             # Kept at root for discoverability
└── TextDown.xcodeproj/
```

### Impact Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **Files at TextDown/ root** | 16 | 2 | -14 (-88%) |
| **Logical folders** | 2 (Rendering, Preferences) | 7 (Core, Models, ViewControllers, Views, Utilities, Resources, Rendering) | +5 |
| **Files moved** | - | 90 | All with 100% git similarity |
| **Build status** | ✅ | ✅ | No regressions |
| **Test status** | 12/12 passing | 12/12 passing | All tests pass |

### Execution Summary

**Duration**: ~45 minutes
**Method**: Manual git mv + Edit tool for project.pbxproj
**Rollback**: git tag `pre-folder-reorg`

**Phase 1: Folder Creation**
```bash
mkdir -p TextDown/{Core,Models,ViewControllers,Views/Settings,Utilities,Resources}
mkdir -p TextDownTests2/{Core,Rendering,Snapshots}
mkdir -p docs/migration
```

**Phase 2: File Moves (git mv)**
- Core/: 5 files (AppDelegate, AppConfiguration+4)
- Models/: 1 file (MarkdownDocument)
- ViewControllers/: 3 files (DocumentViewController, MarkdownWindowController, AboutViewController)
- Views/Settings/: 5 files (all SwiftUI preference views)
- Utilities/: 3 files (Helpers, NSColor, OSLog)
- Resources/: Assets.xcassets + Base.lproj

**Phase 3: Folder Renames**
- `Resources/` → `BundleResources/` (15 files: highlight.js + default.css)
- `Preferences/` → `Views/Settings/` (5 SwiftUI files)

**Phase 4: Documentation**
- `SWIFT_MARKDOWN_MIGRATION_PLAN.md` → `docs/migration/`
- `IMPLEMENTATION_GUIDE.md` → `docs/migration/`
- `REDUCTION_LOG.md` → `docs/migration/`

**Phase 5: Tests**
- `SettingsTests.swift` → `TextDownTests2/Core/`

**Phase 6: Project Updates**
- `project.pbxproj`: Added 6 new PBXGroup definitions (Core, Models, ViewControllers, Views, Utilities, Resources)
- Updated all file path references
- Updated folder names (BundleResources, Settings)
- `CLAUDE.md`: Updated all file path references
- `TODO.md`: Updated all file path references

### Verification

**Build Verification**:
```bash
xcodebuild -scheme TextDown -configuration Release clean build
** BUILD SUCCEEDED **
```

**Test Verification**:
```bash
xcodebuild test -scheme TextDown -destination 'platform=macOS'
Test Suite 'All tests' passed
12 tests passed, 0 failures
```

**Git History Verification**:
```bash
git log --follow --oneline TextDown/Core/AppConfiguration.swift
# Shows full history from original TextDown/AppConfiguration.swift
```

### Key Achievements

- 🎯 **88% reduction** in root-level files (16 → 2)
- 🎯 **7 logical folders** for clear code organization
- 🎯 **100% git history** preserved (all moves used git mv)
- 🎯 **Zero build regressions** (clean build + all tests pass)
- 🎯 **Improved discoverability** (Core/ for config, Models/ for data, etc.)
- 🎯 **Standard Xcode conventions** (Resources/ for assets, Info.plist at root)
- 🎯 **Clear separation of concerns** (AppKit vs SwiftUI, utilities vs business logic)

### Benefits

1. **Code Discoverability**: New developers can immediately understand project structure
2. **Logical Grouping**: Related files grouped together (all AppConfiguration files in Core/)
3. **Clean Root**: Only essential files at target root (Info.plist, entitlements)
4. **Test Organization**: Tests mirror app structure (Core/, Rendering/, Snapshots/)
5. **Documentation Clarity**: Migration docs grouped in docs/migration/
6. **Resource Disambiguation**: BundleResources/ vs TextDown/Resources/ clear distinction

---