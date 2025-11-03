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

## Future Enhancements

### Features to Consider
- [ ] Export as PDF (using SwiftUI rendering)
- [ ] Full GFM table support (complex layouts)
- [ ] Interactive task list checkboxes
- [ ] Math rendering (MathJax alternative in SwiftUI)
- [ ] Extended language support for syntax highlighting (beyond current 5)
- [ ] Theme customization (user-defined color schemes)
- [ ] iCloud sync for preferences
- [ ] Split-view resizing persistence

### Known Limitations
- **Math**: No MathJax in pure SwiftUI (requires custom renderer)
- **GFM Tables**: Placeholder view (needs custom layout engine)
- **Task Lists**: Placeholder view (needs interactive checkboxes)
- **Syntax Highlighting**: 5 languages (vs 190+ in highlight.js)
- **Auto-Updates**: Sparkle removed (requires AppKit integration)

### Technical Debt
- [ ] Implement comprehensive unit tests for SwiftUI views
- [ ] Add snapshot tests for MarkdownASTView rendering
- [ ] Performance profiling for large markdown files (>10K lines)
- [ ] Accessibility audit (VoiceOver support)
- [ ] Localization infrastructure (prepare for i18n)

---

## Migration History (Archived)

All migration phases completed between October-November 2025. See `CLAUDE.md` for detailed history.

### Completed Phases
1. **swift-markdown** (2025-11-02) - Replaced cmark-gfm with Apple's swift-markdown
2. **Pure SwiftUI** (2025-11-03) - 100% SwiftUI, deleted all AppKit components
3. **Phase 5** (2025-11-03) - BundleResources cleanup (212 KB removed)
4. **Phase 6** (2025-11-03) - Rendering pipeline cleanup (1,664 LOC, 103 files removed)
5. **Folder Reorg** (2025-11-03) - Tier 3 folder reorganization (90 files moved)
6. **Documentation** (2025-11-03) - CLAUDE.md & TODO.md cleanup (-1,008 + -450 lines)

### Key Commits
- `2e6dd4a` - Big-bang SwiftUI migration (deleted all AppKit)
- `163a6f5` - Color migration (NSColor → SwiftUI Color)
- `9ebff56` - Removed BundleResources/ (212 KB)
- `2146ac6` - Removed Rendering/ + tests + artifacts (1,664 LOC, 103 files)
- `57388a2` - Tier 3 folder reorganization
- `bee9fdd` - CLAUDE.md cleanup (-1,008 lines, -51%)

For complete migration documentation, see:
- `CLAUDE.md` - Current architecture & migration summary
- `docs/migration/` - Detailed migration plans & guides
