# TextDown → Standalone Markdown Editor/Viewer

## Projektziel

Transformation von TextDown (QuickLook Extension) zu einem eigenständigen Markdown Editor/Viewer mit Split-View Architektur: Raw Markdown Editor (links) | Live Preview (rechts).

**Repository**: `/Users/home/GitHub/QLMarkdown`
**Branch**: `main`
**Migration-Branch**: `feature/standalone-editor`

---

## Aktuelle Projektstruktur (Pre-Migration)

### TextDown.app - Main Application
**Bundle ID**: `org.advison.TextDown`
**Primary Function**: Settings UI + Theme Editor (kein aktiver Editor!)

**Kernklassen**:
- `ViewController.swift` (1200+ Zeilen) - Settings UI mit Live-Preview
  - Markdown Input: NSTextView (für Beispiel-Text)
  - Preview: WKWebView (zeigt gerendertes HTML)
  - Theme Selector + CSS Editor
  - Export HTML Funktionalität
- `AppDelegate.swift` - App Lifecycle, Sparkle Updates, CLI Installation
- `Settings.swift` (~40 Properties) - Rendering-Konfiguration
- `Settings+render.swift` - Haupt-Rendering-Engine
- `Settings+XPC.swift` - XPC Communication (wird entfernt)
- `Settings+NoXPC.swift` - Direkte UserDefaults Persistenz (wird verwendet)

**Wichtige Properties in Settings.swift**:
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
customStyleCSS: String               // Custom CSS override
````

### Extensions & XPC Services (werden entfernt)

**QLExtension.appex** (QuickLook):
- `PreviewViewController.swift` (~500 Zeilen)
- Implementiert `QLPreviewingController` Protocol
- Nutzt **dieselbe** Rendering-Pipeline wie Main App
- Dependency: external-launcher.xpc für URL-Opening

**Shortcut Extension.appex**:
- `MdToHtml_Extension.swift` - App Intent für macOS 15.2+
- Exponiert alle 40+ Settings als Parameters

**qlmarkdown_cli**:
- Standalone Binary in Contents/Resources/
- Verwendet Settings aus Shared UserDefaults

**TextDownXPCHelper.xpc**:
- Settings Persistenz zwischen App/Extensions
- `TextDownXPCHelperProtocol` Functions:
  - `getSettings()` / `setSettings()`
  - `getStylesFolder()` / `getAvailableStyles()`
  - `storeStyle()` / `getFileContents()`

---

## Markdown Extensions (cmark-extra)

**Implementierte Extensions** (alle in C/C++):

| Extension | File | Function | Dependencies |
|-----------|------|----------|--------------|
| **emoji** | emoji.c | `:smile:` → 😄 | emoji_utils.cpp, GitHub API JSON |
| **heads** | heads.c | Auto-Anchor `## Hello` → `id="hello"` | libpcre2 (Regex) |
| **inlineimage** | inlineimage.c | `![](local.png)` → Base64 Data URL | libmagic (MIME), b64.c |
| **math** | math_ext.c | `$E=mc^2$` → MathJax CDN | - |
| **syntaxhighlight** | syntaxhighlight.c | Fenced Code → Colored HTML | wrapper_highlight |
| **highlight** | highlight.c | `==marked text==` Support | - |
| **sub/sup** | sub_ext.c, sup_ext.c | `~sub~` und `^sup^` | - |
| **mention** | mention.c | GitHub `@username` | - |
| **checkbox** | checkbox.c | Task List `- [ ]` Styling | - |

**GitHub Core Extensions** (cmark-gfm):
- table, strikethrough, autolink, tasklist, tagfilter

---

## Rendering Pipeline (Detailliert)
````
User Markdown String
  ↓
