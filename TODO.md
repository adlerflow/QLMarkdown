# TODO

## Migration: TextDown Standalone Editor

### Phase 0: Rebranding ✅ COMPLETED
- [x] Complete rebranding to TextDown (all files, bundle IDs)
- [x] Rename folders and Xcode project
- [x] Update documentation (CLAUDE.md, MIGRATION_LOG.md)

### Phase 0.5: Code Modernization ✅ COMPLETED
- [x] Fix bridging header and build paths
- [x] Modernize ViewController APIs (UniformTypeIdentifiers)
- [x] Remove deprecated WebView code
- [x] Implement collapsible settings panel
- [x] Fix TabView overflow rendering
- [x] Resolve all deprecation warnings

### Phase 0.75: UI Cleanup and Split-View Preparation ✅ COMPLETED
- [x] Remove footer bar from Main.storyboard (separator, buttons, labels)
- [x] Remove Settings TabView from ViewController (875 lines commented out)
- [x] Implement auto-refresh mechanism (debounced text change detection)
- [x] Implement auto-save functionality (NSDocument-style)
- [x] Clean split-view layout (Raw Markdown | Rendered Preview)
- [x] Update .gitignore with comprehensive Xcode build patterns
- [x] Remove tracked build artifacts from repository (1,190 files)
- [x] Git commits: 0b0daee, e197268, 1dcf912, 5009714

### Phase 1: XPC Service Elimination ✅ COMPLETED
- [x] Switch Settings.swift to use Settings+NoXPC exclusively
- [x] Remove TextDownXPCHelper target from build
- [x] Delete TextDownXPCHelper/ folder (8 files)
- [x] Comment out all XPCWrapper calls
- [x] Update Info.plist (removed XPC declarations)
- [x] Test Settings persistence (UserDefaults fallback)
- [x] external-launcher kept for QuickLook Extension
- [x] Git commit: 5f7cb01

### Phase 2: Extension Elimination ✅ COMPLETED
- [x] Delete TextDown Extension target (QuickLook)
- [x] Delete TextDown Shortcut Extension target (Shortcuts)
- [x] Delete external-launcher target (XPC service)
- [x] Remove 2 embed build phases from TextDown.app
- [x] Delete Extension/ folder (5 files)
- [x] Delete Shortcut Extension/ folder (5 files)
- [x] Delete external-launcher/ folder (5 files)
- [x] Delete 3 .xcscheme files
- [x] UUID cleanup validation (no orphaned references)
- [x] Clean build verification
- [x] Bundle size reduction: 77M → 50M (35%)
- [x] Git commit: 69394e7

### Phase 3: NSDocument Architecture Migration ✅ COMPLETED
- [x] Create MarkdownDocument.swift (NSDocument subclass, 180 LOC)
- [x] Create MarkdownWindowController.swift (NSWindowController, 82 LOC)
- [x] Rename ViewController → DocumentViewController (git mv)
- [x] Implement split-view layout (NSTextView + WKWebView)
- [x] Add live preview with debounced rendering (0.5s delay)
- [x] Implement NSDocument architecture (multi-window, tabs, auto-save)
- [x] Add File Open/Save/Auto-Save (NSDocument handles this)
- [x] Replace File menu with standard NSDocument menus
- [x] Update Main.storyboard (removed initialViewController)
- [x] Integrate with Settings (via NoXPC)
- [x] Fix AboutViewController crash (added UI layout)
- [x] Remove unreachable Highlight View Controller scene
- [x] Testing: Multi-window support verified
- [x] Git commits: f6831b6, ebedeaf, 5f7cb01

### Phase 3.5: Features Testing ⏳ IN PROGRESS
- [x] Multi-window support (Cmd+N creates new windows)
- [ ] Native tab support (Window → Merge All Windows)
- [ ] Auto-save after 5 seconds of inactivity
- [ ] Dirty state tracking (red dot in close button)
- [ ] Undo/Redo support
- [ ] Document title bar features (version browser)
- [ ] Preview rendering (all extensions: emoji, math, syntax, tables, etc.)

