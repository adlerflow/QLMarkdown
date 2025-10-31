# TextDown → Standalone Markdown Editor/Viewer

## Projektziel

Transformation von TextDown (QuickLook Extension) zu einem eigenständigen Markdown Editor/Viewer mit Split-View Architektur: Raw Markdown Editor (links) | Live Preview (rechts).

**Repository**: `/Users/home/GitHub/QLMarkdown`
**Branch**: `main`
**Migration-Branch**: `feature/standalone-editor`

---

## Aktuelle Projektstruktur (Post-Migration)

### TextDown.app - Standalone Editor
**Bundle ID**: `org.advison.TextDown`
**Primary Function**: Markdown Editor with Live Preview

**Kernklassen**:
- `DocumentViewController.swift` (~600 LOC) - Split-View Editor
  - Markdown Input: NSTextView (linke Seite)
  - Preview: WKWebView (rechte Seite, Live-Update)
  - Debounced Rendering (0.5s delay)
- `MarkdownDocument.swift` (180 LOC) - NSDocument Subclass
- `MarkdownWindowController.swift` (82 LOC) - Window Management
- `AppDelegate.swift` - App Lifecycle, Sparkle Updates
- `Settings.swift` (~40 Properties) - Rendering-Konfiguration
- `Settings+render.swift` - Haupt-Rendering-Engine
- `Settings+NoXPC.swift` - Standalone Persistenz (JSON in Application Support)
- `SettingsViewModel.swift` (327 LOC) - SwiftUI Preferences State Management

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