Settings+render.swift: render(text:filename:forAppearance:)
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 1: Extension Registration            │
├─────────────────────────────────────────────┤
│ cmark_gfm_core_extensions_ensure_registered │
│ cmark_gfm_extra_extensions_ensure_registered│
│                                             │
│ Registrierte Extensions:                    │
│ - table, strikethrough, autolink, tasklist  │
│ - emoji, heads, inlineimage, math           │
│ - syntaxhighlight, highlight, sub, sup      │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 2: Parser Initialization             │
├─────────────────────────────────────────────┤
│ parser = cmark_parser_new(options)         │
│                                             │
│ Foreach enabled extension:                  │
│   ext = cmark_find_syntax_extension(name)  │
│   cmark_parser_attach_syntax_extension()   │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 3: Parse Markdown → AST              │
├─────────────────────────────────────────────┤
│ cmark_parser_feed(parser, text, len)      │
│ doc = cmark_parser_finish(parser)          │
│                                             │
│ AST Nodes: heading, paragraph, code_block, │
│            list, table, image, etc.        │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 4: Extension Processing              │
├─────────────────────────────────────────────┤
│ Foreach Code Block Node:                   │
│   syntaxhighlight.c: html_render()         │
│     ↓                                       │
│     Get language from fence: ```python     │
│     ↓                                       │
│     IF language empty:                      │
│       - GuessEngine.accurate → Enry        │
│       - GuessEngine.simple → libmagic      │
│     ↓                                       │
│     wrapper_highlight.cpp:                  │
│       highlight_format_string2()           │
│         ↓                                   │
│         libhighlight:                       │
│           CodeGenerator::generateString()  │
│           ↓                                 │
│           Load: langDefs/python.lang       │
│           Apply: themes/solarized-dark.lua │
│           ↓                                 │
│           HTML: <span class="hl kwa">def   │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 5: Render AST → HTML                 │
├─────────────────────────────────────────────┤
│ html = cmark_render_html(doc, options, ext)│
│                                             │
│ Output: HTML Body Fragment                 │
│ - <h1>Headlines mit id="anchor"</h1>       │
│ - <code class="language-python">...</code> │
│ - <img src="data:image/png;base64,...">    │
│ - \(E=mc^2\) für MathJax                   │
└─────────────────────────────────────────────┘
  ↓
┌─────────────────────────────────────────────┐
│ STAGE 6: HTML Post-Processing (Swift)      │
├─────────────────────────────────────────────┤
│ SwiftSoup: Parse HTML                      │
│                                             │
│ 1. Inject Custom CSS (customStyleCSS)     │
│ 2. Add MathJax CDN if math blocks present  │
│ 3. Dark Mode Media Queries                 │
│ 4. Wrap in full HTML document:             │
│    <!doctype html>                         │
│    <html><head>...</head><body>...</body>  │
└─────────────────────────────────────────────┘
  ↓
Complete HTML String → WKWebView.loadHTMLString()
````

**Critical Functions**:
- `cmark_parse_document()` - Entry Point (C)
- `cmark_render_html()` - AST → HTML (C)
- `highlight_format_string2()` - Code → Syntax Highlighted HTML (C++)
- `enry_guess_language()` - Content-Based Language Detection (Go)
- `magic_guess_language()` - MIME-Based Language Detection (C)

---

## Theme System

**Location**: `Resources/highlight/themes/`

**Structure**:
````
themes/
├── acid.lua, zenburn.lua, github.lua          # Base Themes
├── solarized-light.lua, solarized-dark.lua   # Popular
└── base16/*.lua                               # 48 Base16 Variants
````

**Theme Format** (Lua Table):
````lua
-- themes/solarized-dark.theme
Description = "Precision colors for machines and people"
Categories = {"dark"}

Canvas = { Colour="#002b36" }           -- Background
Default = { Colour="#839496" }          -- Default Text
Number = { Colour="#2aa198" }
String = { Colour="#2aa198" }
Escape = { Colour="#dc322f", Bold=true }
BlockComment = { Colour="#657b83", Italic=true }

Keywords = {
  { Colour="#859900", Bold=true },      -- if, for, while
  { Colour="#268bd2" },                 -- int, char, String
  { Colour="#cb4b16" },                 -- #include, import
  { Colour="#6c71c4" },                 -- true, false, NULL
}
````

**Theme Statistics**:
- Total: 97 Themes
- Light Themes: 43
- Dark Themes: 54
- Base16 Collection: 48

**Theme Selection**:
- User Setting: `Settings.syntaxTheme` (String)
- Appearance-Based: Auto-Switch bei `Settings.appearance = .auto`
  - macOS Light Mode → Light Theme
  - macOS Dark Mode → Dark Theme

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
CLANG_CXX_LANGUAGE_STANDARD = c++17
CLANG_CXX_LIBRARY = libc++

ONLY_ACTIVE_ARCH = YES (Debug) / NO (Release)

LD_RUNPATH_SEARCH_PATHS = @loader_path/../Frameworks

SWIFT_OBJC_BRIDGING_HEADER = TextDown/TextDown-Bridging-Header.h
````

### Bridging Header Imports
````c
#import "cmark-gfm.h"
#import "cmark-gfm-core-extensions.h"
#import "syntaxhighlight.h"
#import "emoji.h"
#import "inlineimage.h"
#import "math_ext.h"
#import "extra-extensions.h"
#import "wrapper_highlight.h"
````

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

**QLExtension.appex** (wird entfernt):
````xml
<key>com.apple.security.files.all.read-only</key>
<true/>  <!-- Für lokale Bilder -->
````

### Entitlements (Post-Migration)
Editor braucht zusätzlich:
````xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>  <!-- File Open/Save Dialogs -->
````

---

## SPM Dependencies (Exakt)

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

## Bundle Struktur (Pre-Migration)
````
TextDown.app/
├── Contents/
│   ├── MacOS/
│   │   └── TextDown                 # Main Binary
│   ├── Frameworks/
│   │   ├── Sparkle.framework          # Auto-Update
│   │   └── libwrapper_highlight.dylib # Syntax Highlighting (36 MB)
│   ├── PlugIns/
│   │   ├── QLExtension.appex          # QuickLook (wird entfernt)
│   │   └── Shortcut Extension.appex   # Shortcuts (wird entfernt)
│   ├── XPCServices/
│   │   └── TextDownXPCHelper.xpc    # Settings (wird entfernt)
│   └── Resources/
│       ├── highlight/
│       │   ├── themes/*.lua           # 97 Themes
│       │   ├── langDefs/*.lang        # 261 Language Definitions
│       │   ├── plugins/*.lua          # 45 Lua Plugins
│       │   └── filetypes.conf         # Extension Mapping
│       ├── default.css                # Base CSS (14 KB)
│       ├── magic.mgc                  # libmagic Database (800 KB)
│       └── qlmarkdown_cli             # CLI Binary (wird entfernt)
````

**Size Breakdown**:
- libwrapper_highlight.dylib: 36 MB (50% des Bundles!)
- QLExtension.appex: ~8 MB
- Shortcut Extension.appex: ~8 MB
- Sparkle.framework: ~3 MB
- Resources: ~3 MB (themes + magic.mgc)
- Main Binary + Swift Code: ~2 MB

---

## Build-Time Dependencies (detailliert)

### Required Tools
````
Xcode 16.x                  # Primary IDE
Command Line Tools          # clang, make, git
Go 1.14+                    # Für Enry (libgoutils)
autoconf/automake/libtool   # Für libmagic (file-5.46)
CMake                       # Für cmark-gfm (optional, nicht aktiv verwendet)
````

### Build-Time Legacy Targets

**cmark-headers**:
- Type: PBXLegacyTarget (Makefile)
- Builds: cmark-gfm + cmark-extra Extensions
- Output: Object Files (.o) für Linking
- Time: ~2 min

**libpcre2**:
- Type: PBXLegacyTarget (autoconf)
- Source: dependencies/pcre2/ (Git Submodule)
- Output: libpcre2-32.a (Static Library, ~1 MB)
- Time: ~3 min (configure ist langsam!)

**libjpcre2**:
- Type: PBXLegacyTarget (Makefile)
- Source: dependencies/jpcre2/ (Git Submodule)
- Output: Headers Only (Header-Only Library)
- Time: ~1 min

**magic.mgc**:
- Type: PBXLegacyTarget (file binary)
- Source: highlight-wrapper/magic/
- Output: Compiled Magic Database (~800 KB)
- Time: ~10 sec

### highlight-wrapper Build Stages

**Stage 0**: Lua Interpreter
- Source: lua-5.4.7/
- Output: liblua-{arch}.a (~400 KB)
- Time: ~1-2 min

**Stage 1**: libmagic (MIME Detection)
- Source: file-5.46/
- Build: autoconf + make
- Output: libmagic-{arch}.a (~150 KB)
- Time: ~2-3 min

**Stage 2**: Enry (Language Detection)
- Source: GoUtils/goutils.go
- Build: Go Cross-Compile (CGO)
- Output: libgoutils-{arch}.a (~15 MB)
- Time: ~3-5 min

**Stage 3**: highlight (Syntax Engine)
- Source: highlight/ (Git Submodule)
- Build: C++ Compilation mit Lua + Boost
- Output: libhighlight-{arch}.a (~3 MB)
- Time: ~3-5 min

**Stage 4**: C++ Wrapper
- Source: wrapper_highlight.cpp
- Build: Linking all libs + dylib creation
- Output: libwrapper_highlight.dylib (36 MB Universal)
- Time: ~1-2 min

**Total Build Time**: 10-15 min (Clean, Universal Binary)

---

## Language Detection Details

### Enry (Accurate Mode)
**Function**: `enry_guess_language(const char *buffer)`  
**Source**: GoUtils/goutils.go (Go + CGO)  
**Algorithm**: GitHub Linguist Heuristics  
**Accuracy**: 99%+  
**Usage**: Wenn `Settings.guessMode = .accurate` UND fence tag leer

**Example**:
````markdown
````
#!/usr/bin/env python
print("Hello")
````
→ Enry detektiert: "Python" (via Shebang + Content Analysis)
````

### libmagic (Simple Mode)
**Function**: `magic_guess_language(const char *buffer, const char *magic_db)`  
**Source**: file-5.46/src/  
**Algorithm**: MIME Type Mapping  
**Accuracy**: ~70%  
**Usage**: Wenn `Settings.guessMode = .simple` UND fence tag leer

**Example**:
````markdown
````
int main() { return 0; }
````
→ libmagic detektiert: "text/x-c" → "c"
````

### Detection in Markdown Context
**WICHTIG**: Bei Markdown Editor sind Fence Tags **immer explizit**:
````markdown
```python
print("hi")
```
````
→ Language = "python" (aus Fence Tag, keine Detection nötig!)

Nur bei **unnamed code blocks** wird Detection verwendet:
````markdown
````
print("hi")
````
````
→ Detection erforderlich → Enry oder libmagic

**Conclusion**: Für Editor Use Case ist Detection **OPTIONAL** (nice-to-have).

---

## Architektur-Entscheidungen

### Was wird entfernt
- QuickLook Extension (QLExtension.appex)
- Shortcuts Integration (Shortcut Extension.appex)
- CLI Tool (qlmarkdown_cli)
- XPC Services (TextDownXPCHelper, external-launcher)
- Unused Assets (examples/, assets/)

### Was bleibt erhalten
- **Rendering-Engine**: cmark-gfm + cmark-extra mit allen Extensions
- **Syntax Highlighting**: highlight-wrapper komplett (inkl. Enry/libmagic Detection)
- **Theme System**: 97 Lua-basierte Themes
- **Settings-Logik**: Settings.swift mit Settings+NoXPC.swift Fallback
- **SPM Dependencies**: Sparkle (Auto-Update), SwiftSoup, Yams

### Neue Komponenten
- **EditorViewController**: Split-View mit NSTextView + WKWebView
- **NSDocument Architecture**: File Open/Save/Auto-Save Support
- **Live Rendering**: Debounced text change detection → automatic preview update

---

## Code-Konventionen

### Swift Style
- **Indentation**: 4 Spaces
- **Line Length**: 120 Characters
- **Access Control**: Explicit (private, fileprivate, internal, public)
- **Sections**: `// MARK: - SectionName`

