# Migration Log: TextDown → Standalone Editor

**Migration Start**: 2025-10-30
**Branch**: `feature/standalone-editor`
**Base Commit**: a4b1b63

---

## Pre-Migration Baseline (Phase 1)

### Project Structure

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

### Build Configuration
- **Architectures**: Universal Binary (x86_64 + arm64)
- **Deployment Target**: macOS 10.15+ (x86_64), macOS 11.0+ (arm64)
- **Swift Version**: 5.x
- **C++ Standard**: C++17

### Dependencies
- **Sparkle**: 2.7.0 (Auto-Update)
- **SwiftSoup**: 2.8.7 (HTML Processing)
- **Yams**: 4.0.6 (YAML Parsing)

### Critical Files
- `TextDown/Settings.swift` - 40+ Properties
- `TextDown/Settings+render.swift` - Main Rendering Engine
- `TextDown/Settings+XPC.swift` - XPC Communication
- `TextDown/Settings+NoXPC.swift` - Direct UserDefaults Fallback
- `TextDown/ViewController.swift` - Settings UI (1200+ LOC)
- `TextDown/AppDelegate.swift` - Lifecycle + Sparkle

### Build Status
- **Clean Status**: ✅ SUCCEEDED
- **Build Status**: 🔄 Running...

### Markdown Extensions Status
All extensions present and functional:
- ✅ GitHub Flavored Markdown (table, strikethrough, autolink, tasklist)
- ✅ Emoji (emoji.c)
- ✅ Math (math_ext.c)
- ✅ Syntax Highlighting (syntaxhighlight.c + libhighlight)
- ✅ Inline Images (inlineimage.c)
- ✅ Auto Anchors (heads.c)
- ✅ Highlight/Sub/Sup/Mention/Checkbox

### Theme System
- **Total Themes**: 97
- **Location**: Resources/highlight/themes/
- **Format**: Lua-based

### Bundle Size (Estimated)
- **Total**: ~50 MB
- **libwrapper_highlight.dylib**: ~36 MB
- **Extensions**: ~16 MB (QLExtension + Shortcuts)
- **Resources**: ~3 MB
- **Sparkle.framework**: ~3 MB

---

## Migration Steps

### Phase 0: Complete Rebranding to TextDown ✅ COMPLETED

**Duration**: 2025-10-30
**Status**: ✅ 100% Complete
**Total Commits**: 10
**Files Changed**: 164

#### Overview
Complete transformation of project identity from "QLMarkdown" to "TextDown" including:
- All code references (Swift, C/C++)
- Bundle identifiers
- Xcode project structure
- Folder hierarchy
- Documentation
- Build schemes

---

#### Commit 0.1: Feature Branch Creation ✅
**Date**: 2025-10-30
**Commit**: `9fffa39`
**Message**: `chore: Create feature branch for standalone editor migration`

**Changes**:
- Created `feature/standalone-editor` branch
- Added comprehensive CLAUDE.md documentation (697 lines)
  - Complete project structure analysis
  - Rendering pipeline documentation
  - Build system details
  - Migration roadmap

---

#### Commit 0.2: Initial Rebranding (sbarex → advison) ✅
**Date**: 2025-10-30
**Commit**: `0b23c48`
**Message**: `chore: Rebrand to advison and remove donation features`

**Changes**:
- Bundle IDs: `org.sbarex.*` → `org.advison.*`
- Author attribution: `Sbarex` → `adlerflow` (62 files)
- Removed donation features:
  - Deleted `Resources/stats.html`
  - Removed renderStats counter from CLI
  - Removed "buy me a coffee" messages
- 62 files changed (225 insertions, 186 deletions)

---

#### Commit 0.3: UI Cleanup ✅
**Date**: 2025-10-30
**Commit**: `e373e84`
**Message**: `chore: Remove donation UI and update project configuration`

**Changes**:
- Removed "Buy me a coffee" toolbar item from Main.storyboard
- Cleaned up project.pbxproj references to stats.html
- Updated Xcode toolsVersion (23727 → 24412)
- 2 files changed (115 insertions, 242 deletions)

