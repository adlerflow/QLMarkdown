# SwiftUI State Management Architecture Proposal
**Date**: 2025-11-02
**Author**: Claude Code
**Status**: Design Phase

---

## Deployment Target Decision

### Current State
- **Project Setting**: MACOSX_DEPLOYMENT_TARGET = 26.0 (incorrect, should be 11.0)
- **CLAUDE.md Documentation**: macOS 10.15+ (x86_64), macOS 11.0+ (arm64)
- **Actual Minimum**: macOS 11.0 (Big Sur) for universal binary

### @Observable Framework Requirements
- **Swift Version**: 5.9+
- **macOS Version**: 14.0+ (Sonoma)
- **Released**: September 2023 (18+ months ago)
- **Market Share**: ~80%+ of Mac users on macOS 14+ as of Nov 2024

### Recommendation: Bump to macOS 14.0 ✅

**Rationale**:
1. **Cleaner Architecture**: @Observable eliminates 40+ @Published properties
2. **Automatic Observation**: No manual sink() setup (80 LOC saved)
3. **Better Performance**: Fine-grained tracking vs coarse-grained didSet
4. **Industry Standard**: Most Mac apps target macOS 14+ now
5. **TextDown is Editor**: Professional tool, users likely on recent OS

**Trade-off**:
- ❌ Drops support for macOS 11-13 (~20% of users)
- ✅ Gains modern Swift features, cleaner codebase

**Alternative**: Keep macOS 11+ with Combine (see Option B below)

---

## Proposed Architecture: Option A (Recommended)

### Overview: @Observable + Manual Codable