## Bundle Struktur (Post-Migration - Stand Phase 2)
````
TextDown.app/
├── Contents/
│   ├── MacOS/
│   │   └── TextDown                 # Main Binary (~10M)
│   ├── Frameworks/
│   │   ├── Sparkle.framework          # Auto-Update (~3M)
│   │   └── libwrapper_highlight.dylib # Syntax Highlighting (26M)
│   └── Resources/
│       ├── highlight/
│       │   ├── themes/*.lua           # 97 Themes
│       │   ├── langDefs/*.lang        # 261 Language Definitions
│       │   ├── plugins/*.lua          # 45 Lua Plugins
│       │   └── filetypes.conf         # Extension Mapping
│       ├── default.css                # Base CSS (14 KB)
│       └── magic.mgc                  # libmagic Database (800 KB)
````

**Size Breakdown (Phase 2 - Post-Removal)**:
- **Total Bundle**: 50M (war 77M, Reduktion: 27M / 35%)
- libwrapper_highlight.dylib: 26M (größter Anteil)
- Resources: 10M (themes, langDefs, CSS, magic.mgc)
- MacOS Binary: 10M
- Sparkle.framework: 3M

**Entfernt**:
- PlugIns/ (QLExtension.appex 8.8M)
- Extensions/ (Shortcut Extension.appex 19M)
- XPCServices/ (TextDownXPCHelper.xpc)
- Resources/qlmarkdown_cli

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

### Was wurde entfernt (✅ COMPLETED)
- ✅ QuickLook Extension (QLExtension.appex) - Phase 2
- ✅ Shortcuts Integration (Shortcut Extension.appex) - Phase 2
- ✅ external-launcher (XPC Service) - Phase 2
- ✅ TextDownXPCHelper (XPC Service) - Phase 1
- ✅ CLI Tool (qlmarkdown_cli) - noch nicht gebaut, Target entfernt

### Was bleibt erhalten
- **Rendering-Engine**: cmark-gfm + cmark-extra mit allen Extensions
- **Syntax Highlighting**: highlight-wrapper komplett (inkl. Enry/libmagic Detection)
- **Theme System**: 97 Lua-basierte Themes
- **Settings-Logik**: Settings.swift mit Settings+NoXPC.swift (JSON Persistenz)
- **SPM Dependencies**: Sparkle (Auto-Update), SwiftSoup, Yams

### Neue Komponenten (✅ IMPLEMENTED)
- ✅ **DocumentViewController**: Split-View mit NSTextView + WKWebView (Phase 3)
- ✅ **MarkdownDocument**: NSDocument subclass für File Open/Save/Auto-Save (Phase 3)
- ✅ **MarkdownWindowController**: NSWindowController für Multi-Window Management (Phase 3)
- ✅ **SwiftUI Preferences Window**: 4-Tab Settings UI mit Apply/Cancel Pattern (Phase 4)
- ✅ **SettingsViewModel**: Combine-based State Management für 40 Properties (Phase 4)
- ✅ **Live Rendering**: Debounced text change detection (0.5s) (Phase 3)

---

## SwiftUI Preferences Window (Phase 4)

### Architektur

**Implementierte SwiftUI Settings Scene** (macOS 13+):
- **Pattern**: Apply/Cancel Button (kein auto-save)
- **Keyboard Shortcut**: Cmd+, (standard Preferences shortcut)
- **Window Management**: NSHostingController Bridge zu AppKit
- **State Management**: Combine @Published properties mit change tracking

### Komponenten

**SettingsViewModel.swift** (327 LOC):
```swift
@MainActor
class SettingsViewModel: ObservableObject {
    // 40 @Published properties für reactive state
    @Published var tableExtension: Bool
    @Published var emojiExtension: Bool
    // ... 38 weitere properties

    @Published var hasUnsavedChanges = false

    private var cancellables = Set<AnyCancellable>()
    private var originalSettings: Settings

    init(from settings: Settings)
    func apply()                // Speichert zu Settings.shared + JSON file
    func cancel()               // Restore von originalSettings
    func resetToDefaults()      // Factory defaults
}
```

**SwiftUI View Hierarchy**:
```
TextDownSettingsView (Main Window)
├─ TabView (4 Tabs)
│  ├─ GeneralSettingsView (8 properties)
│  │  └─ CSS, Appearance, Links, QL Window Size
│  ├─ ExtensionsSettingsView (17 properties)
│  │  └─ GFM Extensions + Custom Extensions
│  ├─ SyntaxSettingsView (7 properties)
│  │  └─ Highlighting, Line Numbers, Language Detection
│  └─ AdvancedSettingsView (8 properties)
│     └─ Parser Options, Reset to Defaults
└─ Toolbar (Apply/Cancel Buttons)
```

**Integration mit AppKit**:
```swift
// AppDelegate.swift
@IBAction func showPreferences(_ sender: Any) {
    let settingsView = TextDownSettingsView()
    let hostingController = NSHostingController(rootView: settingsView)
    let window = NSWindow(contentViewController: hostingController)
    window.title = "TextDown Preferences"
    window.styleMask = [.titled, .closable, .resizable]
    window.makeKeyAndOrderFront(nil)
}
```

### Settings Persistence

**JSON File Storage** (Settings+NoXPC.swift):
- **Location**: `~/Library/Containers/org.advison.TextDown/Data/Library/Application Support/settings.json`
- **Format**: Pretty-printed, sorted keys
- **Encoding**: JSONEncoder mit `.atomic` write
- **Sync**: DistributedNotificationCenter für multi-window updates

**Change Tracking**:
```swift
// Combine sink() pattern für alle 40 properties
$tableExtension.sink { [weak self] _ in
    self?.hasUnsavedChanges = true
}.store(in: &cancellables)
```

### Settings Properties (40 Total)

**GitHub Flavored Markdown** (6):
- tableExtension, autoLinkExtension, tagFilterExtension
- taskListExtension, yamlExtension, yamlExtensionAll

**Custom Extensions** (11):
- emojiExtension (mit emojiImageOption)
- headsExtension, highlightExtension, inlineImageExtension
- mathExtension, mentionExtension, subExtension, supExtension
- strikethroughExtension (mit strikethroughDoubleTildeOption)
- checkboxExtension

**Syntax Highlighting** (7):
- syntaxHighlightExtension, syntaxLineNumbersOption
- syntaxTabsOption, syntaxWordWrapOption
- guessEngine (.none, .simple, .accurate)

**Parser Options** (6):
- footnotesOption, hardBreakOption, noSoftBreakOption
- unsafeHTMLOption, smartQuotesOption, validateUTFOption

**Appearance** (8):
- about, debug, renderAsCode, openInlineLink
- customCSSOverride, customCSS (URL?)
- qlWindowWidth, qlWindowHeight (optional Int)

**CSS Theme Management**:
```swift
// Settings+ext.swift
func getAvailableStyles(resetCache: Bool) -> [URL] {
    // Scans ~/Library/Application Support/TextDown/themes/
    // Returns sorted array of .css files
}
```

### UI Features

**Conditional Rendering**:
```swift
VStack(alignment: .leading, spacing: 4) {
    Toggle("Emoji", isOn: $viewModel.emojiExtension)
    if viewModel.emojiExtension {
        Toggle("Render as images", isOn: $viewModel.emojiImageOption)
            .padding(.leading, 20)
    }
}
```

**Apply Button State**:
```swift
Button("Apply") {
    viewModel.apply()
    dismiss()
}
.disabled(!viewModel.hasUnsavedChanges)
```

**Reset to Defaults**:
```swift
Button("Reset All Settings to Factory Defaults") {
    viewModel.resetToDefaults()
}
// Sets hasUnsavedChanges = true, requires Apply to persist
```

### Integration mit DocumentViewController

**Settings Synchronization**:
- DocumentViewController behält @objc dynamic properties für Bindings
- updateSettings() method kopiert zu Settings.shared
- saveAction() triggert JSON persist via Settings.saveToSharedFile()

**Code Cleanup** (Phase 4):
- Removed 448 lines of commented-out Settings UI code
- Removed alle TODO comments related to deleted outlets
- DocumentViewController: 1420 → 972 lines

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
- Check: JSON file exists in Application Support
- Location (Sandboxed): ~/Library/Containers/org.advison.TextDown/Data/Library/Application Support/settings.json
- Debug: os_log(.settings) outputs in Console.app

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
- `TextDown/DocumentViewController.swift` - Editor View Controller (972 Zeilen, cleaned up)
- `TextDown/MarkdownDocument.swift` - NSDocument Implementation (180 Zeilen)
- `TextDown/MarkdownWindowController.swift` - Window Controller (82 Zeilen)
- `TextDown/SettingsViewModel.swift` - SwiftUI State Management (327 Zeilen)
- `TextDown/Preferences/*.swift` - 4 SwiftUI Settings Views
- `TextDown/AppDelegate.swift` - App Lifecycle, Sparkle Integration, Preferences Window
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
  - libwrapper_highlight.dylib: 26M
  - Resources: 10M (themes, langDefs, CSS)
  - MacOS Binary: 10M
  - Sparkle.framework: 3M

### Code Complexity
- **Before**: ~8,000 LOC Swift
- **After**: ~5,500 LOC Swift (900 LOC added, 448 LOC removed)
- **Added**: MarkdownDocument, MarkdownWindowController, SettingsViewModel, 4 SwiftUI Views
- **Removed**: XPCHelper, 3 Extensions, CLI

### Build Time
- **Clean Build**: ~15 min (unchanged - C/C++ Dependencies bleiben)
- **Incremental Build**: ~30s

### project.pbxproj
- **Before**: 2,581 lines
- **After**: 1,577 lines ✅
- **Reduction**: 1,004 lines (39%)

---

## Migration Status

**Phase 0**: Rebranding to TextDown ✅ COMPLETED
- [x] Rename all files, bundle IDs, documentation

**Phase 0.5**: Code Modernization ✅ COMPLETED
- [x] Fix bridging header and build paths
- [x] Modernize APIs (UniformTypeIdentifiers)
- [x] Remove deprecation warnings

**Phase 0.75**: UI Cleanup ✅ COMPLETED
- [x] Remove footer bar from Main.storyboard
- [x] Comment out Settings TabView (875 lines)
- [x] Implement auto-refresh and auto-save

**Phase 1**: XPC Elimination ✅ COMPLETED
- [x] Remove TextDownXPCHelper target
- [x] Switch to Settings+NoXPC exclusively
- [x] Test Settings persistence (JSON file)
- [x] Git commit: 5f7cb01

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

**Phase 3**: NSDocument Architecture ✅ COMPLETED
- [x] Create MarkdownDocument.swift (NSDocument subclass)
- [x] Create MarkdownWindowController.swift
- [x] Rename ViewController → DocumentViewController
- [x] Implement split-view layout (NSTextView + WKWebView)
- [x] Add live preview with debounced rendering
- [x] Multi-window and tabs support
- [x] Fix AboutViewController crash
- [x] Git commits: f6831b6, ebedeaf

**Phase 4**: SwiftUI Preferences Window ✅ COMPLETED
- [x] Fix Settings JSON persistence (Settings+NoXPC.swift)
- [x] Implement CSS theme scanning (Settings+ext.swift)
- [x] Create SettingsViewModel.swift (327 LOC)
- [x] Create 4 SwiftUI Settings views
- [x] Update AppDelegate with showPreferences()
- [x] Wire up Preferences menu (Cmd+,)
- [x] Test Apply/Cancel functionality
- [x] Test persistence across app restarts
- [x] Clean up DocumentViewController (removed 448 lines)
- [x] Git commit: 0ec1bd0

**Current Status**: All phases completed (0, 0.5, 0.75, 1, 2, 3, 4) ✅
**Last Updated**: 2025-10-31
**Branch**: feature/standalone-editor
**Latest Commit**: 69394e7

---