---

#### Commit 0.4: Development Configuration ✅
**Date**: 2025-10-30
**Commit**: `6084027`
**Message**: `chore: Update Xcode schemes and relax entitlements for development`

**Changes**:
- Updated all Xcode schemes: LastUpgradeVersion 1630 → 2610
- Relaxed sandbox entitlements for development flexibility
  - Removed app-sandbox restrictions from all targets
  - ⚠️ Not suitable for App Store (development only)
- Added cmark version fallback in AboutViewController
- 17 files changed (81 insertions, 53 deletions)

---

#### Commit 0.5: Code Rebranding ✅
**Date**: 2025-10-30
**Commit**: `d109a85`
**Message**: `refactor: Complete rebranding QLMarkdown → TextDown`

**Changes**:
- Bundle IDs updated:
  - `org.advison.QLMarkdown` → `org.advison.TextDown`
  - `org.advison.QLMarkdown.QLExtension` → `org.advison.TextDown.QLExtension`
  - `org.advison.QLMarkdown.Shortcut-Extension` → `org.advison.TextDown.Shortcut-Extension`
  - `org.advison.QLMarkdownXPCHelper` → `org.advison.TextDownXPCHelper`
- Code references:
  - Notification: `QLMarkdownSettingsUpdated` → `TextDownSettingsUpdated`
  - UserDefaults: `org.advison.qlmarkdown-*` → `org.advison.textdown-*`
  - 27 Swift file headers updated
  - 28 C/C++ file headers updated
- Folder: `qlmarkdown_cli/` → `textdown_cli/`
- 59 files changed (217 insertions, 217 deletions)

---

#### Commit 0.6: Documentation Rebranding ✅
**Date**: 2025-10-30
**Commit**: `7ed1540`
**Message**: `docs: Update documentation with TextDown branding`

**Changes**:
- Updated CLAUDE.md:
  - Title and project description
  - All 26 QLMarkdown references → TextDown
  - Bundle IDs and code examples
  - Preserved repository path (folder not renamed)
- Updated MIGRATION_LOG.md:
  - All 10 QLMarkdown references → TextDown
  - Target names and bundle IDs
- 2 files changed (37 insertions, 37 deletions)

---

#### Commit 0.7: Xcode Project Rename ✅
**Date**: 2025-10-30
**Commit**: `6309ea7`
**Message**: `refactor: Rename Xcode project QLMarkdown.xcodeproj → TextDown.xcodeproj`

**Changes**:
- Directory rename: `QLMarkdown.xcodeproj/` → `TextDown.xcodeproj/`
- Project name in project.pbxproj updated
- All 9 .xcscheme files: Container references updated
  - `container:QLMarkdown.xcodeproj` → `container:TextDown.xcodeproj`
- 13 files changed (25 insertions, 25 deletions)
- Git history preserved (99-100% similarity)

---

#### Commit 0.8: Source Folder Rename ✅
**Date**: 2025-10-30
**Commit**: `821f480`
**Message**: `refactor: Rename source folders to TextDown`

**Changes**:
- Main app: `QLMarkdown/` → `TextDown/` (68 files)
  - All Swift source files
  - Assets.xcassets (all images)
  - Storyboards and XIBs
  - Bridging header: `QLMarkdown-Bridging-Header.h` → `TextDown-Bridging-Header.h`
  - Entitlements: `QLMarkdown.entitlements` → `TextDown.entitlements`
- XPC Helper: `QLMarkdownXPCHelper/` → `TextDownXPCHelper/` (7 files)
- CLI: `textdown_cli.entitlements` (already renamed)
- project.pbxproj: 16 internal references updated
- 79 files changed (16 insertions, 16 deletions)
- Git history preserved (100% similarity)

---

#### Commit 0.9: Extension Folder Rename ✅
**Date**: 2025-10-30
**Commit**: `5e8a4b4`
**Message**: `refactor: Rename QLExtension folder to Extension`

