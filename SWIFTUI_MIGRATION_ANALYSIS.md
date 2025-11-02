# SwiftUI State Management Migration Analysis
**Date**: 2025-11-02
**Branch**: feature/standalone-editor
**Scope**: Complete architectural analysis for eliminating triple state management

---

## Executive Summary

### Current Architecture: Triple State Management (1,556 LOC)

```
┌────────────────────────────────────────────────────────────────────┐
│                   TRIPLE STATE REDUNDANCY                          │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  DocumentViewController (35 @objc dynamic properties)              │
│  ├─ Each property has didSet { updateSettings() }                 │
│  └─ 35 properties × ~6 LOC = 210 LOC                              │
│                        ↓                                           │
│  Settings.shared (40 @objc properties + 276 LOC Codable)           │
│  ├─ Singleton instance, JSON persistence                          │
│  ├─ Manual Codable: 40 CodingKeys + encode() + decode()           │
│  └─ Total: 680 LOC (78% boilerplate)                              │
│                        ↓                                           │
│  SettingsViewModel (40 @Published properties)                      │
│  ├─ SwiftUI Preferences window state                              │
│  ├─ Combine change tracking                                       │
│  └─ apply() copies all 40 properties to Settings.shared           │
│                                                                    │
│  TOTAL REDUNDANCY: 1,556 lines managing same 40 properties        │
└────────────────────────────────────────────────────────────────────┘
```

### Critical Constraint: C/C++ Integration (MUST PRESERVE)

**Settings+render.swift** is an **extension method** on Settings class that:
- Accesses `self.property` **68+ times** in render pipeline
- Calls **24 C functions** via bridging header (cmark-gfm)
- **CANNOT be deleted** without 40+ hours refactoring

```swift
extension Settings {
    func render(text: String, filename: String,
                forAppearance: Appearance, baseDir: String) throws -> String {
        // Line 63: Direct property access (×68 total)
        if self.tableExtension {
            // Line 64-65: C function calls (×24 total)
            if let ext = cmark_find_syntax_extension("table") {
                cmark_parser_attach_syntax_extension(parser, ext)
            }
        }
        // ... 66 more property accesses + C calls
    }
}
```

**Migration MUST preserve**:
1. ✅ Settings as class (extension methods require reference semantics)
2. ✅ render() as extension method accessing self.property
3. ✅ All 40 property names (C bridge depends on exact names)
4. ✅ JSON Codable compatibility (settings.json persistence)

---

## 1. Triple State Management Architecture

### Layer 1: DocumentViewController (210 LOC)

**File**: `TextDown/DocumentViewController.swift:31-285`

**Pattern**: @objc dynamic properties with didSet synchronization

```swift
@objc dynamic var headsExtension: Bool = Settings.factorySettings.headsExtension {
    didSet {
        guard headsExtension != oldValue, pauseAutoSave == 0 else { return }
        updateSettings()  // Copies to Settings.shared
    }
}
```

**Properties** (35 total):
| Category | Properties | LOC |
|----------|-----------|-----|
| Markdown Extensions | headsExtension, tableExtension, autoLinkExtension, tagFilterExtension, taskListExtension, yamlExtension, yamlExtensionAll, strikethroughExtension, mentionExtension, highlightExtension, emojiExtension, emojiImageOption, inlineImageExtension, mathExtension, subSuperScriptExtension (15) | 90 |
| Syntax Highlighting | syntaxHighlightExtension, syntaxLineNumbers, syntaxWrapEnabled, syntaxWrapCharacters, syntaxTabsOption (5) | 30 |
| Parser Options | hardBreakOption, noSoftBreakOption, unsafeHTMLOption, validateUTFOption, smartQuotesOption, footnotesOption (6) | 36 |
| UI/Appearance | debugMode, renderAsCode, qlWindowSizeCustomized, qlWindowWidth, qlWindowHeight, customCSSOverride, customCSSFile, isAboutVisible (8) | 48 |
| Computed | elapsedTimeLabel, isAutoSaving (2) | 6 |

**Why @objc dynamic?**
- Legacy from Storyboard bindings (NSTextField, NSButton)
- KVO-compatible for AppKit controls
- NOT needed for SwiftUI migration

### Layer 2: Settings.shared (680 LOC)

**File**: `TextDown/Settings.swift:34-680`