### Phase 4: SwiftUI Preferences Window ✅ COMPLETED
- [x] Fix Settings JSON persistence in Settings+NoXPC.swift
- [x] Implement CSS theme filesystem scanning in Settings+ext.swift
- [x] Add .settings log category to Log.swift
- [x] Create SettingsViewModel.swift (327 LOC)
  - [x] 40 @Published properties for reactive state
  - [x] Combine-based change tracking with hasUnsavedChanges
  - [x] apply(), cancel(), resetToDefaults() methods
- [x] Create 4 SwiftUI view files in Preferences/ directory
  - [x] TextDownSettingsView.swift (Main settings window with TabView)
  - [x] GeneralSettingsView.swift (8 properties: CSS, appearance, links, QL size)
  - [x] ExtensionsSettingsView.swift (17 properties: GFM + custom extensions)
  - [x] SyntaxSettingsView.swift (7 properties: Highlighting configuration)
  - [x] AdvancedSettingsView.swift (8 properties: Parser options + reset)
- [x] Update AppDelegate.swift with showPreferences() method
- [x] Wire up Preferences menu item (Cmd+,) in Main.storyboard
- [x] Test Preferences window functionality (Apply/Cancel buttons)
- [x] Test settings persistence across app restarts
- [x] Clean up DocumentViewController.swift (removed 448 lines of commented code)
- [x] Git commit: 0ec1bd0

---

## SwiftUI State Management Migration

### Phase 0: Test Suite Creation ✅ COMPLETED
- [x] Create migration branch: feature/swiftui-state-migration
- [x] Record baseline metrics (Settings: 680 LOC, DocumentViewController: 964 LOC)
- [x] Create TextDownTests2/SettingsTests.swift (420 lines, 40+ tests)
  - [x] JSON Codable roundtrip tests (all 40 properties)
  - [x] Factory defaults verification
  - [x] Settings file I/O tests
- [x] Create TextDownTests2/RenderingTests.swift (570 lines, 30+ tests)
  - [x] Test all 13 C extensions (GFM + custom)
  - [x] Performance baselines (small/large documents)
  - [x] HTML output validation
- [x] Create TextDownTests2/SnapshotTests.swift (480 lines, 10+ tests)
  - [x] Create 6 HTML snapshot files for regression detection
  - [x] Test all extension combinations
- [x] Add tests to Xcode project (TextDownTests2 bundle)
- [x] Run test suite: 46/50 passing (92% baseline)
- [x] Copy snapshots to version control
- [x] Git commit: 7e4d77b, 34f7d39
- [x] Git tag: migration-phase0-complete

### Phase 1: Settings.swift Modernization ✅ COMPLETED
- [x] Create rollback tag: phase1-pre-start
- [x] Add import Observation to Settings.swift
- [x] Add @Observable macro to Settings class
- [x] Remove all 40 @objc var declarations
- [x] Fix @Observable compatibility issues:
  - [x] Convert lazy var resourceBundle → computed property
  - [x] Change resourceBundle from fileprivate → internal
  - [x] Keep @objc on handleSettingsChanged (NSNotificationCenter requirement)
- [x] Keep MACOSX_DEPLOYMENT_TARGET = 26.0 (user on macOS 26.1)
- [x] Clean build verification
- [x] Test suite: 46/50 passing (same baseline, no regressions)
- [x] Git commit: dc8fe34
- [x] Git tag: phase1-complete
- [x] Push to remote with tags

**Code Reduction**: -90 LOC (removed @objc boilerplate, cleaner declarations)

### Phase 2: DocumentViewController State Layer Removal ✅ COMPLETED
- [x] Create rollback tag: phase2-pre-start
- [x] Remove 35 duplicate @objc dynamic properties from DocumentViewController
  - [x] All extension toggles (headsExtension, tableExtension, etc.)
  - [x] All parser options (hardBreakOption, smartQuotesOption, etc.)
  - [x] All syntax settings (syntaxLineNumbers, syntaxWrapEnabled, etc.)
  - [x] Debug/UI properties (debugMode, renderAsCode, customCSSFile, etc.)
- [x] Remove manual sync methods:
  - [x] updateSettings() - 50 lines of local → Settings.shared copying
  - [x] initFromSettings() - 60 lines of Settings.shared → local copying