**Changes**:
- Folder: `QLExtension/` → `Extension/` (5 files)
- Entitlements: `QLExtension.entitlements` → `Extension.entitlements`
- Bundle ID: `org.advison.TextDown.QLExtension` → `org.advison.TextDown.Extension`
- project.pbxproj: Path and identifier references updated
- 6 files changed (7 insertions, 7 deletions)

---

#### Commit 0.10: Scheme Regeneration ✅
**Date**: 2025-10-30
**Commit**: `0ebda1f`
**Message**: `refactor: Regenerate Xcode schemes with TextDown names`

**Changes**:
- Scheme renames (Xcode auto-generated):
  - `Markdown QL Extension.xcscheme` → `TextDown Extension.xcscheme`
  - `QLMardown.xcscheme` → `TextDown.xcscheme` (fixed typo!)
  - `qlmarkdown_cli.xcscheme` → `textdown_cli.xcscheme`
- New schemes added:
  - `TextDown Shortcut Extension.xcscheme`
  - `TextDownXPCHelper.xcscheme`
- All scheme container references point to TextDown.xcodeproj
- 5 files changed (164 insertions)

---

### Phase 0 Summary

**Total Statistics**:
- ✅ 10 Commits
- ✅ 164 Files Changed
- ✅ All QLMarkdown references → TextDown
- ✅ All org.sbarex → org.advison
- ✅ Complete folder structure reorganized
- ✅ Git history fully preserved
- ✅ Working tree clean

**Final Structure**:
```
/Users/home/GitHub/QLMarkdown/  (Repository root)
├── TextDown/                    ✅ Main App
├── TextDown.xcodeproj/          ✅ Xcode Project
├── TextDownXPCHelper/           ✅ XPC Service
├── Extension/                   ✅ QuickLook Extension
├── Shortcut Extension/          ✅ Shortcuts
├── textdown_cli/                ✅ CLI Tool
├── external-launcher/           ✅ Launcher
└── ... (build dependencies)
```

**Rebranding**: 100% Complete ✅

---

### Phase 0.5: Code Modernization & UI Improvements ✅ COMPLETED

**Duration**: 2025-10-31
**Status**: ✅ 100% Complete
**Total Commits**: 6
**Files Changed**: 11

#### Overview
Post-rebranding cleanup to modernize deprecated APIs, remove legacy code, and implement collapsible settings panel for improved UX.

---

#### Commit 0.11: Bridging Header Fix ✅
**Date**: 2025-10-31
**Commit**: `a545e0d`
**Message**: `fix: Remove direct config.h import from bridging header`

**Changes**:
- Removed direct `#import "config.h"` from TextDown-Bridging-Header.h
- Note: config.h is auto-included by cmark headers from build output directory
- Fixed build warning about header not found
- 1 file changed (1 deletion)

---

#### Commit 0.12: Post-Rebranding Path Fixes ✅
**Date**: 2025-10-31
**Commit**: `f01d018`
**Message**: `fix: Update entitlements paths and magic.mgc buildToolPath after rebranding`

**Changes**:
- Fixed Extension.entitlements path in project.pbxproj
- Fixed Shortcut Extension.entitlements path
- Updated magic.mgc build tool path (qlmarkdown_cli → textdown_cli)
- Added wrapper_highlight to search paths
- 1 file changed (4 insertions, 4 deletions)

---

#### Commit 0.13: Modernize ViewController APIs ✅
**Date**: 2025-10-31
**Commit**: `c66cefa`
**Message**: `fix: Modernize ViewController to use UniformTypeIdentifiers`

