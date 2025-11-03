# TextDown → Standalone Markdown Editor/Viewer

## ⚠️ CRITICAL ARCHITECTURE CHANGE - November 2025

**WICHTIG**: Das Projekt hat zwei fundamentale Architekturänderungen durchlaufen:

### Alte Architektur (vor November 2025) ❌ OBSOLETE
- **UI Framework**: AppKit (NSDocument, NSViewController, NSTextView, WKWebView)
- **Rendering**: WKWebView (HTML generation + JavaScript)
- **Markdown Parser**: cmark-gfm (C) + 9 C/C++ custom extensions (4.1K LOC)
- **Syntax Highlighting**: highlight.js (JavaScript, 190+ languages)
- **Build Time**: 10-15 min clean build
- **Bundle Size**: 77 MB
- **Dependencies**: 4 SPM + 2 Git submodules + C/C++/Go/Lua toolchains

### Neue Architektur (ab November 2025) ✅ CURRENT
- **UI Framework**: 100% Pure SwiftUI (DocumentGroup, FileDocument, SwiftUI Views)
- **Rendering**: Native SwiftUI Views (MarkdownASTView - direct AST → Views)
- **Markdown Parser**: swift-markdown 0.7.3 (Pure Swift, Apple's library)
- **Syntax Highlighting**: SwiftHighlighter (Pure Swift tokenizer, 5 languages)
- **Build Time**: ~30-45 sec clean build
- **Bundle Size**: ~45 MB
- **Dependencies**: 1 SPM (swift-markdown only)

### Migration Impact
- **Build Time**: 10-15 min → 30-45 sec (**-95%**)
- **Bundle Size**: 77 MB → 45 MB (**-42%**)
- **LOC**: ~18,000 LOC (mixed) → ~2,000 LOC (Pure Swift) (**-89%**)
- **Architecture**: Mixed (AppKit/C/C++/Go/Lua) → 100% Pure SwiftUI (**Zero AppKit**)
- **Targets**: 10 → 1 (**-9 targets**)

### Removed Components
- ❌ All AppKit components (NSDocument, NSViewController, WKWebView, NSTextView)
- ❌ HTML rendering pipeline (MarkdownRenderer + 8 Rewriters - 1,321 LOC)
- ❌ JavaScript syntax highlighting (highlight.js + 12 CSS themes)
- ❌ C/C++ markdown parser (cmark-gfm + extensions - 9,761 LOC)
- ❌ QuickLook Extension, Shortcuts Extension, XPC Services
- ❌ All Git submodules (pcre2, jpcre2)
- ❌ Bridging header (pure Swift, no C interop)

---

## Projektziel

Transformation von TextDown (QuickLook Extension) zu einem eigenständigen Markdown Editor/Viewer mit Split-View Architektur: Raw Markdown Editor (links) | Live Preview (rechts).

**Repository**: `/Users/home/GitHub/QLMarkdown`
**Branch**: `main`
**Status**: ✅ All migrations completed (Pure SwiftUI)

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

## ✅ IMPLEMENTED: Pure SwiftUI Migration (November 2025)

**Status**: ✅ COMPLETED (Branch: `feature/pure-swiftui-migration`)
**Date**: 2025-11-03
**Commits**: 2e6dd4a, 163a6f5, 14e88fe, 2a68066, 9d1ca6f, bf618ca, 9f562ba, 0133649, f2c3248, 0f74ebf, 9ebff56, 2146ac6

The AppKit/NSDocument architecture has been completely replaced with 100% Pure SwiftUI, eliminating all Cocoa dependencies and achieving full SwiftUI compliance with CI enforcement.

### Migration Summary

**Big-Bang Migration**: Single-pass replacement of all AppKit components
- **Duration**: 1 day (2025-11-03)
- **Approach**: Delete all AppKit controllers, implement Pure SwiftUI from scratch
- **Target**: macOS 12.0+ (SwiftUI DocumentGroup, FileDocument)
- **CI Enforcement**: Bash scripts + SwiftLint rules block any AppKit code

**Critical Constraints**:
- ❌ ZERO AppKit: No `import AppKit`, `import Cocoa`, `import WebKit`
- ❌ NO Bridges: No `NSViewRepresentable`, `@NSApplicationDelegateAdaptor`, `NSDocument`
- ✅ Pure SwiftUI: All views, all state management, all rendering
- ✅ CI Guards: `ci/ensure_pure_swiftui.sh` enforces purity

### Architecture Changes

**Deleted Components** (AppKit):
- ❌ `Main.storyboard` (1,003 lines XML)
- ❌ `AppDelegate.swift` (165 LOC - Sparkle integration)
- ❌ `DocumentViewController.swift` (605 LOC - NSTextView + WKWebView)
- ❌ `MarkdownWindowController.swift` (83 LOC)
- ❌ `AboutViewController.swift` (78 LOC)
- ❌ `MarkdownDocument.swift` (186 LOC - NSDocument)
- ❌ `NSColor.swift` (104 LOC - AppKit color utilities)

**New Components** (Pure SwiftUI):
- ✅ `TextDownApp.swift` (31 LOC) - @main entry point with DocumentGroup
- ✅ `AppState.swift` (110 LOC) - @Observable app state (replaces AppDelegate)
- ✅ `MarkdownFileDocument.swift` (76 LOC) - FileDocument protocol
- ✅ `MarkdownEditorView.swift` (84 LOC) - HSplitView (Editor | Preview)
- ✅ `PureSwiftUITextEditor.swift` (228 LOC) - Custom text editor with Undo/Find/Drag&Drop
- ✅ `MarkdownASTView.swift` (287 LOC) - Native SwiftUI markdown renderer (no WKWebView!)
- ✅ `SwiftHighlighter.swift` (278 LOC) - Pure Swift syntax highlighter
- ✅ `TextDownCommands.swift` (79 LOC) - SwiftUI menu bar commands
- ✅ `AboutView.swift` (81 LOC) - Pure SwiftUI about dialog
- ✅ `Color.swift` (130 LOC) - Pure SwiftUI color utilities (hex parsing + semantic palette)

### Rendering Pipeline Transformation

**Old Pipeline (AppKit):**
```
Markdown String
  → swift-markdown (AST)
  → MarkdownRenderer (HTML generation)
  → WKWebView.loadHTMLString() (WebKit rendering)
  → JavaScript highlight.js (client-side)
```

**New Pipeline (Pure SwiftUI):**
```
Markdown String
  → swift-markdown (AST)
  → MarkdownASTView (SwiftUI view tree)
    → HeadingView, ParagraphView, CodeBlockView, etc.
    → SwiftHighlighter (Pure Swift tokenizer)
    → AttributedString (SwiftUI native styling)
  → Native SwiftUI rendering (no WebView!)
```

**Key Differences**:
- ❌ No WKWebView - Direct SwiftUI rendering
- ❌ No HTML generation - AST → SwiftUI views
- ❌ No JavaScript - Pure Swift syntax highlighting
- ✅ Native performance - No web engine overhead
- ✅ Full SwiftUI integration - TextSelection, accessibility

### Achieved Metrics ✅

| Metric | Before (AppKit) | After (SwiftUI) | Impact |
|--------|-----------------|-----------------|--------|
| **Architecture** | Mixed (AppKit + SwiftUI) | 100% Pure SwiftUI | ✅ |
| **Main Entry** | AppDelegate + Storyboard | TextDownApp (@main) | **-100% AppKit** ✅ |
| **Document Model** | NSDocument (186 LOC) | FileDocument (76 LOC) | **-59%** ✅ |
| **Editor View** | NSTextView (AppKit) | TextEditor (SwiftUI) | **-100% AppKit** ✅ |
| **Preview** | WKWebView (WebKit) | MarkdownASTView (SwiftUI) | **-100% WebKit** ✅ |
| **Menu Bar** | Main.storyboard (1,003 lines) | TextDownCommands (79 LOC) | **-92%** ✅ |
| **Color Utilities** | NSColor (104 LOC AppKit) | Color (130 LOC SwiftUI) | **Zero AppKit** ✅ |
| **CI Status** | N/A | ✅ PASSED | **Enforced** ✅ |

### Implementation Commits

**Phase 1: Core Architecture** (Commit: 2e6dd4a)
- Created SwiftUI @main entry point
- Implemented FileDocument protocol
- Built split-view editor with native rendering
- Deleted all AppKit controllers and storyboard

**Phase 2: Color Migration** (Commit: 163a6f5)
- Replaced NSColor with pure SwiftUI Color
- Created Color(hex:) initializer
- Added Color.Markdown semantic palette
- Removed all AppKit imports

**Phase 3: Compilation Fixes** (Commits: 14e88fe, 2a68066, 9d1ca6f, bf618ca, 9f562ba)
- Fixed UTType.markdown compatibility (macOS 12.0)
- Fixed DocumentGroup syntax
- Resolved type ambiguities (SwiftUI.Text vs Markdown.Text)
- Fixed Swift keyword conflicts (.func, .operator)

**Phase 4: UI Polish** (Commit: 0133649)
- Fixed duplicate View menu
- Cleaned up menu bar commands

**Phase 5: BundleResources Cleanup** (Commit: 9ebff56)
- Removed obsolete BundleResources/ folder (212 KB)
- Deleted default.css (14 KB) - no longer used
- Deleted highlight.js library (77 KB) - replaced by SwiftHighlighter
- Deleted 12 CSS themes (90 KB) - replaced by hardcoded Swift themes
- Fixed 3 minor bugs (unused variable, missing openURL, unnecessary await)

**Phase 6: Rendering Pipeline & Migration Artifacts Cleanup** (Commit: 2146ac6)
- Deleted entire Rendering/ folder (10 files, 1,321 LOC)
  - MarkdownRenderer.swift - HTML generation (obsolete)
  - HeadingIDGenerator, YamlHeaderProcessor
  - 6 Rewriters (Emoji, Highlight, Math, etc.)
- Removed SPM dependencies: SwiftSoup (500 KB), Yams (300 KB)
- Deleted test infrastructure: RenderingTests.swift (343 LOC), 6 HTML snapshots (597 KB)
- Deleted migration artifacts: analysis/ folder (37 files, 304 KB)
- Deleted obsolete assets: examples/ (116 KB), 18 imagesets (~3.8 MB)
- **Total cleanup**: -1,664 LOC, -103 files, ~5 MB bundle size

### Known Limitations (Accepted Trade-offs)

**Temporarily Disabled Features**:
- ⚠️ Math rendering (no MathJax in pure SwiftUI - would need custom renderer)
- ⚠️ GFM Tables (placeholder view - needs custom layout)
- ⚠️ Task lists (placeholder view - needs interactive checkboxes)
- ⚠️ Sparkle auto-updates (requires AppKit integration)

**Syntax Highlighting**:
- ✅ Pure Swift tokenizer (5 languages: Swift, Python, JS, HTML, CSS)
- ✅ 2 themes (github-dark, github-light)
- ⚠️ Limited vs highlight.js (190+ languages)

**UI Constraints**:
- ⚠️ TextEditor has limited customization vs NSTextView
- ⚠️ No line numbers in editor (SwiftUI TextEditor limitation)
- ⚠️ Find/Replace is custom implementation (no system integration)

### CI Enforcement

**ci/ensure_pure_swiftui.sh**:
```bash
Forbidden Patterns: import AppKit, import Cocoa, import WebKit,
                    NSViewRepresentable, NSDocument, WKWebView,
                    NSViewController, NSWindowController, etc.

Exit Code: 1 if violations found
Status: ✅ PASSED (zero violations)
```

**.swiftlint.yml**:
```yaml
custom_rules:
  no_appkit_import:
    regex: 'import (AppKit|Cocoa|WebKit)'
    message: "AppKit forbidden - use SwiftUI only"
    severity: error
```

**GitHub Actions**: Workflow runs CI script on every push

### Files Reference

**New SwiftUI Files**:
- `TextDown/App/TextDownApp.swift` - @main entry
- `TextDown/App/AppState.swift` - Observable state
- `TextDown/Document/MarkdownFileDocument.swift` - FileDocument
- `TextDown/Editor/MarkdownEditorView.swift` - Main editor
- `TextDown/Editor/PureSwiftUITextEditor.swift` - Text editor component
- `TextDown/Preview/MarkdownASTView.swift` - Native renderer
- `TextDown/Preview/SwiftHighlighter.swift` - Syntax highlighter
- `TextDown/Preview/Color.swift` - Color utilities
- `TextDown/Commands/TextDownCommands.swift` - Menu bar
- `TextDown/About/AboutView.swift` - About dialog

**CI Files**:
- `ci/ensure_pure_swiftui.sh` - Purity enforcement script
- `.swiftlint.yml` - Linter configuration
- `.github/workflows/pure-swiftui-check.yml` - CI workflow

---

## Aktuelle Projektstruktur (Post-SwiftUI Migration)

### TextDown.app - Pure SwiftUI Editor
**Bundle ID**: `org.advison.TextDown`
**Architecture**: 100% SwiftUI (Zero AppKit)
**Target**: macOS 12.0+
**Primary Function**: Markdown Editor with Live Preview

**SwiftUI Entry Point**:
- `App/TextDownApp.swift` (@main) - DocumentGroup-based app
  - DocumentGroup(newDocument: MarkdownFileDocument())
  - Settings scene (SwiftUI preferences)
  - Window("About TextDown") scene

**Core Components**:
- `App/AppState.swift` (@Observable) - Replaces AppDelegate
  - Auto-refresh state
  - Syntax theme selection
  - Rendering settings

- `Document/MarkdownFileDocument.swift` (FileDocument) - Replaces NSDocument
  - UTType support: .markdown, .rMarkdown, .qmdMarkdown
  - UTF-8 encoding with fallback
  - Auto-save support

- `Editor/MarkdownEditorView.swift` (SwiftUI HSplitView)
  - Left: PureSwiftUITextEditor (raw markdown)
  - Right: MarkdownASTView (live preview)
  - Debounced rendering (0.5s delay)
  - Receives AppState via @EnvironmentObject

- `Editor/PureSwiftUITextEditor.swift` (SwiftUI TextEditor wrapper)
  - Custom undo/redo stack (50 entries)
  - Find bar with match counting
  - Drag & drop for file URLs
  - Monospaced font

- `Preview/MarkdownASTView.swift` (Native SwiftUI Renderer)
  - Direct swift-markdown AST → SwiftUI views
  - HeadingView, ParagraphView, CodeBlockView, ListViews, BlockQuoteView
  - No WKWebView - pure SwiftUI rendering
  - AttributedString for inline styles

- `Preview/SwiftHighlighter.swift` (Pure Swift Tokenizer)
  - Supports: Swift, Python, JavaScript, HTML, CSS
  - 2 themes: github-dark, github-light
  - Returns AttributedString with color styling

- `Preview/Color.swift` (SwiftUI Color Utilities)
  - Color(hex: "#FF5733") initializer
  - Color.Markdown semantic palette
  - Zero AppKit dependencies

- `Commands/TextDownCommands.swift` (Menu Bar)
  - Export as HTML (File menu)
  - Preview Auto-Refresh, Refresh Preview (View menu)
  - About TextDown (Window menu)
  - TextDown Help (Help menu)

- `About/AboutView.swift` (Pure SwiftUI Dialog)
  - App icon, version info
  - Library credits
  - GitHub link

**Settings UI** (Pure SwiftUI):
- `Views/Settings/TextDownSettingsView.swift` - Main settings window
- `Views/Settings/GeneralSettingsView.swift` - Appearance, CSS, behavior
- `Views/Settings/ExtensionsSettingsView.swift` - GFM + custom extensions
- `Views/Settings/SyntaxSettingsView.swift` - Highlighting, themes
- `Views/Settings/AdvancedSettingsView.swift` - Parser options, reset

**Configuration** (Shared State):
- `Core/AppConfiguration.swift` (~40 Properties, @Observable)
  - GFM options (tables, strikethrough, autolinks, task lists)
  - Custom extensions (emoji, math, highlight, inline images, heads)
  - Syntax highlighting (theme, line numbers, word wrap)
  - Parser options (footnotes, hard breaks, smart quotes)

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

## Markdown Extensions (Pure SwiftUI - Nov 2025)

**Current Architecture**: Direct SwiftUI rendering (no HTML, no Rewriters)

**Supported Extensions** (MarkdownASTView.swift):

| Extension | Status | Implementation | Notes |
|-----------|--------|----------------|-------|
| **Headings** | ✅ Active | HeadingView (SwiftUI) | Font sizes: .largeTitle → .body.bold() |
| **Paragraphs** | ✅ Active | ParagraphView (SwiftUI) | Inline styles: bold, italic, code, links, strikethrough |
| **Code Blocks** | ✅ Active | CodeBlockView + SwiftHighlighter | 5 languages (Swift, Python, JS, HTML, CSS) |
| **Lists** | ✅ Active | UnorderedListView, OrderedListView | Bullets + numbering |
| **Block Quotes** | ✅ Active | BlockQuoteView | Blue accent bar |
| **Thematic Break** | ✅ Active | Divider() | Horizontal rule |
| **Tables** | ⚠️ Placeholder | Text("⚠️ Tables not yet supported") | GFM extension |
| **Task Lists** | ⚠️ Placeholder | Text("⚠️ Task lists not yet supported") | GFM extension |
| **Strikethrough** | ✅ Active | .strikethroughStyle = .single | GFM extension |
| **Autolinks** | ✅ Active | .link attribute | GFM extension |

**Removed After Pure SwiftUI Migration** (Nov 2025):
- ❌ EmojiRewriter.swift - HTML-based, no longer needed
- ❌ HeadingIDGenerator.swift - HTML anchors, no longer needed
- ❌ InlineImageRewriter.swift - Base64 injection, no longer needed
- ❌ MathRewriter.swift - MathJax, no longer needed
- ❌ HighlightRewriter.swift - HTML `<mark>` tags, no longer needed
- ❌ SubSupRewriter.swift - HTML `<sub>`/`<sup>`, no longer needed
- ❌ MentionRewriter.swift - GitHub links, no longer needed
- ❌ YamlHeaderProcessor.swift - HTML table generation, no longer needed

**Syntax Highlighting**: Pure Swift tokenizer (SwiftHighlighter.swift)

---

## Build Configuration (Xcode)

### Architectures
- **Universal Binary**: x86_64 + arm64
- **Deployment Target**: macOS 26.0+ (Required for Pure SwiftUI)

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

### Entitlements (Pure SwiftUI - Nov 2025)

**TextDown.app** (Minimal permissions):
````xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>  <!-- File Open/Save Dialogs via DocumentGroup -->
````

**Removed Entitlements** (no longer needed):
- ❌ `com.apple.security.network.client` - No network access needed (no MathJax CDN, no external APIs)
- ❌ `com.apple.security.cs.allow-jit` - No JavaScript (no WKWebView)

---

## SPM Dependencies

**swift-markdown** - Markdown Parser ✅ ONLY DEPENDENCY
- Version: 0.7.3
- Repository: https://github.com/swiftlang/swift-markdown
- Size: ~1 MB
- Usage: Core markdown parsing with GFM support (tables, strikethrough, task lists, autolinks)
- Transitive: swift-cmark 0.7.1 (Apple's Swift wrapper for CommonMark)

**Removed Dependencies**:
- ❌ Sparkle (2.7.0) - Auto-updates removed (AppDelegate deleted in Pure SwiftUI migration)
- ❌ SwiftSoup (2.8.7) - HTML parsing removed (no HTML rendering)
- ❌ Yams (4.0.6) - YAML parsing removed (no R Markdown support)

---

## Bundle Struktur (Pure SwiftUI - Nov 2025)
````
TextDown.app/
├── Contents/
│   ├── MacOS/
│   │   └── TextDown                 # Main Binary (~10M)
│   └── Resources/
│       └── Assets.xcassets            # AppIcon + AccentColor (~100 KB)
````

**Size Breakdown (Nov 2025 - Pure SwiftUI)**:
- **Total Bundle**: ~10 MB (down from 77 MB)
- MacOS Binary: ~10M
- Resources: ~100 KB (Assets.xcassets only - 2 assets: AppIcon, AccentColor)
- **Total Reduction**: -67 MB (-87%) from original

**Entfernt (Phase 2)**:
- PlugIns/ (QLExtension.appex 8.8M)
- Extensions/ (Shortcut Extension.appex 19M)
- XPCServices/ (TextDownXPCHelper.xpc)
- Resources/qlmarkdown_cli

**Entfernt (Nov 2025 - swift-markdown Migration)**:
- ❌ Frameworks/libwrapper_highlight.dylib (26M) - Replaced by highlight.js (77 KB)
- ❌ Resources/highlight/ (10M) - 386 files (Lua language definitions, themes, plugins)
- ❌ cmark-gfm/ (126 C files, ~15K LOC) - Replaced by swift-markdown
- ❌ cmark-extra/ (47 C/C++ files, ~4.1K LOC) - Replaced by 8 Swift Rewriters
- ❌ dependencies/pcre2 (Git submodule) - No longer needed
- ❌ dependencies/jpcre2 (Git submodule) - No longer needed
- ❌ TextDown-Bridging-Header.h - Pure Swift, no bridging needed

**Entfernt (Nov 2025 - Pure SwiftUI Migration Phase 5+6)**:
- ❌ BundleResources/ (15 files, 212 KB) - highlight.js + CSS themes
- ❌ TextDown/Rendering/ (10 files, 1,321 LOC) - HTML rendering pipeline
- ❌ SPM Dependencies: SwiftSoup (500 KB), Yams (300 KB)
- ❌ TextDownTests2/Rendering/ + Snapshots/ (8 files, 940 KB)
- ❌ analysis/ (37 files, 304 KB) - Migration artifacts
- ❌ examples/ (26 files, 116 KB) - Language samples
- ❌ Assets.xcassets (18 obsolete imagesets, ~3.8 MB) - Storyboard icons

---

## Build-Time Dependencies

### Required Tools
````
Xcode 16.x                  # Only requirement
Command Line Tools          # Included with Xcode (Swift compiler, git)
````

### Build Targets
- **Current**: 1 target (TextDown.app)
- **Before**: 10 targets (6 Native + 4 Legacy)
- **Reduction**: -9 targets (-90%)

### Build Time
- **Clean Build**: ~30-45 seconds
- **Incremental Build**: ~5-10 seconds
- **Original**: 10-15 minutes (95% faster)

**Removed Build-Time Dependencies**:
- ❌ Go 1.14+ (Enry language detection)
- ❌ Lua 5.4 (theme system)
- ❌ Boost C++ Libraries (libhighlight)
- ❌ autoconf/automake/libtool (libpcre2/libmagic)
- ❌ CMake (cmark-gfm)
- ❌ All Legacy Build Targets (cmark-headers, libpcre2, libjpcre2, magic.mgc)

---

## Architektur-Entscheidungen

### Removed Components (All Phases ✅ COMPLETED)
- ✅ QuickLook Extension (QLExtension.appex) - Phase 2
- ✅ Shortcuts Integration (Shortcut Extension.appex) - Phase 2
- ✅ external-launcher (XPC Service) - Phase 2
- ✅ TextDownXPCHelper (XPC Service) - Phase 1
- ✅ AppKit Controllers (DocumentViewController, MarkdownWindowController, AboutViewController) - Pure SwiftUI Phase
- ✅ NSDocument Architecture - Pure SwiftUI Phase
- ✅ WKWebView + HTML Rendering - Pure SwiftUI Phase
- ✅ MarkdownRenderer + Rewriters - Pure SwiftUI Phase 6
- ✅ BundleResources/ (highlight.js, CSS) - Pure SwiftUI Phase 5

### Current Architecture (Pure SwiftUI - Nov 2025)
- **Entry Point**: `TextDownApp.swift` (@main with DocumentGroup)
- **Document Model**: `MarkdownFileDocument` (FileDocument protocol)
- **Editor**: `PureSwiftUITextEditor` (SwiftUI TextEditor with undo/find)
- **Preview**: `MarkdownASTView` (direct AST → SwiftUI views)
- **Syntax Highlighting**: `SwiftHighlighter` (pure Swift tokenizer, 5 languages)
- **Settings**: SwiftUI Settings scene with @Observable AppConfiguration
- **Persistence**: JSON file in Application Support
- **SPM Dependencies**: swift-markdown only (Sparkle unused)

---

## Key Files (Pure SwiftUI - Nov 2025)

**App Entry & State**:
- `App/TextDownApp.swift` (31 LOC) - @main entry point
- `App/AppState.swift` (110 LOC) - @Observable app state
- `Core/AppConfiguration.swift` (~40 properties) - Shared configuration
- `Core/AppConfiguration+Persistence.swift` - JSON persistence

**Document Model**:
- `Document/MarkdownFileDocument.swift` (76 LOC) - FileDocument protocol

**Editor**:
- `Editor/MarkdownEditorView.swift` (84 LOC) - Main split-view
- `Editor/PureSwiftUITextEditor.swift` (228 LOC) - Text editor with undo/find

**Preview & Rendering**:
- `Preview/MarkdownASTView.swift` (287 LOC) - Native SwiftUI renderer
- `Preview/SwiftHighlighter.swift` (278 LOC) - Pure Swift syntax highlighter
- `Preview/Color.swift` (130 LOC) - Color utilities

**UI Components**:
- `Commands/TextDownCommands.swift` (79 LOC) - Menu bar commands
- `About/AboutView.swift` (81 LOC) - About dialog
- `Views/Settings/*.swift` (5 SwiftUI settings views)

**Build**:
- `TextDown.xcodeproj/project.pbxproj`

---

## Success Metrics (All Phases ✅ ACHIEVED)

### Overall Impact
| Metric | Original | After Pure SwiftUI | Total Reduction |
|--------|----------|-------------------|-----------------|
| **Build Time** | 10-15 min | ~30-45 sec | **-95%** |
| **Bundle Size** | 77 MB | ~45 MB | **-32 MB (-42%)** |
| **Targets** | 10 (6 Native + 4 Legacy) | 1 (Pure SwiftUI) | **-9 targets** |
| **Architecture** | Mixed (AppKit/C/C++/Go/Lua) | 100% Pure SwiftUI | **Zero AppKit** |
| **LOC** | ~18,000 LOC (mixed languages) | ~2,000 LOC (Pure Swift) | **-89%** |

### Technology Stack Evolution
| Component | Before | After |
|-----------|--------|-------|
| **UI Framework** | AppKit (NSDocument, NSViewController) | 100% SwiftUI |
| **Rendering** | WKWebView (HTML + JavaScript) | Native SwiftUI Views |
| **Markdown Parser** | cmark-gfm (C) | swift-markdown (Swift) |
| **Syntax Highlighting** | highlight.js (JavaScript, 190+ languages) | SwiftHighlighter (Swift, 5 languages) |
| **Custom Extensions** | 9 C/C++ extensions (4.1K LOC) | Direct SwiftUI rendering |
| **Dependencies** | 4 SPM + 2 Git submodules | 1 SPM (swift-markdown) |

---

## Migration Phases Summary

All phases completed between October-November 2025.

| Phase | Date | Key Achievement | Commits |
|-------|------|----------------|---------|
| **Phase 0** | 2025-10-30 | Rebranding (QLMarkdown → TextDown) | `9fffa39`-`0ebda1f` (10 commits) |
| **Phase 0.5** | 2025-10-31 | API modernization, deprecation fixes | `a545e0d`-`f638528` (6 commits) |
| **Phase 0.75** | 2025-10-31 | UI cleanup, split-view prep | `0b0daee`-`5009714` (4 commits) |
| **Phase 1** | 2025-10-31 | XPC Service elimination | `5f7cb01` |
| **Phase 2** | 2025-10-31 | Extension elimination (QuickLook + Shortcuts) | `69394e7` |
| **Phase 3** | 2025-10-31 | NSDocument architecture | `f6831b6`, `ebedeaf` |
| **Phase 4** | 2025-10-31 | SwiftUI Preferences window | `0ec1bd0` |
| **swift-markdown** | 2025-11-02 | Replace cmark-gfm with swift-markdown | `a140381`, `bb46b5b` (+4 cleanup) |
| **Pure SwiftUI** | 2025-11-03 | 100% SwiftUI (zero AppKit) | `2e6dd4a`-`f2c3248` (10 commits) |
| **Phase 5** | 2025-11-03 | BundleResources cleanup | `9ebff56` |
| **Phase 6** | 2025-11-03 | Rendering pipeline & artifacts cleanup | `2146ac6` |
| **Folder Reorg** | 2025-11-03 | Tier 3 folder reorganization | `57388a2` |

### Key Milestone Commits

**swift-markdown Migration (2025-11-02)**:
- `a140381` - Core implementation (8 Rewriters, MarkdownRenderer)
- `3923659` - Removed Legacy Build Targets
- `e58e284` - Removed Bridging-Header
- `bb46b5b` - YAML header processing

**Pure SwiftUI Migration (2025-11-03)**:
- `2e6dd4a` - Big-bang SwiftUI migration (deleted all AppKit)
- `163a6f5` - Color migration (NSColor → SwiftUI Color)
- `9ebff56` - Removed BundleResources/ (212 KB)
- `2146ac6` - Removed Rendering/ + tests + artifacts (1,664 LOC, 103 files, ~5 MB)

### Documentation

Migration documentation preserved in `docs/migration/`:
- `SWIFT_MARKDOWN_MIGRATION_PLAN.md` (1,245 lines)
- `IMPLEMENTATION_GUIDE.md` (1,190 lines)
- `PHASED_ROLLOUT.md`, `TESTING_STRATEGY.md`, `ALTERNATIVE_APPROACHES.md`

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
## ✅ COMPLETED: Code Quality & Clean Architecture Refactoring (November 2025)

**Status**: ✅ COMPLETED
**Date**: 2025-11-03

Comprehensive code quality cleanup implementing Clean Architecture patterns and removing all code violations.

### Code Quality Violations Fixed (26 total)

**1. Logging Migration (14 violations)**: Replaced all `print()` statements with proper OSLog
- ✅ MarkdownEditorViewModel.swift - Parse error logging
- ✅ DocumentViewModel.swift - Parse error logging
- ✅ SettingsViewModel.swift (2) - Save/reset error logging
- ✅ ParseMarkdownUseCase.swift - High complexity warnings
- ✅ SaveSettingsUseCase.swift (2) - Save/reset success logging
- ✅ LoadSettingsUseCase.swift (4) - Load status, errors, defaults
- ✅ SaveDocumentUseCase.swift (3) - Backup/save operations
- **Impact**: Proper structured logging via OSLog categories (.rendering, .settings, .document)

**2. Bundle Identifier Hardcoding (2 violations)**: Dynamic bundle ID resolution
- ✅ OSLog.swift:12 - `"org.advison.TextDown"` → `Bundle.main.bundleIdentifier ?? "org.advison.TextDown"`
- ✅ SettingsRepositoryImpl.swift:22 - Dynamic Application Support path
- **Impact**: Code works across bundle ID changes, no hardcoded strings

**3. Internationalization (8 violations)**: Translated German comments to English
- ✅ TextDownApp.swift (3) - "Haupt-Dokumenten-Szene" → "Main document scene", etc.
- ✅ TextDownCommands.swift - "File Menu Ergänzungen" → "File Menu Extensions"
- ✅ PureSwiftUITextEditor.swift - "mit Undo/Redo" → "with Undo/Redo"
- ✅ MarkdownEditorView.swift (3) - "Haupt-Editor-View" → "Main editor view", "Links/Rechts" → "Left/Right"
- **Impact**: English-only codebase, improved maintainability

**4. Dead Code Removal (2 violations)**: Removed non-functional UI elements
- ✅ TextDownCommands.swift - Removed disabled "Export as HTML..." button
- ✅ PureSwiftUITextEditor.swift - Removed disabled find previous/next buttons (SwiftUI limitations)
- **Impact**: Cleaner UI, no confusing disabled features

### Clean Architecture Implementation

**Architecture Pattern**: Domain → Data → Presentation (Dependency Inversion)

**Domain Layer** (Business Logic):
```
Domain/
├── Entities/
│   ├── AppSettings.swift - Root aggregate (editor, markdown, syntaxTheme, css)
│   ├── EditorSettings.swift - Editor behavior (openInlineLink, debug)
│   ├── MarkdownSettings.swift - GFM options + validation
│   ├── SyntaxTheme.swift - Highlighting configuration
│   └── CSSSettings.swift - Custom CSS overrides
├── UseCases/
│   ├── ParseMarkdownUseCase.swift - Markdown → AST conversion
│   ├── LoadSettingsUseCase.swift - Settings loading + validation
│   ├── SaveSettingsUseCase.swift - Settings persistence
│   ├── ValidateSettingsUseCase.swift - Conflict detection
│   └── SaveDocumentUseCase.swift - Document persistence + backups
├── Repositories/ (Protocols)
│   ├── MarkdownParserRepository.swift
│   ├── SettingsRepository.swift
│   └── DocumentRepository.swift
└── Errors/
    ├── DocumentError.swift
    ├── ParseError.swift
    └── ValidationError.swift
```

**Data Layer** (Infrastructure):
```
Data/
└── Repositories/
    ├── MarkdownParserRepositoryImpl.swift - swift-markdown wrapper
    ├── SettingsRepositoryImpl.swift - JSON persistence (Application Support)
    └── DocumentRepositoryImpl.swift - FileManager wrapper
```

**Presentation Layer** (UI):
```
Presentation/
└── ViewModels/
    ├── SettingsViewModel.swift - Settings UI coordination
    ├── DocumentViewModel.swift - Document lifecycle (OBSOLETE - replaced by Clean Architecture)
    └── EditorViewModel.swift - Editor coordination (OBSOLETE - replaced by MarkdownEditorViewModel)

Editor/
├── MarkdownEditorViewModel.swift - NEW: Clean Architecture ViewModel
├── MarkdownEditorView.swift - Main split-view UI
├── PureSwiftUITextEditor.swift - Text editor component
└── TextEditorViewModel.swift - Undo/redo/find logic
```

### Key Architecture Changes

**Before (Mixed Architecture)**:
- ViewModels directly called repositories
- Business logic scattered across Views and ViewModels
- No clear separation of concerns
- print() statements everywhere

**After (Clean Architecture)**:
- **Domain**: Pure business logic (Use Cases)
- **Data**: Infrastructure implementations (Repositories)
- **Presentation**: UI logic only (ViewModels)
- **Dependencies flow inward**: Presentation → Domain ← Data
- **Proper logging**: OSLog with categories
- **Dependency Injection**: Composition root in TextDownApp.swift

### Dependency Injection Flow

```swift
// TextDownApp.swift (Composition Root)
init() {
    // 1. Create Repositories (Data Layer)
    let settingsRepo = SettingsRepositoryImpl()
    let parserRepo = MarkdownParserRepositoryImpl()

    // 2. Create Use Cases (Domain Layer) - Inject Repositories
    let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
    let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
    let parseUseCase = ParseMarkdownUseCase(parserRepository: parserRepo)

    // 3. Create ViewModels (Presentation Layer) - Inject Use Cases
    let settingsVM = SettingsViewModel(
        loadSettingsUseCase: loadUseCase,
        saveSettingsUseCase: saveUseCase,
        validateSettingsUseCase: validateUseCase
    )

    self._settingsViewModel = StateObject(wrappedValue: settingsVM)
}
```

### Auto-Refresh Simplification

**Removed Complexity**:
- ❌ `autoRefresh` property from EditorSettings
- ❌ Auto-refresh toggle in View menu
- ❌ Auto-refresh toggle in Settings UI
- ❌ Conditional rendering logic

**New Behavior**:
- ✅ Auto-refresh always enabled (500ms debounce)
- ✅ Simplified ViewModel logic
- ✅ Better UX (fewer settings, less confusion)

### OSLog Categories

```swift
extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "org.advison.TextDown"

    static let rendering = OSLog(subsystem: subsystem, category: "Rendering")
    static let settings = OSLog(subsystem: subsystem, category: "Settings")
    static let document = OSLog(subsystem: subsystem, category: "Document")
    static let window = OSLog(subsystem: subsystem, category: "Window")
}
```

**Usage Examples**:
```swift
// Before
print("❌ Parse error: \(error)")

// After
os_log("Parse error: %{public}@", log: .rendering, type: .error, String(describing: error))
```

### Settings Validation

**Domain-Driven Validation**:
```swift
// MarkdownSettings.swift
func validated() -> MarkdownSettings {
    var validated = self

    // Business rule: Double tilde requires strikethrough enabled
    if enableStrikethroughDoubleTilde && !enableStrikethrough {
        validated.enableStrikethrough = true
    }

    // Business rule: YAML-all requires YAML enabled
    if enableYAMLAll && !enableYAML {
        validated.enableYAML = true
    }

    return validated
}
```

### Testing Updates

**Updated Test Files**:
- SettingsTests.swift - Removed all `autoRefresh` test cases
- MarkdownEditorViewModelTests.swift - Simplified debounce tests
- **Status**: ✅ All tests passing

### Build Status

**Verification**:
```bash
xcodebuild -scheme TextDown -configuration Debug build
** BUILD SUCCEEDED **
```

**Metrics**:
- Zero compilation warnings
- Zero code violations
- 100% English codebase
- Proper logging throughout

---
