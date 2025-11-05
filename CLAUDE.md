# TextDown - Pure SwiftUI Markdown Editor

## Project Overview

**Repository**: `/Users/home/GitHub/QLMarkdown`
**Bundle ID**: `org.advison.TextDown`
**Target**: macOS 26.0+
**Architecture**: 100% Pure SwiftUI + Clean Architecture
**Status**: ✅ Production Ready

TextDown is a standalone markdown editor/viewer with split-view architecture:
- **Left**: Raw markdown editor with undo/redo, find, drag & drop
- **Right**: Live preview with native SwiftUI rendering

---

## Current Architecture (November 2025)

### Technology Stack

| Component | Implementation |
|-----------|---------------|
| **UI Framework** | 100% Pure SwiftUI (DocumentGroup, FileDocument) |
| **Rendering** | Native SwiftUI Views (MarkdownASTView → AST to Views) |
| **Markdown Parser** | swift-markdown 0.7.3 (Apple's library) |
| **Syntax Highlighting** | SwiftHighlighter (Pure Swift, 5 languages) |
| **Architecture Pattern** | Clean Architecture (Domain → Data → Presentation) |
| **Dependencies** | swift-markdown only (1 SPM package) |
| **Build Time** | ~30-45 sec clean build |
| **Bundle Size** | ~45 MB |
| **LOC** | ~2,000 lines (Pure Swift) |

### Key Achievements

- ✅ **Zero AppKit dependencies** - No `import AppKit`, `import Cocoa`, `import WebKit`
- ✅ **Zero C/C++ code** - Pure Swift codebase
- ✅ **Single target** - Reduced from 10 targets to 1
- ✅ **Fast builds** - 95% faster than original (30-45s vs 10-15min)
- ✅ **Small bundle** - 42% smaller (45MB vs 77MB)
- ✅ **Clean Architecture** - Domain-driven design with dependency injection

---

## Clean Architecture Structure

### Domain Layer (Business Logic)

```
TextDown/Domain/
├── Entities/
│   ├── AppSettings.swift          # Root aggregate
│   ├── EditorSettings.swift       # Editor behavior
│   ├── MarkdownSettings.swift     # GFM options + validation
│   ├── SyntaxTheme.swift          # Highlighting config
│   └── CSSSettings.swift          # Custom CSS
│
├── UseCases/
│   ├── ParseMarkdownUseCase.swift    # Markdown → AST
│   ├── LoadSettingsUseCase.swift     # Load + validate settings
│   ├── SaveSettingsUseCase.swift     # Persist settings
│   ├── ValidateSettingsUseCase.swift # Conflict detection
│   └── SaveDocumentUseCase.swift     # Document persistence
│
├── Repositories/ (Protocols)
│   ├── MarkdownParserRepository.swift
│   ├── SettingsRepository.swift
│   └── DocumentRepository.swift
│
└── Errors/
    ├── DocumentError.swift
    ├── ParseError.swift
    └── ValidationError.swift
```

### Data Layer (Infrastructure)

```
TextDown/Data/Repositories/
├── MarkdownParserRepositoryImpl.swift  # swift-markdown wrapper
├── SettingsRepositoryImpl.swift        # JSON persistence
└── DocumentRepositoryImpl.swift        # FileManager wrapper
```

### Presentation Layer (UI)

```
TextDown/
├── App/
│   └── TextDownApp.swift              # @main entry (Composition Root)
│
├── Editor/
│   ├── MarkdownEditorView.swift       # Main HSplitView
│   ├── MarkdownEditorViewModel.swift  # Rendering coordination
│   ├── PureSwiftUITextEditor.swift    # Text editor with undo/native find
│   └── TextEditorViewModel.swift      # Undo/redo logic
│
├── Preview/
│   ├── MarkdownASTView.swift          # Native SwiftUI renderer
│   ├── SwiftHighlighter.swift         # Syntax highlighter
│   ├── HeadingView.swift              # Heading rendering
│   ├── ParagraphView.swift            # Paragraph + inline styles
│   ├── CodeBlockView.swift            # Code block + highlighting
│   ├── ListViews.swift                # Ordered/unordered lists
│   ├── BlockQuoteView.swift           # Block quotes
│   └── Color.swift                    # Color utilities
│
├── Presentation/ViewModels/
│   └── SettingsViewModel.swift        # Settings coordination
│
├── Views/Settings/
│   ├── TextDownSettingsView.swift     # Custom tab bar
│   ├── GeneralSettingsView.swift
│   ├── ExtensionsSettingsView.swift
│   ├── SyntaxSettingsView.swift
│   └── AdvancedSettingsView.swift
│
├── Commands/
│   └── TextDownCommands.swift         # Menu bar
│
├── About/
│   └── AboutView.swift                # About dialog
│
├── Document/
│   └── MarkdownFileDocument.swift     # FileDocument protocol
│
└── Utilities/
    ├── OSLog.swift                    # Logging categories
    ├── BundleExtensions.swift
    └── FocusedValuesExtensions.swift
```

---

## Dependency Injection (Composition Root)

```swift
// TextDownApp.swift
@main
struct TextDownApp: App {
    // MARK: - Repositories (Data Layer)
    private let markdownParserRepository: MarkdownParserRepository
    private let settingsRepository: SettingsRepository
    private let documentRepository: DocumentRepository

    // MARK: - Use Cases (Domain Layer)
    private let parseMarkdownUseCase: ParseMarkdownUseCase
    private let loadSettingsUseCase: LoadSettingsUseCase
    private let saveSettingsUseCase: SaveSettingsUseCase
    private let validateSettingsUseCase: ValidateSettingsUseCase
    private let saveDocumentUseCase: SaveDocumentUseCase

    // MARK: - ViewModels (Presentation Layer)
    @StateObject private var settingsViewModel: SettingsViewModel

    init() {
        // 1. Create Repositories (Data Layer)
        let parserRepo = MarkdownParserRepositoryImpl()
        let settingsRepo = SettingsRepositoryImpl()
        let documentRepo = DocumentRepositoryImpl()

        // 2. Create Use Cases (Domain Layer - inject repositories)
        let parseUseCase = ParseMarkdownUseCase(parserRepository: parserRepo)
        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
        let validateUseCase = ValidateSettingsUseCase()
        let saveDocUseCase = SaveDocumentUseCase(documentRepository: documentRepo)

        // 3. Create ViewModels (Presentation Layer - inject use cases)
        let settingsVM = SettingsViewModel(
            loadSettingsUseCase: loadUseCase,
            saveSettingsUseCase: saveUseCase,
            validateSettingsUseCase: validateUseCase
        )

        // Store dependencies
        self.markdownParserRepository = parserRepo
        self.settingsRepository = settingsRepo
        self.documentRepository = documentRepo
        self.parseMarkdownUseCase = parseUseCase
        self.loadSettingsUseCase = loadUseCase
        self.saveSettingsUseCase = saveUseCase
        self.validateSettingsUseCase = validateUseCase
        self.saveDocumentUseCase = saveDocUseCase
        self._settingsViewModel = StateObject(wrappedValue: settingsVM)
    }
}
```

**Dependency Flow**: Presentation → Domain ← Data (dependencies point inward)

---

## Rendering Pipeline

### SwiftUI Native Rendering (No WebView!)

```
Markdown String
  ↓
swift-markdown Parser (AST)
  ↓
MarkdownASTView (SwiftUI)
  ├→ HeadingView
  ├→ ParagraphView (+ inline styles)
  ├→ CodeBlockView (+ SwiftHighlighter)
  ├→ ListViews
  ├→ BlockQuoteView
  └→ Other views
  ↓
Native SwiftUI Rendering
```

**No HTML generation, no WKWebView, no JavaScript** - Pure SwiftUI from AST to screen.

---

## Markdown Support

### Fully Supported

| Feature | Implementation |
|---------|---------------|
| **Headings** | HeadingView (.largeTitle → .body.bold) |
| **Paragraphs** | ParagraphView (bold, italic, code, links) |
| **Code Blocks** | CodeBlockView + SwiftHighlighter (5 languages) |
| **Lists** | UnorderedListView, OrderedListView |
| **Block Quotes** | BlockQuoteView (blue accent bar) |
| **Thematic Break** | Divider() |
| **Strikethrough** | .strikethroughStyle = .single (GFM) |
| **Autolinks** | .link attribute (GFM) |

### Placeholder/Limited Support

| Feature | Status |
|---------|--------|
| **Tables** | ⚠️ Placeholder (needs custom layout) |
| **Task Lists** | ⚠️ Placeholder (needs interactive checkboxes) |
| **Math** | ❌ Not supported (would need custom renderer) |

### Syntax Highlighting

- **Languages**: Swift, Python, JavaScript, HTML, CSS
- **Themes**: github-dark, github-light
- **Implementation**: Pure Swift tokenizer (SwiftHighlighter.swift)

---

## Settings & Configuration

### AppSettings Structure

```swift
struct AppSettings: Sendable, Codable, Equatable {
    var editor: EditorSettings
    var markdown: MarkdownSettings
    var syntaxTheme: SyntaxTheme
    var css: CSSSettings
}
```

### EditorSettings

```swift
struct EditorSettings {
    var openInlineLink: Bool  // Open links in external browser
    var debug: Bool           // Enable debug mode
}
```

### MarkdownSettings (GFM Options)

```swift
struct MarkdownSettings {
    // GFM Extensions
    var enableAutolink: Bool
    var enableTable: Bool
    var enableTagFilter: Bool
    var enableTaskList: Bool
    var enableYAML: Bool
    var enableYAMLAll: Bool
    var enableStrikethrough: Bool
    var enableStrikethroughDoubleTilde: Bool

    // Parser Options
    var enableFootnotes: Bool
    var enableHardBreaks: Bool
    var disableSoftBreaks: Bool
    var allowUnsafeHTML: Bool
    var enableSmartQuotes: Bool
    var validateUTF8: Bool
}
```

### Domain-Driven Validation

```swift
func validated() -> MarkdownSettings {
    var validated = self

    // Business rule: Double tilde requires strikethrough
    if enableStrikethroughDoubleTilde && !enableStrikethrough {
        validated.enableStrikethrough = true
    }

    // Business rule: YAML-all requires YAML
    if enableYAMLAll && !enableYAML {
        validated.enableYAML = true
    }

    return validated
}
```

---

## Logging

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

### Usage Examples

```swift
// Parse errors
os_log("Parse error: %{public}@", log: .rendering, type: .error, String(describing: error))

// Settings operations
os_log("Settings saved successfully", log: .settings, type: .debug)
os_log("Failed to load settings: %{public}@", log: .settings, type: .error, String(describing: error))

// Document operations
os_log("Saved document: %{public}@", log: .document, type: .info, url.lastPathComponent)
```

**No `print()` statements** - All logging uses structured OSLog.

---

## Build Configuration

### Xcode Settings

```
SWIFT_VERSION = 5.x
MACOSX_DEPLOYMENT_TARGET = 26.0
ONLY_ACTIVE_ARCH = YES (Debug) / NO (Release)
PRODUCT_BUNDLE_IDENTIFIER = org.advison.TextDown
```

### Entitlements

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>  <!-- File Open/Save via DocumentGroup -->
```

### SPM Dependencies

**swift-markdown** (0.7.3) - ONLY DEPENDENCY
- Repository: https://github.com/swiftlang/swift-markdown
- Usage: Core markdown parsing with GFM support
- Transitive: swift-cmark 0.7.1

---

## Bundle Structure

```
TextDown.app/
├── Contents/
│   ├── MacOS/
│   │   └── TextDown              # Main Binary (~10MB)
│   ├── Resources/
│   │   └── Assets.xcassets       # AppIcon + AccentColor (~100KB)
│   └── Info.plist
```

**Total Bundle Size**: ~45 MB (down from 77 MB original)

---

## File Type Support

### Supported UTTypes

```swift
.markdown           // .md, .markdown
.rMarkdown          // .rmd (R Markdown)
.qmdMarkdown        // .qmd (Quarto)
```

### Document Handling

```swift
struct MarkdownFileDocument: FileDocument {
    static var readableContentTypes: [UTType] = [
        .markdown,
        .rMarkdown,
        .qmdMarkdown
    ]

    var content: String

    // UTF-8 encoding with fallback
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(data: data, encoding: .utf8) ?? ""
        } else {
            throw DocumentError.fileNotFound(configuration.file.filename ?? "Unknown")
        }
    }
}
```

---

## Code Quality Standards

### Enforced Rules

1. ✅ **Zero AppKit** - No `import AppKit`, `import Cocoa`, `import WebKit`
2. ✅ **English only** - All comments and documentation in English
3. ✅ **Structured logging** - OSLog only, no `print()` statements
4. ✅ **Dynamic bundle IDs** - No hardcoded bundle identifiers
5. ✅ **Clean Architecture** - Domain → Data → Presentation separation
6. ✅ **No dead code** - No disabled features or placeholder buttons

### CI Enforcement

```bash
# ci/ensure_pure_swiftui.sh
Forbidden Patterns:
  - import AppKit
  - import Cocoa
  - import WebKit
  - NSViewRepresentable
  - NSDocument
  - WKWebView