```swift
import Observation
import Foundation

@MainActor  // Thread safety: All property access on main thread
@Observable
class Settings {
    // MARK: - GitHub Flavored Markdown Extensions (6 properties)

    var tableExtension: Bool = true
    var autoLinkExtension: Bool = true
    var tagFilterExtension: Bool = true
    var taskListExtension: Bool = true
    var yamlExtension: Bool = true
    var yamlExtensionAll: Bool = false

    // MARK: - Custom Markdown Extensions (11 properties)

    var emojiExtension: Bool = true
    var emojiImageOption: Bool = false
    var headsExtension: Bool = true
    var highlightExtension: Bool = false
    var inlineImageExtension: Bool = true
    var mathExtension: Bool = true
    var mentionExtension: Bool = false
    var subExtension: Bool = false
    var supExtension: Bool = false
    var strikethroughExtension: Bool = true
    var strikethroughDoubleTildeOption: Bool = false
    var checkboxExtension: Bool = false

    // MARK: - Syntax Highlighting (7 properties)

    var syntaxHighlightExtension: Bool = true
    var syntaxWordWrapOption: Int = 0
    var syntaxLineNumbersOption: Bool = false
    var syntaxTabsOption: Int = 4
    var syntaxThemeLightOption: String = "github"
    var syntaxThemeDarkOption: String = "github-dark"

    // MARK: - Parser Options (6 properties)

    var footnotesOption: Bool = true
    var hardBreakOption: Bool = false
    var noSoftBreakOption: Bool = false
    var unsafeHTMLOption: Bool = false
    var smartQuotesOption: Bool = true
    var validateUTFOption: Bool = false

    // MARK: - CSS Theming (4 properties)

    var customCSS: URL? = nil
    var customCSSCode: String? = nil
    var customCSSFetched: Bool = false
    var customCSSOverride: Bool = false

    // MARK: - Application Behavior (6 properties)

    var openInlineLink: Bool = false
    var renderAsCode: Bool = false
    var useLegacyPreview: Bool = false  // Dead code, to be removed
    var qlWindowWidth: Int? = nil
    var qlWindowHeight: Int? = nil
    var about: Bool = false
    var debug: Bool = false

    // MARK: - Computed Properties (unchanged)

    var app_version: String {
        // ... existing implementation (lines 173-188)
    }

    var app_version2: String {
        // ... existing implementation (lines 190-204)
    }

    lazy fileprivate(set) var resourceBundle: Bundle = {
        return Self.getResourceBundle()
    }()

    var qlWindowSize: CGSize {
        if let w = qlWindowWidth, w > 0, let h = qlWindowHeight, h > 0 {
            return CGSize(width: CGFloat(w), height: CGFloat(h))
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    // MARK: - Singleton

    static let shared: Settings = {
        return Settings.settingsFromSharedFile() ?? Settings()
    }()

    static let factorySettings = Settings(noInitFromDefault: true)

    private init(noInitFromDefault: Bool = false) {
        if !noInitFromDefault {
            self.initFromDefaults()
        }
    }

    // MARK: - UserDefaults Migration (temporary)

    private func initFromDefaults() {
        // Migrate from old UserDefaults keys if needed
        // To be removed after migration complete
    }
}

// MARK: - Codable Conformance (Manual - REQUIRED)

extension Settings: Codable {
    enum CodingKeys: String, CodingKey {
        // All 40 keys (unchanged from current)
        case autoLinkExtension, checkboxExtension, emojiExtension
        case emojiImageOption, headsExtension, highlightExtension
        case inlineImageExtension, mathExtension, mentionExtension
        case subExtension, supExtension, strikethroughExtension
        case strikethroughDoubleTildeOption, syntaxHighlightExtension
        case syntaxWordWrapOption, syntaxLineNumbersOption
        case syntaxTabsOption, syntaxThemeLightOption, syntaxThemeDarkOption
        case tableExtension, tagFilterExtension, taskListExtension
        case yamlExtension, yamlExtensionAll
        case footnotesOption, hardBreakOption, noSoftBreakOption
        case unsafeHTMLOption, smartQuotesOption, validateUTFOption
        case customCSS, customCSSCode, customCSSCodeFetched
        case customCSSOverride, openInlineLink, renderAsCode
        case useLegacyPreview, qlWindowWidth, qlWindowHeight
        case about, debug
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // GFM Extensions
        self.autoLinkExtension = try container.decode(Bool.self, forKey: .autoLinkExtension)
        self.checkboxExtension = try container.decode(Bool.self, forKey: .checkboxExtension)
        self.tableExtension = try container.decode(Bool.self, forKey: .tableExtension)
        self.tagFilterExtension = try container.decode(Bool.self, forKey: .tagFilterExtension)
        self.taskListExtension = try container.decode(Bool.self, forKey: .taskListExtension)
        self.yamlExtension = try container.decode(Bool.self, forKey: .yamlExtension)
        self.yamlExtensionAll = try container.decode(Bool.self, forKey: .yamlExtensionAll)

        // Custom Extensions
        self.emojiExtension = try container.decode(Bool.self, forKey: .emojiExtension)
        self.emojiImageOption = try container.decode(Bool.self, forKey: .emojiImageOption)
        self.headsExtension = try container.decode(Bool.self, forKey: .headsExtension)
        self.highlightExtension = try container.decode(Bool.self, forKey: .highlightExtension)
        self.inlineImageExtension = try container.decode(Bool.self, forKey: .inlineImageExtension)
        self.mathExtension = try container.decode(Bool.self, forKey: .mathExtension)
        self.mentionExtension = try container.decode(Bool.self, forKey: .mentionExtension)
        self.subExtension = try container.decode(Bool.self, forKey: .subExtension)
        self.supExtension = try container.decode(Bool.self, forKey: .supExtension)
        self.strikethroughExtension = try container.decode(Bool.self, forKey: .strikethroughExtension)
        self.strikethroughDoubleTildeOption = try container.decode(Bool.self, forKey: .strikethroughDoubleTildeOption)

        // Syntax Highlighting
        self.syntaxHighlightExtension = try container.decode(Bool.self, forKey: .syntaxHighlightExtension)
        self.syntaxWordWrapOption = try container.decode(Int.self, forKey: .syntaxWordWrapOption)
        self.syntaxLineNumbersOption = try container.decode(Bool.self, forKey: .syntaxLineNumbersOption)
        self.syntaxTabsOption = try container.decode(Int.self, forKey: .syntaxTabsOption)
        self.syntaxThemeLightOption = try container.decode(String.self, forKey: .syntaxThemeLightOption)
        self.syntaxThemeDarkOption = try container.decode(String.self, forKey: .syntaxThemeDarkOption)

        // Parser Options
        self.footnotesOption = try container.decode(Bool.self, forKey: .footnotesOption)
        self.hardBreakOption = try container.decode(Bool.self, forKey: .hardBreakOption)
        self.noSoftBreakOption = try container.decode(Bool.self, forKey: .noSoftBreakOption)
        self.unsafeHTMLOption = try container.decode(Bool.self, forKey: .unsafeHTMLOption)
        self.smartQuotesOption = try container.decode(Bool.self, forKey: .smartQuotesOption)
        self.validateUTFOption = try container.decode(Bool.self, forKey: .validateUTFOption)

        // CSS Theming
        self.customCSS = try container.decode(URL?.self, forKey: .customCSS)
        self.customCSSCode = try container.decode(String?.self, forKey: .customCSSCode)
        self.customCSSFetched = try container.decode(Bool.self, forKey: .customCSSCodeFetched)
        self.customCSSOverride = try container.decode(Bool.self, forKey: .customCSSOverride)

        // Application Behavior
        self.openInlineLink = try container.decode(Bool.self, forKey: .openInlineLink)
        self.renderAsCode = try container.decode(Bool.self, forKey: .renderAsCode)
        self.useLegacyPreview = try container.decode(Bool.self, forKey: .useLegacyPreview)
        self.qlWindowWidth = try container.decode(Int?.self, forKey: .qlWindowWidth)
        self.qlWindowHeight = try container.decode(Int?.self, forKey: .qlWindowHeight)
        self.about = try container.decode(Bool.self, forKey: .about)
        self.debug = try container.decode(Bool.self, forKey: .debug)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // GFM Extensions
        try container.encode(self.autoLinkExtension, forKey: .autoLinkExtension)
        try container.encode(self.checkboxExtension, forKey: .checkboxExtension)
        try container.encode(self.tableExtension, forKey: .tableExtension)
        try container.encode(self.tagFilterExtension, forKey: .tagFilterExtension)
        try container.encode(self.taskListExtension, forKey: .taskListExtension)
        try container.encode(self.yamlExtension, forKey: .yamlExtension)
        try container.encode(self.yamlExtensionAll, forKey: .yamlExtensionAll)

        // Custom Extensions
        try container.encode(self.emojiExtension, forKey: .emojiExtension)
        try container.encode(self.emojiImageOption, forKey: .emojiImageOption)
        try container.encode(self.headsExtension, forKey: .headsExtension)
        try container.encode(self.highlightExtension, forKey: .highlightExtension)
        try container.encode(self.inlineImageExtension, forKey: .inlineImageExtension)
        try container.encode(self.mathExtension, forKey: .mathExtension)
        try container.encode(self.mentionExtension, forKey: .mentionExtension)
        try container.encode(self.subExtension, forKey: .subExtension)
        try container.encode(self.supExtension, forKey: .supExtension)
        try container.encode(self.strikethroughExtension, forKey: .strikethroughExtension)
        try container.encode(self.strikethroughDoubleTildeOption, forKey: .strikethroughDoubleTildeOption)

        // Syntax Highlighting
        try container.encode(self.syntaxHighlightExtension, forKey: .syntaxHighlightExtension)
        try container.encode(self.syntaxWordWrapOption, forKey: .syntaxWordWrapOption)
        try container.encode(self.syntaxLineNumbersOption, forKey: .syntaxLineNumbersOption)
        try container.encode(self.syntaxTabsOption, forKey: .syntaxTabsOption)
        try container.encode(self.syntaxThemeLightOption, forKey: .syntaxThemeLightOption)
        try container.encode(self.syntaxThemeDarkOption, forKey: .syntaxThemeDarkOption)

        // Parser Options
        try container.encode(self.footnotesOption, forKey: .footnotesOption)
        try container.encode(self.hardBreakOption, forKey: .hardBreakOption)
        try container.encode(self.noSoftBreakOption, forKey: .noSoftBreakOption)
        try container.encode(self.unsafeHTMLOption, forKey: .unsafeHTMLOption)
        try container.encode(self.smartQuotesOption, forKey: .smartQuotesOption)
        try container.encode(self.validateUTFOption, forKey: .validateUTFOption)

        // CSS Theming
        try container.encode(self.customCSS, forKey: .customCSS)
        try container.encode(self.customCSSCode, forKey: .customCSSCode)
        try container.encode(self.customCSSFetched, forKey: .customCSSCodeFetched)
        try container.encode(self.customCSSOverride, forKey: .customCSSOverride)

        // Application Behavior
        try container.encode(self.openInlineLink, forKey: .openInlineLink)
        try container.encode(self.renderAsCode, forKey: .renderAsCode)
        try container.encode(self.useLegacyPreview, forKey: .useLegacyPreview)
        try container.encode(self.qlWindowWidth, forKey: .qlWindowWidth)
        try container.encode(self.qlWindowHeight, forKey: .qlWindowHeight)
        try container.encode(self.about, forKey: .about)
        try container.encode(self.debug, forKey: .debug)
    }
}

// MARK: - JSON Persistence (unchanged)

extension Settings {
    static func settingsFromSharedFile() -> Settings? {
        // ... existing implementation from Settings+NoXPC.swift
    }

    func saveToSharedFile() {
        // ... existing implementation from Settings+NoXPC.swift
    }
}

// MARK: - Settings+render.swift (UNCHANGED - preserved for C bridge)
// All 68 property accesses work with @Observable ✅
// C function calls identical ✅
```