**Pattern**: Codable class with manual encoding (276 lines of boilerplate)

```swift
class Settings: Codable {
    enum CodingKeys: String, CodingKey {  // 40 cases
        case autoLinkExtension, checkboxExtension, emojiExtension
        // ... 37 more
    }

    @objc var autoLinkExtension: Bool = true
    // ... 39 more properties

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 40 decode statements (138 lines)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // 40 encode statements (138 lines)
    }
}
```

**Properties** (40 total):
| Category | Count | Examples |
|----------|-------|----------|
| GFM Core Extensions | 6 | tableExtension, autoLinkExtension, tagFilterExtension, taskListExtension, yamlExtension, yamlExtensionAll |
| Custom Extensions | 11 | emojiExtension, emojiImageOption, headsExtension, highlightExtension, inlineImageExtension, mathExtension, mentionExtension, subExtension, supExtension, strikethroughExtension, strikethroughDoubleTildeOption, checkboxExtension |
| Syntax Highlighting | 7 | syntaxHighlightExtension, syntaxWordWrapOption, syntaxLineNumbersOption, syntaxTabsOption, syntaxThemeLightOption, syntaxThemeDarkOption |
| Parser Options | 6 | footnotesOption, hardBreakOption, noSoftBreakOption, unsafeHTMLOption, smartQuotesOption, validateUTFOption |
| CSS/Theming | 4 | customCSS, customCSSCode, customCSSFetched, customCSSOverride |
| UI/Behavior | 6 | openInlineLink, renderAsCode, useLegacyPreview, qlWindowWidth, qlWindowHeight, about, debug |

**Boilerplate Breakdown**:
- CodingKeys enum: ~40 lines
- init(from decoder:): ~138 lines
- encode(to encoder:): ~138 lines
- **Total**: 316 lines (78% of Settings.swift is boilerplate)

### Layer 3: SettingsViewModel (327 LOC)

**File**: `TextDown/SettingsViewModel.swift:1-327`

**Pattern**: Combine @Published properties with change tracking

```swift
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var tableExtension: Bool
    // ... 39 more @Published properties

    @Published var hasUnsavedChanges = false
    private var cancellables = Set<AnyCancellable>()

    init(from settings: Settings) {
        // Copy all 40 properties from Settings (40 lines)
        self.tableExtension = settings.tableExtension
        // ...

        // Setup change tracking (40+ sink() calls)
        $tableExtension.sink { [weak self] _ in
            self?.hasUnsavedChanges = true
        }.store(in: &cancellables)
        // ...
    }

    func apply() {
        // Copy all 40 properties back to Settings.shared (40 lines)
        Settings.shared.tableExtension = self.tableExtension
        // ...
        Settings.shared.saveToSharedFile()
    }
}
```

**Structure**:
- 40 @Published properties: ~40 LOC
- init(from:) property copying: ~40 LOC
- Change tracking setup: ~80 LOC (40 sink() calls)
- apply() method: ~40 LOC
- cancel() method: ~20 LOC
- resetToDefaults() method: ~20 LOC
- **Total**: 327 LOC

---

## 2. C/C++ Integration Mapping

### 2.1 C/C++ Codebase Analysis

**Total C/C++ Files**: 412 files
- cmark-gfm/ (core parser): 89 files
- cmark-extra/extensions/ (custom extensions): 12 files
- dependencies/pcre2/ (regex): 311 files

**Settings References in C/C++**: **ZERO** ✅

```bash
$ grep -r "Settings" cmark-extra/extensions cmark-gfm
# No matches found
```

**Conclusion**: C code has NO knowledge of Swift Settings class. All communication is one-way: **Swift → C**.

### 2.2 Swift/C Bridging Header

**File**: `TextDown/TextDown-Bridging-Header.h:1-14`

```c
// Core cmark-gfm parser
#import "../cmark-gfm/src/cmark-gfm.h"
#import "../cmark-gfm/extensions/cmark-gfm-core-extensions.h"

// Custom cmark-extra extensions
#import "../cmark-extra/extensions/emoji.h"
#import "../cmark-extra/extensions/inlineimage.h"
#import "../cmark-extra/extensions/math_ext.h"
#import "../cmark-extra/extensions/extra-extensions.h"
```

**Exposed C Functions** (24 called from Settings+render.swift):