Exit Code: 1 if violations found
Status: ✅ PASSED
```

---

## Testing

### Test Structure

```
TextDownTests/
├── Editor/
│   ├── MarkdownEditorViewModelTests.swift
│   ├── TextEditorViewModelTests.swift
│   └── MarkdownInlineRendererTests.swift
├── Preview/
│   └── MarkdownInlineRendererTests.swift
└── SettingsTests.swift
```

### Test Coverage

- ✅ Rendering tests (AST → Views)
- ✅ Settings persistence (JSON encoding/decoding)
- ✅ Validation logic (business rules)
- ✅ Undo/redo stack
- ✅ Find functionality

**Status**: All tests passing

---

## Development Workflow

### Clean Build

```bash
xcodebuild -scheme TextDown -configuration Debug clean build
# ~30-45 seconds
```

### Run Tests

```bash
xcodebuild test -scheme TextDown -destination 'platform=macOS'
```

### Code Style

```bash
swiftlint
# .swiftlint.yml enforces Pure SwiftUI rules
```

---

## Migration History (Completed November 2025)

### Major Transformations

1. **swift-markdown Migration** (Nov 2)
   - Replaced cmark-gfm (C) with swift-markdown (Swift)
   - Removed 9,761 LOC of C/C++ code
   - Removed bridging header
   - Build time: -75%

2. **Pure SwiftUI Migration** (Nov 3)
   - Replaced all AppKit with SwiftUI
   - Deleted NSDocument, NSViewController, WKWebView
   - Native SwiftUI rendering (no HTML generation)
   - Bundle size: -32 MB

3. **Clean Architecture Refactoring** (Nov 3)
   - Implemented Domain-Data-Presentation layers
   - Added dependency injection
   - Migrated to OSLog
   - Removed auto-refresh toggle (always enabled)

### Overall Impact

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| **Build Time** | 10-15 min | 30-45 sec | **-95%** |
| **Bundle Size** | 77 MB | 45 MB | **-42%** |
| **LOC** | 18,000 (mixed) | 2,000 (Swift) | **-89%** |
| **Targets** | 10 | 1 | **-90%** |
| **Dependencies** | 6 (4 SPM + 2 submodules) | 1 SPM | **-83%** |

---

## Key Features

### Editor
- ✅ Custom undo/redo (50 entries)
- ✅ **Native find & replace** (`.findNavigator()` modifier, system integration, find history, Cmd+F)
- ✅ Drag & drop markdown files
- ✅ Monospaced font
- ✅ Auto-save

### Preview
- ✅ Live preview (500ms debounce)
- ✅ Native SwiftUI rendering
- ✅ Syntax highlighting (5 languages)
- ✅ Clickable links
- ✅ Responsive layout

### Settings
- ✅ Custom tab bar UI
- ✅ GFM extension toggles
- ✅ Syntax theme selection
- ✅ Auto-save (1s debounce)
- ✅ Reset to defaults

---

## Known Limitations

1. **Syntax Highlighting**: Limited to 5 languages (vs highlight.js 190+)
2. **Math Rendering**: Not supported (would require custom renderer or MathJax)
3. **GFM Tables**: Placeholder only (needs custom SwiftUI layout)
4. **Task Lists**: Placeholder only (needs interactive checkboxes)
5. **Find Navigation**: No previous/next (SwiftUI TextEditor limitation)
6. **Line Numbers**: Not available (SwiftUI TextEditor limitation)

---

## Future Enhancements

### Planned
- [ ] Custom table rendering (SwiftUI grid)
- [ ] Interactive task lists (checkboxes)
- [ ] Expand syntax highlighting (10+ languages)
- [ ] Export to PDF/HTML
- [ ] Custom themes

### Maybe
- [ ] Math rendering (KaTeX or custom)
- [ ] Plugin system
- [ ] iCloud sync
- [ ] iOS/iPadOS version

---

## License & Credits

**Developed by**: ADLERFLOW (2020-2025)
**Repository**: https://github.com/adlerflow/TextDown

**Dependencies**:
- swift-markdown (Apple) - MIT License

---

*Last Updated: November 2025*