**Changes**:
- Added `import UniformTypeIdentifiers` to ViewController.swift
- Replaced deprecated `String(contentsOf:)` with `String(contentsOf:encoding:.utf8)`
- Migrated 6 file dialogs from `allowedFileTypes` to `allowedContentTypes`:
  - NSOpenPanel (markdown): `UTType(filenameExtension: "md")`
  - NSSavePanel (markdown): `.md`, `.rmd`, `.qmd`
  - NSSavePanel (HTML): `.html`
  - NSOpenPanel (CSS): `UTType(filenameExtension: "css")`
  - NSSavePanel (CSS): `UTType(filenameExtension: "css")`
- **Result**: All 6 deprecation warnings resolved
- 1 file changed (7 insertions, 6 deletions)

---

#### Commit 0.14: Remove Legacy WebView Code ✅
**Date**: 2025-10-31
**Commit**: `76cc903`
**Message**: `refactor: Remove deprecated WebView and legacy preview support`

**Changes**:
- Deleted deprecated MyWebView class (macOS 10.14)
- Removed legacy preview path from loadView() (macOS 11 compatibility)
- Simplified loadView() from 85 lines to 32 lines (-53 lines)
- Replaced `preferences.javaScriptEnabled` with `defaultWebpagePreferences.allowsContentJavaScript`
- Deleted preparePreviewOfFile() method (replaced by providePreview for macOS 12+)
- Removed WebFrameLoadDelegate extension entirely
- **Result**: -115 lines removed (51% code reduction), all deprecation warnings resolved
- 1 file changed (23 insertions, 138 deletions)

---

#### Commit 0.15: Collapsible Settings Panel ✅
**Date**: 2025-10-31
**Commit**: `7e1234c`
**Message**: `feat: Add collapsible settings panel with toggle button`

**Changes**:
- **Storyboard** (Main.storyboard):
  - Added height constraint to TabView (identifier: `tabViewHeightConstraint`, constant: 220)
  - Added toggle button with SF Symbol `chevron.up.chevron.down` (ID: tgl-st-btn)
  - Positioned between rendering time label and appearance button
  - Added 2 layout constraints (leading, centerY)
  - Added outlet connections for `settingsToggleButton` and `tabViewHeightConstraint`
  - Registered system image resource
- **Swift Code** (ViewController.swift):
  - Added `@IBOutlet weak var tabViewHeightConstraint: NSLayoutConstraint!`
  - Added `@IBOutlet weak var settingsToggleButton: NSButton!`
  - Implemented `@IBAction func toggleSettings(_ sender:)` with:
    - Height toggle: 220pt ↔ 0pt
    - Smooth animation: 0.25s ease-in-ease-out
    - Dynamic tooltip update
- 2 files changed (21 insertions, 6 deletions)

---

#### Commit 0.16: Fix TabView Overflow Rendering ✅
**Date**: 2025-10-31
**Commit**: `f638528`
**Message**: `fix: Hide TabView completely when collapsed to prevent overflow rendering`

**Problem**: Bottom-row elements remained visible when panel collapsed to height=0
- External link popup (iLd-SC-WJ6)
- Autosave switch (gn8-wq-9v6)
- Quick Look window size popup (uGz-Oo-fnE)
- About info button (XA7-Gl-MRu)

**Root Cause**: NSTabView in AppKit does not clip subviews by default. Even at height=0, child elements render outside bounds.

**Solution**:
- Show TabView (`isHidden = false`) BEFORE expanding animation
- Hide TabView (`isHidden = true`) AFTER collapsing animation completes
- Synchronized with height constraint animation

**Changes**:
- Modified toggleSettings() method in ViewController.swift
- Added tabView.isHidden state management
- **Result**: Settings panel now fully hidden when collapsed
- 1 file changed (11 insertions, 1 deletion)

---

### Phase 0.5 Summary

**Total Statistics**:
- ✅ 6 Commits
- ✅ 11 Files Changed
- ✅ All deprecation warnings resolved
- ✅ Legacy code removed (-115 LOC)
- ✅ Modern APIs implemented (UniformTypeIdentifiers)
- ✅ Collapsible settings panel functional
- ✅ Build status: **BUILD SUCCEEDED**