### SwiftUI Integration (Zero Boilerplate!)

```swift
import SwiftUI

struct TextDownSettingsView: View {
    // Direct Settings.shared access - automatic observation!
    @State private var settings = Settings.shared

    var body: some View {
        TabView {
            GeneralSettingsView()
            ExtensionsSettingsView()
            SyntaxSettingsView()
            AdvancedSettingsView()
        }
        .frame(width: 600, height: 400)
    }
}

struct ExtensionsSettingsView: View {
    @State private var settings = Settings.shared  // Automatic observation ✅

    var body: some View {
        Form {
            Section("GitHub Flavored Markdown") {
                Toggle("Tables", isOn: $settings.tableExtension)
                // Changes propagate to Settings.shared automatically
                // JSON auto-saved via didSet observation (if needed)
            }

            Section("Custom Extensions") {
                Toggle("Emoji", isOn: $settings.emojiExtension)
                if settings.emojiExtension {
                    Toggle("Render as images", isOn: $settings.emojiImageOption)
                        .padding(.leading, 20)
                }
            }
        }
    }
}

// NO SettingsViewModel needed! ✅
// NO @Published properties! ✅
// NO apply() method! ✅
// NO manual Combine sink() calls! ✅
```

### DocumentViewController Integration

```swift
// OLD (35 @objc dynamic properties, 210 LOC):
class DocumentViewController: NSViewController {
    @objc dynamic var tableExtension: Bool = ... {
        didSet { updateSettings() }  // Manual sync
    }
    // ... 34 more properties

    func updateSettings() {
        Settings.shared.tableExtension = self.tableExtension
        // ... copy all 35 properties
        Settings.shared.saveToSharedFile()
    }
}

// NEW (0 properties, direct Settings access):
@MainActor
class DocumentViewController: NSViewController {
    // Direct Settings.shared access
    private var settings: Settings { Settings.shared }

    func refreshPreview() {
        let html = try? settings.render(text: markdownText, ...)
        webView.loadHTMLString(html ?? "", baseURL: nil)
    }

    // NO @objc dynamic properties ✅
    // NO updateSettings() method ✅
    // NO manual synchronization ✅
}
```