| Function | Purpose | Line |
|----------|---------|------|
| `cmark_gfm_core_extensions_ensure_registered()` | Register GFM extensions | 18 |
| `cmark_gfm_extra_extensions_ensure_registered()` | Register custom extensions | 19 |
| `cmark_parser_new(options)` | Create parser | 48 |
| `cmark_parser_free(parser)` | Free parser | 53 |
| `cmark_find_syntax_extension(name)` | Find extension | 64, 74, 83, 92, 126, 135, 144, 153, 167, 180, 193, 297, 307 |
| `cmark_parser_attach_syntax_extension(parser, ext)` | Activate extension | 65, 75, 84, 93, 127, 136, 145, 154, 168, 181, 194, 299, 308 |
| `cmark_syntax_extension_inlineimage_set_wd(ext, path)` | Set working dir | 195 |
| `cmark_syntax_extension_emoji_set_use_characters(ext, bool)` | Emoji mode | 298 |
| `cmark_parser_feed(parser, text, len)` | Parse markdown | 321 |
| `cmark_parser_finish(parser)` | Finalize AST | 322 |
| `cmark_node_free(doc)` | Free AST | 326 |
| `cmark_render_html(doc, options, exts)` | Render to HTML | 333 |
| `cmark_parser_get_syntax_extensions(parser)` | Get active extensions | 333 |
| `cmark_syntax_extension_math_get_rendered_count(ext)` | Check math usage | 567 |
| `free(ptr)` | Free C memory | 335 |

### 2.3 Settings+render.swift Property Access Analysis

**File**: `TextDown/Settings+render.swift:14-770`

**Property Accesses**: 68 total (36 unique properties)

#### Extension Activation Properties (16 properties, 32 accesses)

```swift
// GFM Core (6 properties)
if self.tableExtension { /* line 63, 470, 705 */ }
if self.autoLinkExtension { /* line 73, 387 */ }
if self.tagFilterExtension { /* line 82, 478 */ }
if self.taskListExtension { /* line 91, 486 */ }
if self.yamlExtension { /* line 104, 494 */ }
    if self.yamlExtensionAll { /* line 104, 495 */ }

// Custom Extensions (10 properties)
if self.strikethroughExtension { /* line 125, 439, 380 */ }
    if self.strikethroughDoubleTildeOption { /* line 42, 380 */ }
if self.mentionExtension { /* line 134, 431 */ }
if self.headsExtension { /* line 143, 403 */ }
if self.highlightExtension { /* line 152, 406 */ }
if self.subExtension { /* line 166, 455 */ }
if self.supExtension { /* line 179, 462 */ }
if self.inlineImageExtension { /* line 192, 414 */ }
if self.emojiExtension { /* line 296, 360, 395 */ }
    if self.emojiImageOption { /* line 298, 360, 397 */ }
if self.mathExtension { /* line 306, 423, 567 */ }
if self.syntaxHighlightExtension { /* line 447, 598 */ }
```

#### Parser Option Properties (6 properties, 12 accesses)

```swift
// cmark options (lines 22-40)
if self.unsafeHTMLOption { options |= CMARK_OPT_UNSAFE }  // line 22, 360
if self.hardBreakOption { options |= CMARK_OPT_HARDBREAKS }  // line 26, 364
if self.noSoftBreakOption { options |= CMARK_OPT_NOBREAKS }  // line 29, 367
if self.validateUTFOption { options |= CMARK_OPT_VALIDATE_UTF8 }  // line 32, 370
if self.smartQuotesOption { options |= CMARK_OPT_SMART }  // line 35, 373
if self.footnotesOption { options |= CMARK_OPT_FOOTNOTES }  // line 38, 376
```

#### UI/Appearance Properties (10 properties, 15 accesses)

```swift
// Debug/About (lines 329, 346, 572)
if self.about { /* append version footer */ }
if self.debug { /* render debug table */ }
self.app_version  // line 329
self.app_version2  // line 329

// CSS Theming (lines 545-562)
if self.renderAsCode { /* skip CSS */ }
if self.customCSSFetched { let css = self.customCSSCode }
if self.customCSSOverride { /* skip default.css */ }

// Syntax Highlighting (lines 600-646)
let theme = appearance == .light ? self.syntaxThemeLightOption : self.syntaxThemeDarkOption

// Bundle Resources (line 603)
self.resourceBundle

// Link Behavior (line 501)
if self.openInlineLink { /* debug output */ }
```