### Naming
- **Classes**: `PascalCase` (EditorViewController)
- **Functions**: `camelCase` (updatePreview)
- **Properties**: `camelCase` (markdownText)
- **Constants**: `camelCase` (defaultTheme)

### Error Handling
````swift
// Prefer throwing functions
func render() throws -> String

// Always log errors
catch {
    os_log(.error, log: sLog, "Operation failed: %{public}@", 
           error.localizedDescription)
}
````

---

## Git Workflow

### Branch Strategy
````
main                          # Production code
  └─ feature/standalone-editor  # Migration work
````

### Commit Message Format
````
feat: Add new functionality
fix: Bug fix
refactor: Code restructuring
test: Add/update tests
docs: Documentation changes
chore: Maintenance tasks
````

### Commit Frequency
- Nach jedem erfolgreich getesteten Milestone
- Vor potentiell breaking changes als Rollback-Point
- Mit klarem Test-Status im Commit-Body

### Testing Requirements (Pre-Commit)
1. Clean Build erfolgreich (Cmd+Shift+K, dann Cmd+B)
2. App startet ohne Crash (Cmd+R)
3. Settings UI öffnet und funktioniert
4. Markdown Rendering funktioniert mit allen Extensions

---

## Debugging Reference

### Build Issues

**Symbol not found: _enry_guess_language**
- Ursache: highlight-wrapper outdated
- Location: highlight-wrapper/Makefile
- Fix: Clean build von highlight-wrapper