### Thread Safety: @MainActor Isolation

```swift
@MainActor  // All Settings access on main thread
@Observable
class Settings { ... }

// render() must run on main thread now:
@MainActor
func refreshPreview() {
    let html = try? Settings.shared.render(text: markdownText, ...)
    // Safe: render() accesses Settings properties on main thread
}
```

**Trade-off**:
- ✅ Simple, safe (no race conditions)
- ❌ render() blocks main thread (~50ms for large documents)

**Alternative**: Background rendering with snapshot (see below)

---

## Alternative Architecture: Option B (Backward Compatible)

### Overview: Combine @Published (macOS 11+)

```swift
import Combine

class Settings: ObservableObject {
    // NO @MainActor (not available in macOS 11-13)
    // Use @Published instead of @Observable

    @Published var tableExtension: Bool = true
    @Published var emojiExtension: Bool = true
    // ... 38 more @Published properties

    private var cancellables = Set<AnyCancellable>()

    static let shared = Settings()

    init() {
        // Auto-save on any property change
        setupAutoSave()
    }

    private func setupAutoSave() {
        // Observe all 40 properties and auto-save
        $tableExtension.sink { [weak self] _ in
            self?.saveToSharedFile()
        }.store(in: &cancellables)
        // ... 39 more sink() calls (80 LOC)
    }
}

// Manual Codable conformance (same as Option A)
extension Settings: Codable { ... }
```

