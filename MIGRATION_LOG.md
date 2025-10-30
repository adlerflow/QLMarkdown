# Migration Log: QLMarkdown → Standalone Editor

**Migration Start**: 2025-10-30
**Branch**: `feature/standalone-editor`
**Base Commit**: a4b1b63

---

## Pre-Migration Baseline (Phase 1)

### Project Structure

**Xcode Targets (10 Total)**:

**Native Targets (6)**:
1. QLMarkdown - Main Application (Bundle ID: org.sbarex.QLMarkdown)
2. Markdown QL Extension - QuickLook Extension (.appex)
3. QLMarkdown Shortcut Extension - Shortcuts Integration (.appex)
4. qlmarkdown_cli - Command Line Interface Binary
5. QLMarkdownXPCHelper - Settings Persistence XPC Service (.xpc)
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
- `QLMarkdown/Settings.swift` - 40+ Properties
- `QLMarkdown/Settings+render.swift` - Main Rendering Engine
- `QLMarkdown/Settings+XPC.swift` - XPC Communication
- `QLMarkdown/Settings+NoXPC.swift` - Direct UserDefaults Fallback
- `QLMarkdown/ViewController.swift` - Settings UI (1200+ LOC)
- `QLMarkdown/AppDelegate.swift` - Lifecycle + Sparkle

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

### Phase 1: Vorbereitung & Branch Setup ✅

#### Step 1.1: Feature Branch erstellen ✅
**Date**: 2025-10-30
**Commit**: 9fffa39 - `chore: Create feature branch for standalone editor migration`
**Status**: ✅ SUCCESS

**Changes**:
- Created branch `feature/standalone-editor`
- Pushed to remote: origin/feature/standalone-editor
- Added CLAUDE.md with complete project documentation

**Tests**:
- ✅ Branch exists on remote
- ✅ CLAUDE.md committed

---

#### Step 1.2: Baseline dokumentieren 🔄
**Date**: 2025-10-30
**Status**: 🔄 IN PROGRESS

**Actions**:
- ✅ Documented all Xcode targets
- ✅ Listed SPM dependencies
- ✅ Clean build successful
- 🔄 Full build verification running

---

## Next Steps

### Phase 2: XPC Service Elimination
- [ ] Step 2.1: Settings auf NoXPC umstellen
- [ ] Step 2.2: XPC Helper Target aus Build entfernen
- [ ] Step 2.3: XPC Source Files löschen
- [ ] Step 2.4: external-launcher XPC entfernen

### Phase 3: QuickLook Extension Elimination
- [ ] Step 3.1: QLExtension Target deaktivieren
- [ ] Step 3.2: QLExtension Target löschen
- [ ] Step 3.3: QLExtension Source Files löschen
- [ ] Step 3.4: Info.plist bereinigen

---

## Notes

### Key Decisions
- All C/C++ rendering code will be preserved
- highlight-wrapper stays intact (36 MB dylib)
- All 97 themes preserved
- Settings.swift properties unchanged (40+ properties)

### Rollback Points
- ✅ Baseline: Pre-migration state documented
- 🔄 After Phase 2: XPC removed, Settings functional
- 🔄 After Phase 5: All extensions removed
- 🔄 After Phase 7: Editor functional
- 🔄 After Phase 8: Migration complete

---

**Last Updated**: 2025-10-30