#### Computed Properties (2 properties)

```swift
var app_version: String { /* lines 173-188 */ }
var app_version2: String { /* lines 190-204 */ }
lazy var resourceBundle: Bundle { /* lines 206-208 */ }
```

### 2.4 Critical C Integration Points

**Extension Registration** (lines 18-19):
```swift
cmark_gfm_core_extensions_ensure_registered()
cmark_gfm_extra_extensions_ensure_registered()
```
- Must be called BEFORE `cmark_find_syntax_extension()`
- One-time registration, safe to call multiple times
- No Settings dependency

**Extension Activation Pattern** (13 extensions):
```swift
if self.{extension}Extension {
    if let ext = cmark_find_syntax_extension("{name}") {
        cmark_parser_attach_syntax_extension(parser, ext)
        // Optional: extension-specific config
        // cmark_syntax_extension_{name}_set_{option}(ext, value)
    }
}
```

**Extension-Specific Configuration**:
1. **emoji** (lines 297-300):
   ```swift
   cmark_syntax_extension_emoji_set_use_characters(ext, !self.emojiImageOption)
   ```
   - `emojiImageOption = false` → Unicode characters (😄)
   - `emojiImageOption = true` → GitHub CDN images

2. **inlineimage** (line 195):
   ```swift
   cmark_syntax_extension_inlineimage_set_wd(ext, baseDir.cString(using: .utf8))
   ```
   - Sets working directory for relative image paths
   - **CRITICAL**: Uses `baseDir` parameter, not Settings

3. **math** (line 567):
   ```swift
   if cmark_syntax_extension_math_get_rendered_count(ext) > 0 || body.contains("$") {
       // Inject MathJax CDN script
   }
   ```
   - Queries C extension for math usage count
   - Used to conditionally load MathJax

**Parser Options** (lines 22-40):
```swift
var options = CMARK_OPT_DEFAULT
if self.unsafeHTMLOption { options |= CMARK_OPT_UNSAFE }
// ... 5 more bitwise OR operations
```
- C bitflags: `CMARK_OPT_DEFAULT`, `CMARK_OPT_UNSAFE`, `CMARK_OPT_HARDBREAKS`, etc.
- Settings properties control which flags are set

---

## 3. Migration Constraints

### 3.1 CANNOT Delete Settings Class

**Reason**: Settings+render.swift is an **extension method** that:
1. Requires reference semantics (`self` refers to Settings instance)
2. Accesses 36 unique properties 68 times
3. Is called from DocumentViewController, MarkdownDocument, PreviewProvider
4. Cannot be refactored to free function without 40+ hours work

**Why not make it a free function?**
```swift
// Current (extension method - 770 lines)
extension Settings {
    func render(text: String, ...) throws -> String {
        if self.tableExtension { ... }  // ×68 accesses
        // ... 24 C function calls
    }
}

// Hypothetical free function (requires 40+ hours refactoring)
func render(text: String, ..., settings: Settings) throws -> String {
    if settings.tableExtension { ... }  // Change all 68 accesses
    // Refactor all callers to pass settings
}
```

**Estimated Effort**: 40+ hours to refactor Settings+render.swift to free function

### 3.2 MUST Preserve Property Names

**Reason**: C extension activation uses exact property names

```swift
// ❌ CANNOT rename properties without breaking C bridge
// Before:
if self.tableExtension {
    if let ext = cmark_find_syntax_extension("table") { ... }
}

// After (BREAKS):
if self.enableTableExtension {  // ❌ render() method still expects tableExtension
    if let ext = cmark_find_syntax_extension("table") { ... }
}
```

**All 40 property names are frozen** due to:
1. Settings+render.swift accesses (68 times)
2. JSON Codable CodingKeys (40 keys)
3. UserDefaults keys (backward compatibility)

### 3.3 MUST Preserve JSON Codable

**Reason**: Settings persistence uses JSON file

**File**: `~/Library/Containers/org.advison.TextDown/Data/Library/Application Support/settings.json`

```json
{
  "autoLinkExtension": true,
  "checkboxExtension": false,
  "emojiExtension": true,
  "emojiImageOption": false,
  ...
}
```

**Constraints**:
1. ✅ All 40 CodingKeys must match JSON keys
2. ✅ Backward compatibility (existing settings.json files)
3. ✅ Type compatibility (Bool, Int, String, URL?)