**Bridging Header not found**
- Location: Build Settings → Swift Compiler → Objective-C Bridging Header
- Expected: `$(SRCROOT)/TextDown/TextDown-Bridging-Header.h`

**Resources missing in Bundle**
- Location: Build Phases → Copy Bundle Resources
- Required: Resources/ folder (CSS, Themes)

**Linker Error: library not found**
- Check: Framework Search Paths in Build Settings
- Expected: `$(BUILT_PRODUCTS_DIR)`, `$(PROJECT_DIR)/highlight-wrapper/build`

### Runtime Issues

**Preview bleibt leer**
- Check: Settings+render.swift execution
- Check: HTML output nicht nil
- Check: WKWebView navigation allowed

**Settings nicht persistent**
- Check: Settings+NoXPC.swift active (nicht XPCWrapper)
- Check: UserDefaults domain korrekt
- Location: ~/Library/Preferences/org.advison.TextDown.plist

**Syntax Highlighting fehlt**
- Check: wrapper_highlight.dylib in Bundle/Frameworks
- Check: Resources/highlight/ in Bundle
- Check: cmark_syntax_highlight_init() called

**Themes nicht verfügbar**
- Check: Resources/highlight/themes/ kopiert
- Check: Bundle.main.resourceURL/highlight accessible
- Log: wrapper_highlight.cpp Theme Loading Errors