- [x] Update all methods to use Settings.shared directly:
  - [x] saveAction() → Settings.shared.saveToSharedFile()
  - [x] doRefresh() → Settings.shared.render()
  - [x] exportPreview() → Settings.shared.render() + getCompleteHTML()
  - [x] revertDocumentToSaved() → Settings.shared.initFromDefaults()
  - [x] resetToFactory() → Settings.shared.resetToFactory()
  - [x] viewDidLoad() → removed initFromSettings() call
  - [x] menuNeedsUpdate() → Settings.shared.customCSS
- [x] Update HighlightViewController.swift:
  - [x] Update 4 computed properties to proxy Settings.shared
  - [x] Remove initFromSettings() method
  - [x] Simplify viewDidLoad()
- [x] Clean build verification
- [x] Test suite: **47/50 passing (94%)** - IMPROVED! ✨
  - [x] Fixed: testFactoryDefaults now passes
  - [x] Same 3 baseline failures (emoji, noSoftBreak, subExtension)
- [x] Git commit: 844f646
- [x] Git tag: phase2-swiftui-complete
- [x] Push to remote with tags

**Code Reduction**:
- DocumentViewController: 964 → 617 lines (-347/-36%)
- HighlightViewController: 93 → 82 lines (-11/-12%)
- **Total: -358 LOC**

---

## Migration Summary

### Completed Work - Standalone Editor Migration
**Phase 0**: Rebranding to TextDown ✅
**Phase 0.5**: Code Modernization (API updates, deprecation fixes) ✅
**Phase 0.75**: UI Cleanup (footer removal, Settings TabView cleanup, split-view prep) ✅
**Phase 1**: XPC Service Elimination (TextDownXPCHelper removed) ✅
**Phase 2**: Extension Elimination (QuickLook + Shortcuts extensions removed) ✅
**Phase 3**: NSDocument Architecture Migration (multi-window, auto-save, tabs) ✅
**Phase 4**: SwiftUI Preferences Window (Apply button pattern, 40 settings properties) ✅

### Completed Work - SwiftUI State Management Migration
**Phase 0**: Test Suite Creation (1,470 LOC tests, 80+ tests, 6 HTML snapshots) ✅
**Phase 1**: Settings.swift Modernization (@Observable macro, -90 LOC) ✅
**Phase 2**: DocumentViewController State Layer Removal (-358 LOC, eliminated redundancy) ✅

### Key Achievements - Standalone Editor
- Multi-window support with NSDocument architecture
- Auto-save and dirty state tracking
- Live preview with debounced rendering (0.5s delay)
- Split-view layout: Raw Markdown (NSTextView) | Rendered Preview (WKWebView)
- Removed memory-intensive XPCHelper (was causing app crashes)
- Settings persistence via JSON file in Application Support (sandboxed Container path)
- SwiftUI-based Preferences window with Apply/Cancel pattern (Cmd+, keyboard shortcut)
- Reactive state management with Combine for 40 settings properties
- Storyboard cleanup (fixed AboutViewController, removed unreachable scenes)

### Key Achievements - SwiftUI State Migration
- Eliminated triple state redundancy (Settings + DocumentViewController + SettingsViewModel)
- Adopted Swift Observation framework (@Observable macro)
- Removed all 40 @objc property declarations
- Single source of truth: Settings.shared accessed directly
- No manual synchronization code (updateSettings/initFromSettings removed)
- Automatic UI updates via @Observable
- Improved test pass rate: 46/50 → 47/50 (94%)
- **Total code reduction: -448 LOC (22% reduction in state management)**

