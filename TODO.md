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

### Phase 1: XPC Service Elimination ⏳ NEXT
- [ ] Switch Settings.swift to use Settings+NoXPC exclusively
- [ ] Remove TextDownXPCHelper target from build
- [ ] Delete TextDownXPCHelper/ folder
- [ ] Remove external-launcher target
- [ ] Delete external-launcher/ folder
- [ ] Update Info.plist (remove XPC declarations)
- [ ] Test Settings persistence

### Phase 2: Extension Elimination ⏳ FUTURE
- [ ] Disable Extension target in build scheme
- [ ] Remove Extension target from project
- [ ] Delete Extension/ folder
- [ ] Remove Shortcuts Extension target
- [ ] Delete Shortcut Extension/ folder
- [ ] Clean Info.plist from extension declarations

### Phase 3: Standalone Editor Implementation ⏳ FUTURE
- [ ] Create EditorViewController skeleton
- [ ] Implement split-view layout (NSTextView + WKWebView)
- [ ] Add live preview with debounced rendering
- [ ] Implement NSDocument architecture
- [ ] Add File Open/Save/Auto-Save
- [ ] Add toolbar and menu items
- [ ] Integrate with Settings (via NoXPC)
- [ ] Testing and polish

---

## Legacy TODOs (Original QLMarkdown)

### Bugs
- [ ] Bugfix: footnote option and super/sub script extension are incompatible
- [ ] Bugfix: on dark style, there is a flashing white rectangle before show the preview on Monterey
- [ ] Check inline images on network / mounted disk

### Features
- [ ] Investigate if export syntax highlighting colors scheme style as CSS var overriding the default style
- [ ] Localization support

### Completed Legacy Items
- [x] Check code signature and app group access (bypassed using an XPC process)
- [x] Syntax highlighting color scheme editor
- [x] Optimize the inline image extension for raw html code
- [x] Embed inline image for `<img>` raw tag without using javascript/callbacks
- [x] Emoji extension: better code that parse the single placeholder and generate nodes inside the AST
- [x] Investigate CMARK_OPT_UNSAFE for inline images
- [x] Application screenshot in the docs
- [x] Extension to generate anchor link for heads
- [x] Sparkle update engine
- [x] Insert the `highlight` library on the build process
- [x] @rpath libwrapper

---

**Last Updated**: 2025-10-31
**Phase 0.75 Completed**: 2025-10-31
**Git Commits**: 0b0daee, e197268, 1dcf912, 5009714