---

## Code-Hotspots (Wichtige Files)

### Rendering Pipeline
- `TextDown/Settings+render.swift` - Haupt-Rendering-Logic (400+ Zeilen)
- `TextDown/Settings.swift` - Settings-Management (~40 Properties)
- `TextDown/Settings+NoXPC.swift` - Standalone Settings ohne XPC
- `TextDown/TextDown-Bridging-Header.h` - C/Swift Bridge (9 Imports)

### UI Layer
- `TextDown/ViewController.swift` - Existierende Settings UI (1200+ Zeilen)
- `TextDown/AppDelegate.swift` - App Lifecycle, Sparkle Integration
- `TextDown/Theme.swift` - Theme Datenstrukturen
- `TextDown/ThemePreview.swift` - Theme Preview UI

### Build System
- `TextDown.xcodeproj/project.pbxproj` - Xcode Projekt-Konfiguration
- `highlight-wrapper/Makefile` - Multi-Stage C/C++/Go Build (383 Zeilen)
- `cmark-extra/Makefile` - Custom Markdown Extensions Build

### Extensions (C/C++ Layer)
- `cmark-extra/extensions/syntaxhighlight.c` - Syntax Highlighting Integration (500+ Zeilen)
- `cmark-extra/extensions/emoji.c` - Emoji Support (300+ Zeilen)
- `cmark-extra/extensions/inlineimage.c` - Inline Image Embedding (250+ Zeilen)
- `cmark-extra/extensions/math_ext.c` - LaTeX Math Support (200+ Zeilen)
- `cmark-extra/extensions/heads.c` - Headline Anchor Generation (300+ Zeilen)
- `highlight-wrapper/wrapper_highlight.cpp` - C++ Bridge (1109 Zeilen)
- `highlight-wrapper/wrapper_highlight.h` - Public C API (286 Zeilen)

---

## Success Metrics

### Targets
- **Before**: 10 Targets (6 Native + 4 Legacy)
- **After**: 4 Targets (1 Native + 3 Legacy)

### Bundle Size
- **Before**: ~50 MB (mit allen Extensions)
- **After**: ~34 MB (nur Editor)
- **Breakdown After**:
  - libwrapper_highlight.dylib: 36 MB
  - Sparkle.framework: 3 MB
  - Resources: 2 MB
  - Swift Code: 1 MB

### Code Complexity
- **Before**: ~8,000 LOC Swift
- **After**: ~5,000 LOC Swift

### Build Time
- **Clean Build**: ~15 min (unchanged - C/C++ Dependencies bleiben)
- **Incremental Build**: ~30s

---

## Migration Status

**Phase 1: Cleanup** (Estimated: 6h)
- [ ] Delete QL Extension Target
- [ ] Delete Shortcuts Extension Target
- [ ] Delete CLI Tool Target
- [ ] Delete external-launcher XPC
- [ ] Delete TextDownXPCHelper XPC
- [ ] Update Settings.swift (Remove XPC, use NoXPC)
- [ ] Update Info.plist (Remove Extension declarations)

**Phase 2: Editor Implementation** (Estimated: 10h)
- [ ] Create EditorViewController with Split-View
- [ ] Implement NSDocument Architecture
- [ ] Add Live Preview (debounced rendering)
- [ ] Integrate File Menu (Open/Save/Export)
- [ ] Polish UI (Toolbar, Status Bar)

**Phase 3: Testing & Documentation** (Estimated: 4h)
- [ ] Comprehensive Testing (all extensions)
- [ ] Bug Fixes
- [ ] Update README.md
- [ ] Update CHANGELOG.md

**Current Status**: Not started  
**Last Updated**: 2025-10-30

---