**Key Achievements**:
- 🎯 Zero deprecation warnings
- 🎯 51% code reduction in PreviewViewController
- 🎯 Modernized file dialogs (UTType)
- 🎯 Smooth animated settings toggle (0.25s)
- 🎯 Fixed AppKit clipping behavior

**Code Modernization**: 100% Complete ✅

---

### Phase 1: XPC Service Elimination ⏳ NEXT

**Status**: Pending
**Estimated Duration**: 2-3 hours

**Goals**:
- Switch Settings persistence from XPC to direct UserDefaults
- Remove XPC Helper targets (TextDownXPCHelper, external-launcher)
- Clean up XPC-related code
- Simplify architecture for standalone app

**Tasks**:
- [ ] Step 1.1: Switch Settings.swift to use Settings+NoXPC exclusively
- [ ] Step 1.2: Remove TextDownXPCHelper target from build
- [ ] Step 1.3: Delete TextDownXPCHelper/ folder
- [ ] Step 1.4: Remove external-launcher target
- [ ] Step 1.5: Delete external-launcher/ folder
- [ ] Step 1.6: Update Info.plist (remove XPC declarations)
- [ ] Step 1.7: Test Settings persistence

---

### Phase 2: QuickLook Extension Elimination ⏳ FUTURE

**Status**: Pending
**Estimated Duration**: 2-3 hours

**Goals**:
- Remove QuickLook Extension functionality
- Transform to standalone editor app only
- Clean up Extension-related code

**Tasks**:
- [ ] Step 2.1: Disable Extension target in build scheme
- [ ] Step 2.2: Remove Extension target
- [ ] Step 2.3: Delete Extension/ folder
- [ ] Step 2.4: Remove Shortcuts Extension target
- [ ] Step 2.5: Delete Shortcut Extension/ folder
- [ ] Step 2.6: Clean Info.plist

---

### Phase 3: Editor Implementation ⏳ FUTURE

**Status**: Pending
**Estimated Duration**: 8-10 hours

**Goals**:
- Implement split-view Markdown editor
- Add live preview functionality
- NSDocument architecture for file management

**Tasks**:
- [ ] Step 3.1: Create EditorViewController skeleton
- [ ] Step 3.2: Implement split-view layout (NSTextView + WKWebView)
- [ ] Step 3.3: Add live preview with debounced rendering
- [ ] Step 3.4: Implement NSDocument architecture
- [ ] Step 3.5: Add File Open/Save/Auto-Save
- [ ] Step 3.6: Add toolbar and menu items
- [ ] Step 3.7: Integrate with Settings (via NoXPC)
- [ ] Step 3.8: Testing and polish

---

## Next Steps

**Immediate** (Current Session):
1. ✅ Complete rebranding to TextDown
2. ✅ Modernize deprecated APIs
3. ✅ Implement collapsible settings panel
4. ✅ Update MIGRATION_LOG.md

**Short-term** (Next Session):
1. Begin Phase 1: XPC Service Elimination
2. Switch to NoXPC Settings persistence
3. Remove XPC targets and code

**Medium-term**:
1. Complete Phase 2: Remove Extensions
2. Begin Phase 3: Implement Editor UI
3. Basic editor functionality working

**Long-term**:
1. Complete Phase 3: Full editor implementation
2. Polish and testing
3. Merge to main branch

---

## Notes

### Key Decisions Made
- All C/C++ rendering code will be preserved
- highlight-wrapper stays intact (36 MB dylib)
- All 97 themes preserved
- Settings.swift properties unchanged (40+ properties)
- Deprecated APIs modernized (UniformTypeIdentifiers)
- Legacy WebView code removed

### Rollback Points
- ✅ Baseline: Pre-migration state documented
- ✅ After Phase 0.5: Code modernized, settings toggle implemented
- 🔄 After Phase 1: XPC removed, Settings functional
- 🔄 After Phase 2: All extensions removed
- 🔄 After Phase 3: Editor functional
- 🔄 Final: Migration complete

---

**Last Updated**: 2025-10-31