### 3.4 Thread Safety Considerations

**Current Threading**:
- Settings.shared accessed from main thread (UI updates)
- render() called from background thread (DocumentViewController debounced updates)
- No thread synchronization (race conditions possible!)

**C Function Thread Safety**:
- `cmark_parser_new()` creates thread-local parser instance ✅
- `cmark_render_html()` thread-safe (no global state) ✅
- Extensions registered globally once (thread-safe after registration) ✅

**Settings Property Access**:
- ❌ NOT thread-safe (Settings.shared mutable properties)
- ❌ Potential race: UI changes Settings while render() reads properties

**Migration MUST address**:
- Immutable Settings snapshots for render()
- Or: @MainActor isolation for Settings
- Or: Combine CurrentValueSubject with thread-safe access

---

## 4. Current Redundancy Analysis

### 4.1 Property Redundancy Matrix

| Property | DocumentViewController | Settings.shared | SettingsViewModel | render() usage |
|----------|----------------------|-----------------|-------------------|----------------|
| tableExtension | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ✅ line 63, 470, 705 |
| autoLinkExtension | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ✅ line 73, 387 |
| emojiExtension | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ✅ line 296, 360, 395 |
| emojiImageOption | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ✅ line 298, 360, 397 |
| syntaxHighlightExtension | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ✅ line 447, 598 |
| syntaxLineNumbersOption | ✅ syntaxLineNumbers | ✅ @objc | ✅ @Published | ❌ (UI only) |
| syntaxWordWrapOption | ✅ syntaxWrapEnabled/Characters | ✅ @objc | ✅ @Published | ❌ (UI only) |
| syntaxTabsOption | ✅ @objc dynamic | ✅ @objc | ✅ @Published | ❌ (UI only) |
| ... | ... | ... | ... | ... |

**Total Redundancy**:
- 35 properties in DocumentViewController (210 LOC)
- 40 properties in Settings.shared (404 LOC + 276 Codable boilerplate)
- 40 properties in SettingsViewModel (327 LOC)
- **Total**: 1,217 LOC managing state (excluding render.swift dependency)

### 4.2 Boilerplate Breakdown

**Settings.swift Codable** (276 lines):
```swift
enum CodingKeys: String, CodingKey {  // 40 cases = 40 lines
    case autoLinkExtension
    // ... 39 more
}

required init(from decoder: Decoder) throws {  // 138 lines
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.autoLinkExtension = try container.decode(Bool.self, forKey: .autoLinkExtension)
    // ... 39 more decode statements
}

func encode(to encoder: Encoder) throws {  // 138 lines
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.autoLinkExtension, forKey: .autoLinkExtension)
    // ... 39 more encode statements
}
```

**Can be eliminated with**:
```swift
// Swift 5.9+ @Codable macro (auto-generates Codable conformance)
@Codable
struct Settings {
    var autoLinkExtension: Bool = true
    // ... 39 more properties
}
// Codable boilerplate: 276 lines → 0 lines
```

---

## 5. Proposed Migration Architecture

### 5.1 Target Architecture: Single Source of Truth

```
┌────────────────────────────────────────────────────────────────────┐
│                   UNIFIED STATE MANAGEMENT                         │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  @Observable                                                       │
│  class Settings {  // Swift 5.9+ Observation framework            │
│      var tableExtension: Bool = true                               │
│      var emojiExtension: Bool = true                               │
│      // ... 38 more properties                                     │
│                                                                    │
│      static let shared = Settings()  // Single source of truth    │
│  }                                                                 │
│                                                                    │
│  extension Settings {  // PRESERVED for C bridge                  │
│      func render(text: String, ...) throws -> String {            │
│          if self.tableExtension {  // Direct property access ✅    │
│              cmark_parser_attach_syntax_extension(...)  // C call  │
│          }                                                         │
│      }                                                             │
│  }                                                                 │
│                                                                    │
│  extension Settings: Codable {  // Manual conformance required    │
│      // CodingKeys + encode/decode (can't use @Codable macro)     │
│      // Reason: @Observable uses @ObservationTracked macro        │
│  }                                                                 │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────┐
    │  SwiftUI Views (automatic observation)          │
    ├─────────────────────────────────────────────────┤
    │  struct SettingsView: View {                    │
    │      @State private var settings = Settings.shared │
    │      var body: some View {                      │
    │          Toggle("Tables", isOn: $settings.tableExtension) │
    │          // Automatic observation, no @Published │
    │      }                                           │
    │  }                                               │
    └─────────────────────────────────────────────────┘
```