### Files Changed - Standalone Editor Migration
- **Added**:
  - MarkdownDocument.swift (180 LOC), MarkdownWindowController.swift (82 LOC)
  - SettingsViewModel.swift (327 LOC)
  - Preferences/*.swift (4 SwiftUI views: ~900 LOC total)
- **Renamed**: ViewController.swift → DocumentViewController.swift
- **Deleted**:
  - TextDownXPCHelper/ (8 files)
  - Extension/ (5 files)
  - Shortcut Extension/ (5 files)
  - external-launcher/ (5 files)
  - Settings+XPC.swift
  - 3 .xcscheme files
- **Modified**:
  - Main.storyboard (220 lines removed, Preferences menu added)
  - AppDelegate.swift (Preferences window integration)
  - Settings.swift, Settings+NoXPC.swift, Settings+ext.swift
  - Log.swift (.settings category)
  - DocumentViewController.swift (448 lines of commented code removed)
  - project.pbxproj (1004 lines removed)

### Files Changed - SwiftUI State Migration
- **Added**:
  - TextDownTests2/SettingsTests.swift (420 LOC, 40+ tests)
  - TextDownTests2/RenderingTests.swift (570 LOC, 30+ tests)
  - TextDownTests2/SnapshotTests.swift (480 LOC, 10+ tests)
  - TextDownTests2/Snapshots/*.html (6 baseline HTML files)
  - migration_baseline.txt (baseline metrics)
  - PHASE_0_COMPLETE.md (414 LOC documentation)
- **Modified**:
  - Settings.swift (+import Observation, +@Observable, -40 @objc declarations)
  - DocumentViewController.swift (964 → 617 lines, -347 LOC)
  - HighlightViewController.swift (93 → 82 lines, -11 LOC)
  - TextDown.xcodeproj/project.pbxproj (build configuration)

### Statistics - Standalone Editor Migration
- Targets Reduced: 10 → 5 (removed TextDownXPCHelper + 3 extensions + CLI)
- Native Targets: 6 → 1 (only TextDown.app remains)
- Legacy Targets: 4 (unchanged: cmark-headers, magic.mgc, libpcre2, libjpcre2)
- Swift Code Added: ~900 LOC (NSDocument implementation + SwiftUI Preferences)
- Swift Code Removed: ~448 lines from DocumentViewController (commented Settings UI)
- Storyboard: ~220 lines removed (unreachable scenes), Preferences menu added
- XPC References: All removed
- Settings Properties: 40 properties managed via SwiftUI ViewModel
- project.pbxproj: 2581 → 1577 lines (1004 lines removed)

### Statistics - SwiftUI State Migration
- Test Suite: 1,470 LOC added (80+ tests across 3 files)
- Test Pass Rate: 47/50 (94%), improved from 46/50 baseline
- Code Reduction: -448 LOC total
  - Settings.swift: -90 LOC (removed @objc boilerplate)
  - DocumentViewController: -347 LOC (removed state layer)
  - HighlightViewController: -11 LOC (simplified)
- @objc Declarations Removed: 40 (100% elimination)
- Manual Sync Methods Removed: 2 (updateSettings, initFromSettings = 110 lines)
- Duplicate Properties Removed: 35 from DocumentViewController
- Single Source of Truth: Settings.shared accessed directly via @Observable

### Bundle Impact
- Removed: XPCHelper process (was consuming excessive memory)
- Removed: QuickLook Extension (8.8M)
- Removed: Shortcuts Extension (19M)
- Removed: external-launcher XPC service
- Size Change: 77M → 50M (27M reduction, 35%)
- Performance: Improved memory usage, no XPCHelper overhead

### Testing Status
- ✅ App builds successfully without warnings (Release configuration)
- ✅ App launches without crash
- ✅ Multi-window support verified (3+ windows simultaneously)
- ✅ AboutViewController UI fixed and functional
- ✅ Settings persistence working (JSON file in Container sandbox)
- ✅ SwiftUI Preferences window functional (Apply/Cancel buttons)
- ✅ Settings changes persist across app restarts
- ✅ Markdown rendering dependencies intact (libwrapper_highlight, Sparkle)
- ✅ UUID cleanup validated (no orphaned references)
- ⏳ Feature testing in progress (tabs, auto-save, rendering)

---

**Last Updated**: 2025-10-31
**Phase 1 Completed**: 2025-10-31 (XPC Elimination)
**Phase 2 Completed**: 2025-10-31 (Extension Elimination)
**Phase 3 Completed**: 2025-10-31 (NSDocument Migration)
**Phase 4 Completed**: 2025-10-31 (SwiftUI Preferences Window)
**Git Commits**: f6831b6, 5f7cb01, 8857d1a, 0ec1bd0, 69394e7
**Branch**: feature/standalone-editor
**Tags**: phase2-pre-removal, phase2-complete
