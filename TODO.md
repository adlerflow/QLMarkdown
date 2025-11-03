# TODO

## Current Status - Pure SwiftUI Architecture ✅ COMPLETED

**Last Updated**: 2025-11-03
**Branch**: `main` (all migrations merged)
**Architecture**: 100% Pure SwiftUI (Zero AppKit)

### Overview
TextDown is now a complete Pure SwiftUI application with native markdown rendering. All AppKit components, HTML rendering, and JavaScript dependencies have been removed.

### Migration Timeline
| Phase | Date | Status |
|-------|------|--------|
| **swift-markdown** | 2025-11-02 | ✅ Replaced cmark-gfm with swift-markdown |
| **Pure SwiftUI** | 2025-11-03 | ✅ 100% SwiftUI (deleted all AppKit) |
| **Phase 5** | 2025-11-03 | ✅ BundleResources cleanup |
| **Phase 6** | 2025-11-03 | ✅ Rendering pipeline cleanup |
| **Folder Reorg** | 2025-11-03 | ✅ Tier 3 reorganization |
| **Documentation** | 2025-11-03 | ✅ CLAUDE.md & TODO.md cleanup |

### Key Achievements
- **Architecture**: 100% Pure SwiftUI (DocumentGroup, FileDocument)
- **Rendering**: Native SwiftUI views (MarkdownASTView, no WKWebView)
- **Syntax Highlighting**: Pure Swift tokenizer (SwiftHighlighter)
- **Build Time**: 10-15 min → 30-45 sec (-95%)
- **Bundle Size**: 77 MB → 10 MB (-87%)
- **LOC**: ~18,000 → ~2,000 (-89%)
- **Targets**: 10 → 1 (-90%)
- **Dependencies**: 4 SPM + 2 Git submodules → 1 SPM (swift-markdown only)

### Removed Components
- ❌ All AppKit (NSDocument, NSViewController, NSTextView, WKWebView, Main.storyboard)
- ❌ HTML rendering pipeline (MarkdownRenderer + 8 Rewriters - 1,321 LOC)
- ❌ JavaScript syntax highlighting (highlight.js)
- ❌ C/C++ markdown parser (cmark-gfm - 9,761 LOC)
- ❌ QuickLook Extension, Shortcuts Extension, XPC Services
- ❌ All Git submodules (pcre2, jpcre2)
- ❌ Bridging header (pure Swift)

---

## Pure SwiftUI Migration (100% SwiftUI Architecture)

### Phase 1: Core Architecture - Big Bang Migration ✅ COMPLETED
- [x] Create feature branch: feature/pure-swiftui-migration
- [x] **Delete ALL AppKit components**:
  - [x] Main.storyboard (1,003 lines XML)
  - [x] DocumentViewController.swift (605 LOC - NSTextView + WKWebView)
  - [x] MarkdownWindowController.swift (83 LOC)
  - [x] AboutViewController.swift (78 LOC)
  - [x] MarkdownDocument.swift (186 LOC - NSDocument)
  - [x] NSColor.swift (104 LOC - AppKit color utilities)
- [x] **Create Pure SwiftUI components**:
  - [x] App/TextDownApp.swift (31 LOC) - @main entry with DocumentGroup
  - [x] App/AppState.swift (110 LOC) - @Observable replaces AppDelegate
  - [x] Document/MarkdownFileDocument.swift (76 LOC) - FileDocument protocol
  - [x] Editor/MarkdownEditorView.swift (84 LOC) - HSplitView editor
  - [x] Editor/PureSwiftUITextEditor.swift (228 LOC) - Text editor with Undo/Find
  - [x] Preview/MarkdownASTView.swift (287 LOC) - Native SwiftUI renderer
  - [x] Preview/SwiftHighlighter.swift (278 LOC) - Pure Swift tokenizer
  - [x] Commands/TextDownCommands.swift (79 LOC) - Menu bar commands
  - [x] About/AboutView.swift (81 LOC) - Pure SwiftUI about dialog