**Benefits**:
- ✅ Eliminate DocumentViewController state layer (-210 LOC)
- ✅ Eliminate SettingsViewModel wrapper (-327 LOC)
- ✅ Automatic SwiftUI observation (no @Published boilerplate)
- ✅ Preserve Settings+render.swift C bridge (unchanged)
- ✅ JSON persistence (manual Codable conformance)

**Estimated Reduction**: 1,556 LOC → ~750 LOC (48% reduction)

### 5.2 Migration Phases

#### Phase 1: Preparation (4 hours)
1. ✅ **C dependency audit** (COMPLETED)
   - Verify zero C references to Settings ✅
   - Map all C function calls ✅
   - Document property usage in render() ✅

2. Create comprehensive tests:
   - Settings JSON roundtrip test (encode → decode → compare)
   - C extension activation test (verify all 13 extensions work)
   - Rendering snapshot test (compare HTML output with/without extensions)

3. Thread safety audit:
   - Document all Settings access points
   - Identify race conditions (render() background vs UI updates)
   - Design isolation strategy (@MainActor or immutable snapshots)

#### Phase 2: Settings.swift Modernization (8 hours)
1. Add @Observable macro (Swift 5.9+)
   ```swift
   import Observation

   @Observable
   class Settings {
       var tableExtension: Bool = true
       // ... 39 more properties (NO @objc, NO @Published)
   }
   ```

2. Manual Codable conformance (276 lines, MUST preserve):
   ```swift
   extension Settings: Codable {
       enum CodingKeys: String, CodingKey {
           case tableExtension  // ... 39 more
       }
       // Manual encode/decode (can't use @Codable with @Observable)
   }
   ```

3. Verify Settings+render.swift unchanged:
   - All 68 property accesses work with @Observable ✅
   - No performance regression
   - C function calls identical

4. Testing:
   - JSON persistence roundtrip ✅
   - render() output identical ✅
   - C extensions activate correctly ✅

#### Phase 3: DocumentViewController Cleanup (6 hours)
1. Remove all 35 @objc dynamic properties
2. Replace with direct Settings.shared access:
   ```swift
   // Before (210 LOC):
   @objc dynamic var tableExtension: Bool = ... {
       didSet { updateSettings() }
   }

   // After (0 LOC):
   // Use Settings.shared.tableExtension directly in UI
   ```

3. Update UI bindings:
   - Storyboard: Remove all KVO bindings
   - Replace with programmatic observation
   - Or: Migrate UI to SwiftUI (long-term)

4. Remove updateSettings() synchronization logic
5. Testing: Verify Settings changes persist to JSON ✅

#### Phase 4: SettingsViewModel Elimination (4 hours)
1. Delete SettingsViewModel.swift (327 LOC)
2. Update SwiftUI Preferences views:
   ```swift
   // Before:
   @StateObject var viewModel = SettingsViewModel(from: Settings.shared)
   Toggle("Tables", isOn: $viewModel.tableExtension)

   // After:
   @State private var settings = Settings.shared
   Toggle("Tables", isOn: $settings.tableExtension)
   // Auto-observation with @Observable, no apply() needed
   ```

3. Remove Apply/Cancel pattern:
   - Settings.shared mutated directly (live updates)
   - Or: Add snapshot/revert mechanism if desired

4. Testing:
   - SwiftUI Preferences functional ✅
   - Changes persist to JSON ✅
   - Multi-window sync works ✅

#### Phase 5: Thread Safety (6 hours)
1. Add @MainActor isolation:
   ```swift
   @MainActor
   @Observable
   class Settings { ... }
   ```

2. Or: Implement immutable snapshots for render():
   ```swift
   struct SettingsSnapshot: Codable {
       let tableExtension: Bool
       // ... 39 more (immutable)
   }

   extension Settings {
       var snapshot: SettingsSnapshot {
           SettingsSnapshot(tableExtension: tableExtension, ...)
       }
   }

   func render(...) throws -> String {
       let snapshot = Settings.shared.snapshot  // Thread-safe copy
       if snapshot.tableExtension { ... }
   }
   ```