**Comparison**:
| Feature | Option A (@Observable) | Option B (Combine) |
|---------|----------------------|-------------------|
| macOS Version | 14.0+ | 11.0+ |
| Property Syntax | `var tableExtension: Bool` | `@Published var tableExtension: Bool` |
| Observation Setup | Automatic ✅ | Manual sink() calls (80 LOC) |
| SwiftUI Binding | `$settings.tableExtension` ✅ | `$settings.tableExtension` ✅ |
| Thread Safety | `@MainActor` ✅ | Manual GCD/locks |
| Performance | Fine-grained tracking ✅ | Coarse-grained didSet |
| Code Size | **~750 LOC** ✅ | ~830 LOC |

**Recommendation**: Option A (@Observable) for cleaner architecture

---

## Migration Path: Phased Approach

### Phase 1: Fix Deployment Target (1 hour)
```diff
- MACOSX_DEPLOYMENT_TARGET = 26.0
+ MACOSX_DEPLOYMENT_TARGET = 14.0
```

Update project.pbxproj (10 locations), verify build succeeds.

### Phase 2: Modernize Settings.swift (8 hours)
1. Add `import Observation`
2. Add `@MainActor` and `@Observable` macros
3. Remove all `@objc` declarations (40 properties)
4. Keep manual Codable conformance (276 lines)
5. Verify Settings+render.swift unchanged
6. Test: JSON roundtrip, C extensions, rendering

### Phase 3: Remove DocumentViewController State (6 hours)
1. Delete all 35 `@objc dynamic` properties
2. Replace with `Settings.shared` direct access
3. Update Storyboard bindings (or migrate to SwiftUI)
4. Remove `updateSettings()` method
5. Test: Settings persistence, UI updates

### Phase 4: Remove SettingsViewModel (4 hours)
1. Delete `SettingsViewModel.swift` (327 LOC)
2. Update SwiftUI views to use `@State private var settings = Settings.shared`
3. Remove Apply/Cancel pattern (optional: add undo/redo)
4. Test: Preferences window functional

### Phase 5: Documentation & Cleanup (2 hours)
1. Update CLAUDE.md
2. Update MIGRATION_LOG.md
3. Create git tag: `swiftui-migration-complete`
4. Remove dead code: `useLegacyPreview`, `renderAsCode`

**Total Effort**: 21 hours

---

## Advanced: Background Rendering with Snapshots

### Problem
- @MainActor forces render() to main thread
- Large documents (10,000+ lines) can block UI for 50-200ms
- User experience: Typing feels laggy

### Solution: Immutable Snapshots