- [x] **Replace WKWebView with native SwiftUI rendering**:
  - [x] Direct swift-markdown AST → SwiftUI view tree
  - [x] HeadingView, ParagraphView, CodeBlockView, ListViews, BlockQuoteView
  - [x] AttributedString for inline styling (bold, italic, code, links)
  - [x] No HTML generation, no WebKit dependencies
- [x] Update Info.plist (remove NSMainStoryboardFile, NSDocumentClass, Sparkle)
- [x] Git commit: 2e6dd4a

### Phase 2: Color Migration (Pure SwiftUI) ✅ COMPLETED
- [x] Delete TextDown/Utilities/NSColor.swift (104 LOC AppKit)
- [x] Create TextDown/Preview/Color.swift (130 LOC SwiftUI):
  - [x] Color(hex: "#FF5733") initializer (supports #RGB, #RRGGBB, #RRGGBBAA)
  - [x] Color.Markdown semantic palette (codeBackground, inlineCodeForeground, etc.)
  - [x] Zero AppKit/UIKit dependencies
- [x] Remove `import AppKit` from AppConfiguration+Themes.swift
- [x] Update comments to avoid CI violations (NSDocument, WKWebView mentions)
- [x] Run CI Guards: `ci/ensure_pure_swiftui.sh` ✅ PASSED
- [x] Git commit: 163a6f5

### Phase 3: Compilation Error Fixes ✅ COMPLETED
- [x] Fix UTType.markdown unavailable → UTType("net.daringfireball.markdown")
- [x] Fix @FocusState type mismatch → changed to @State
- [x] Fix Swift keyword conflicts → escaped .func and .operator with backticks
- [x] Fix DocumentGroup syntax → removed closure wrapper
- [x] Fix Settings ambiguity → SwiftUI.Settings
- [x] Fix Markdown.Text vs SwiftUI.Text conflicts → fully qualified types
- [x] Fix Markdown.Link vs SwiftUI.Link conflicts → fully qualified types
- [x] Fix Color inference issues → explicitly use Color.blue, Color.pink, etc.
- [x] Fix LineStyle.Pattern → use .single for proper inference
- [x] Fix UInt + Int operator → cast list.startIndex to Int
- [x] Git commits: 14e88fe, 2a68066, 9d1ca6f, bf618ca, 9f562ba

### Phase 4: UI Polish ✅ COMPLETED
- [x] Fix duplicate View menu (CommandMenu → CommandGroup)
- [x] Remove redundant Toggle Toolbar button
- [x] Git commit: 0133649

### Phase 5: Documentation ✅ COMPLETED
- [x] Update CLAUDE.md with Pure SwiftUI migration section
  - [x] Migration summary (Big-Bang approach, duration)
  - [x] Architecture changes (deleted/new components)
  - [x] Rendering pipeline transformation
  - [x] Achieved metrics table
  - [x] Implementation commits
  - [x] Known limitations
  - [x] CI enforcement details
  - [x] Files reference
- [x] Update branch information in CLAUDE.md
- [x] Git commit: f2c3248

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
**Phase 1**: Core/AppConfiguration.swift Modernization (@Observable macro, -90 LOC) ✅
**Phase 2**: DocumentViewController State Layer Removal (-358 LOC, eliminated redundancy) ✅
**Phase 3**: AppConfigurationViewModel Elimination (-327 LOC, 100% ViewModel layer removed) ✅
**Phase 4**: Documentation and Code Quality (CLAUDE.md reduction, os_log() migration) ✅

### Completed Work - Pure SwiftUI Migration
**Phase 1**: Core Architecture - Big Bang Migration (delete AppKit, create SwiftUI) ✅
**Phase 2**: Color Migration (NSColor → Color, zero AppKit) ✅
**Phase 3**: Compilation Error Fixes (type ambiguities, syntax corrections) ✅
**Phase 4**: UI Polish (duplicate menu fix) ✅
**Phase 5**: Documentation (CLAUDE.md comprehensive update) ✅