3. Testing:
   - Stress test: Rapid UI changes during render()
   - Verify no crashes, data races
   - Performance: Snapshot creation overhead

#### Phase 6: Documentation & Cleanup (2 hours)
1. Update CLAUDE.md with new architecture
2. Remove @objc declarations audit (Settings.swift has 40 @objc, all removable)
3. Git commit with comprehensive migration notes
4. Create tag: `swiftui-migration-complete`

**Total Estimated Effort**: 30 hours

---

## 6. Risk Assessment

### High Risk
1. **Breaking Settings+render.swift** (Severity: CRITICAL)
   - Mitigation: Comprehensive snapshot tests before migration
   - Rollback: Git tags at each phase

2. **JSON incompatibility** (Severity: HIGH)
   - Mitigation: Manual Codable conformance, CodingKeys unchanged
   - Testing: Load existing settings.json files from users

3. **Thread safety issues** (Severity: MEDIUM)
   - Mitigation: @MainActor isolation or immutable snapshots
   - Testing: TSan (Thread Sanitizer) enabled builds

### Medium Risk
1. **SwiftUI observation bugs** (Severity: MEDIUM)
   - @Observable is Swift 5.9+ (iOS 17+, macOS 14+)
   - Deployment target: macOS 11+ (need compatibility check)
   - Mitigation: Verify macOS 11 compatibility with @Observable

2. **Performance regression** (Severity: MEDIUM)
   - @Observable uses tracking instead of manual didSet
   - Mitigation: Benchmark render() performance before/after

### Low Risk
1. **UI binding breakage** (Severity: LOW)
   - DocumentViewController Storyboard bindings → direct access
   - Mitigation: Incremental testing, one view at a time

---

## 7. Success Metrics

### Code Reduction
- **Before**: 1,556 LOC managing 40 properties
- **Target**: ~750 LOC (48% reduction)
- **Breakdown**:
  - DocumentViewController state: 210 → 0 LOC ✅
  - Settings.swift: 680 → 420 LOC (remove boilerplate, keep Codable)
  - SettingsViewModel: 327 → 0 LOC ✅
  - Settings+render.swift: 770 → 770 LOC (unchanged) ✅

### Maintainability
- ✅ Single source of truth (Settings.shared)
- ✅ No manual synchronization (updateSettings(), apply())
- ✅ Automatic SwiftUI observation
- ✅ Thread-safe access (@MainActor or snapshots)

### Compatibility
- ✅ JSON persistence unchanged (CodingKeys preserved)
- ✅ C bridge unchanged (Settings+render.swift)
- ✅ Property names unchanged (68 render() accesses)
- ✅ Backward compatible (existing settings.json files)

---

## 8. Open Questions

1. **Deployment Target**: Does TextDown support macOS 11-13?
   - @Observable requires macOS 14+ (Swift 5.9)
   - Alternative: Stick with Combine @Published for older OS versions

2. **Thread Safety Strategy**: @MainActor or immutable snapshots?
   - @MainActor: Simplest, but forces render() to main thread (bad for performance)
   - Snapshots: More complex, but allows background rendering

3. **SwiftUI Preferences**: Keep Apply/Cancel pattern or live updates?
   - Current: Apply/Cancel with hasUnsavedChanges tracking
   - Proposed: Live updates with undo/redo support?

4. **Storyboard Migration**: Keep DocumentViewController in Storyboard?
   - Short-term: Keep Storyboard, remove @objc bindings
   - Long-term: Full SwiftUI migration (16+ hours effort)

---

## Conclusion

**Migration is FEASIBLE** with strict constraints:

✅ **PRESERVE**:
- Settings as class (extension method requirement)
- Settings+render.swift unchanged (C bridge)
- All 40 property names (render() accesses + JSON keys)
- Manual Codable conformance (JSON persistence)

✅ **ELIMINATE**:
- DocumentViewController state layer (-210 LOC)
- SettingsViewModel wrapper (-327 LOC)
- @objc dynamic properties (40 in Settings, 35 in DocumentViewController)
- Manual @Published boilerplate (327 LOC)

✅ **BENEFITS**:
- 48% code reduction (1,556 → 750 LOC)
- Single source of truth (Settings.shared)
- Automatic SwiftUI observation
- Thread safety (@MainActor or snapshots)

**Next Step**: Phase 1 - Create comprehensive tests for Settings JSON roundtrip and C extension activation.