```swift
@MainActor
@Observable
class Settings {
    // ... 40 properties

    // Create thread-safe snapshot for background rendering
    func snapshot() -> SettingsSnapshot {
        SettingsSnapshot(
            tableExtension: tableExtension,
            emojiExtension: emojiExtension,
            // ... 38 more properties
        )
    }
}

// Immutable value type - thread-safe by design
struct SettingsSnapshot: Sendable {
    let tableExtension: Bool
    let emojiExtension: Bool
    // ... 38 more properties (all let, no var)
}

// Background-safe render extension
extension SettingsSnapshot {
    func render(text: String, ...) throws -> String {
        // IDENTICAL to Settings+render.swift
        // But accesses immutable snapshot properties
        if self.tableExtension {
            if let ext = cmark_find_syntax_extension("table") { ... }
        }
    }
}

// Usage in DocumentViewController
@MainActor
class DocumentViewController: NSViewController {
    func refreshPreview() {
        let snapshot = Settings.shared.snapshot()  // Main thread: Fast copy
        let text = markdownText

        Task.detached {  // Background thread
            let html = try? snapshot.render(text: text, ...)

            await MainActor.run {  // Return to main thread
                webView.loadHTMLString(html ?? "", baseURL: nil)
            }
        }
    }
}
```

**Benefits**:
- ✅ Non-blocking UI (render on background thread)
- ✅ Thread-safe (snapshot is immutable)
- ✅ Settings can mutate while rendering (no data races)

**Trade-offs**:
- ❌ Duplicate code: Settings+render.swift → SettingsSnapshot+render.swift
- ❌ Maintenance burden: Keep both render() methods in sync
- ❌ Memory overhead: 40 properties copied per render (~200 bytes)

**Recommendation**: Only implement if performance testing shows main thread blocking > 50ms

---

## Success Criteria

### Code Metrics
- ✅ DocumentViewController state: 210 LOC → 0 LOC
- ✅ SettingsViewModel: 327 LOC → 0 LOC
- ✅ Settings.swift: 680 LOC → ~420 LOC (remove @objc, keep Codable)
- ✅ **Total Reduction**: 1,217 LOC → 420 LOC (66% reduction)

### Functionality
- ✅ All 40 settings properties accessible
- ✅ JSON persistence unchanged (backward compatible)
- ✅ C bridge unchanged (Settings+render.swift)
- ✅ SwiftUI Preferences functional
- ✅ Multi-window sync works
- ✅ Thread-safe (@MainActor or snapshots)

### Testing
- ✅ Unit tests: JSON roundtrip for all 40 properties
- ✅ Integration tests: C extensions activate correctly
- ✅ Snapshot tests: HTML output identical before/after
- ✅ Performance tests: render() no slower than baseline
- ✅ UI tests: Preferences window Apply/Cancel (if kept)

---

## Open Questions

1. **Apply/Cancel Pattern**: Keep or remove?
   - **Keep**: User can preview changes before saving
   - **Remove**: Live updates, add undo/redo support

2. **Background Rendering**: Implement snapshots now or later?
   - **Now**: If performance testing shows > 50ms blocking
   - **Later**: Start with @MainActor, optimize if needed

3. **Storyboard Migration**: Migrate DocumentViewController to SwiftUI?
   - **Short-term**: Keep Storyboard, remove @objc bindings
   - **Long-term**: Full SwiftUI migration (16+ hours)

4. **Dead Code Removal**: Remove `useLegacyPreview`, `renderAsCode` now?
   - **Yes**: Per LEGACY_CODE_AUDIT, both are unused
   - **Impact**: 2 properties removed from Settings

---

## Recommendation

**Proceed with Option A: @Observable + @MainActor**

1. Bump deployment target to macOS 14.0
2. Implement @Observable Settings with manual Codable
3. Remove DocumentViewController state layer
4. Remove SettingsViewModel
5. Add performance tests for render()
6. Implement background snapshots ONLY if needed

**Estimated Effort**: 21 hours
**Estimated Reduction**: 797 LOC (66%)

**Next Step**: Create comprehensive test suite (Phase 1) before beginning migration.
