# 🧠 ULTRATHINK: Settings → AppConfiguration Renaming

**Analysis Date**: 2025-11-02
**Scope**: Full rename (class + 4 extensions)
**Risk Level**: ⚠️⚠️ MODERATE-HIGH

---

## 📊 DISCOVERY METRICS

### Files to Rename (5 total)
```
Settings.swift              → AppConfiguration.swift                (675 LOC)
Settings+NoXPC.swift        → AppConfiguration+Persistence.swift    (42 LOC)
Settings+ext.swift          → AppConfiguration+Themes.swift         (48 LOC)
Settings+render.swift       → AppConfiguration+Rendering.swift      (91 LOC)
Settings+render.txt         → AppConfiguration+Rendering.txt.ref    (772 LOC - reference only)
```

### Code References to Update
```
Settings.shared             32 occurrences in 7 files
class Settings              1 definition (Settings.swift)
extension Settings          3 extensions
@Bindable var settings      4 SwiftUI views
@Observable                 1 macro on class Settings
Settings.applicationSupportUrl  Multiple static references
```

### Affected Files (12 total)

**High Impact (must update):**
1. ✅ `Settings.swift` - Class definition + @Observable
2. ✅ `Settings+NoXPC.swift` - 3 extensions
3. ✅ `Settings+ext.swift` - 1 extension
4. ✅ `Settings+render.swift` - 1 extension

**Medium Impact (Settings.shared references):**
5. ⚠️ `HighlightViewController.swift` - 13 references
6. ⚠️ `DocumentViewController.swift` - 10 references
7. ⚠️ `TextDownSettingsView.swift` - 5 references
8. ⚠️ `SyntaxSettingsView.swift` - 1 reference + @Bindable
9. ⚠️ `GeneralSettingsView.swift` - 1 reference + @Bindable
10. ⚠️ `ExtensionsSettingsView.swift` - 1 reference + @Bindable
11. ⚠️ `AdvancedSettingsView.swift` - 1 reference + @Bindable

**Build System:**
12. ⚠️ `TextDown.xcodeproj/project.pbxproj` - 5 file references + 5 build phases

**NOT Affected:**
- ❌ `Info.plist` - NSDocumentClass is "TextDown.MarkdownDocument" (no Settings)
- ❌ `settings.json` - Codable uses property names, not class name
- ❌ All 8 Rewriters - Receive Settings as parameter, don't use Settings.shared
- ❌ MarkdownRenderer - Receives Settings in constructor
- ❌ YamlHeaderProcessor - Receives Settings in constructor

---

## 🎯 IMPACT ANALYSIS

### ✅ LOW RISK AREAS

**1. JSON Persistence (NO BREAKING CHANGE)**
```swift
// Settings.swift uses Codable
class Settings: Codable { ... }

// JSON file: ~/Library/.../settings.json
{
  "emojiExtension": true,
  "mathExtension": true,
  ...
}
```
✅ Field names come from properties, NOT class name
✅ Existing settings.json files will work unchanged
✅ No migration needed

**2. Info.plist (NO CHANGE NEEDED)**
```xml
<key>NSDocumentClass</key>
<string>TextDown.MarkdownDocument</string>
```
✅ Not referencing Settings class

**3. Rewriters (NO CHANGE NEEDED)**
```swift
// All 8 rewriters receive Settings as parameter:
struct EmojiRewriter: MarkupRewriter {
    let settings: Settings  // Just change type annotation
}

// No Settings.shared references in:
- EmojiRewriter.swift
- HighlightRewriter.swift
- SubSupRewriter.swift
- MentionRewriter.swift
- InlineImageRewriter.swift
- MathRewriter.swift
- HeadingIDGenerator.swift (doesn't use Settings at all)
- YamlHeaderProcessor.swift
```
✅ Only type annotations need update (8 files, trivial)

---

### ⚠️ MODERATE RISK AREAS

**1. Settings.shared Static Singleton (32 references)**

**Files by Reference Count:**
```
HighlightViewController.swift      13x Settings.shared
DocumentViewController.swift       10x Settings.shared
TextDownSettingsView.swift         5x Settings.shared
SyntaxSettingsView.swift           1x Settings.shared
GeneralSettingsView.swift          1x Settings.shared
ExtensionsSettingsView.swift       1x Settings.shared
AdvancedSettingsView.swift         1x Settings.shared
```

**Example Changes:**
```swift
// BEFORE
let html = Settings.shared.render(...)
if Settings.shared.openInlineLink { ... }

// AFTER
let html = AppConfiguration.shared.render(...)
if AppConfiguration.shared.openInlineLink { ... }
```

⚠️ Manual search-and-replace needed
⚠️ High error potential (32 occurrences)
✅ Easy to verify (compiler errors)

**2. SwiftUI @Bindable Bindings (4 views)**

```swift
// BEFORE
struct GeneralSettingsView: View {
    @Bindable var settings: Settings
    ...
}

// AFTER
struct GeneralSettingsView: View {
    @Bindable var settings: AppConfiguration
    ...
}
```

⚠️ @Observable macro may need rebuild
✅ SwiftUI compiler will catch errors

---

### 🔴 HIGH RISK AREAS

**1. Xcode project.pbxproj (5 file references)**

**UUIDs to Update:**
```
83F4B99125868A7400FC58A7 /* Settings.swift */
838D197B2DCDD96100963323 /* Settings+NoXPC.swift */
83327D452595E15700E76CF6 /* Settings+ext.swift */
83D22E632DCA65980013EB9D /* Settings+render.swift */
83D22E632DCA65980013EB9D /* Settings+render.txt */ (if added)
```

**Affected Sections:**
- PBXBuildFile (5 entries)
- PBXFileReference (5 entries)
- PBXGroup children (5 paths)
- PBXSourcesBuildPhase (4 entries, .txt excluded)

⚠️⚠️ Manual editing of project.pbxproj HIGHLY RISKY
⚠️⚠️ Xcode refactoring does NOT work across extensions
✅ Use `git mv` to preserve history

**Recommended Approach:**
1. Rename files in Xcode GUI (one by one)
2. OR: Use `git mv` + manually fix project.pbxproj
3. Verify with `plutil` or open in Xcode

**2. @Observable Macro Expansion**

```swift
// BEFORE
@Observable
class Settings: Codable { ... }

// AFTER
@Observable
class AppConfiguration: Codable { ... }
```

⚠️ Macro generates hidden code (`_$observationRegistrar`, etc.)
⚠️ May require clean build to regenerate
⚠️ Potential SwiftUI binding breakage

---

## 🔧 EXECUTION PLAN (14 Steps)

### Phase 1: Preparation (Safety First)
```bash
# Step 1: Create feature branch
git checkout -b refactor/settings-to-appconfig

# Step 2: Create rollback tag
git tag -a pre-rename-settings -m "Before Settings → AppConfiguration rename"

# Step 3: Verify clean working tree
git status  # Should be clean
```

### Phase 2: File Renaming (Preserve Git History)
```bash
# Step 4: Rename files using git mv (preserves history)
git mv TextDown/Settings.swift TextDown/AppConfiguration.swift
git mv TextDown/Settings+NoXPC.swift TextDown/AppConfiguration+Persistence.swift
git mv TextDown/Settings+ext.swift TextDown/AppConfiguration+Themes.swift
git mv TextDown/Settings+render.swift TextDown/AppConfiguration+Rendering.swift
git mv TextDown/Settings+render.txt TextDown/AppConfiguration+Rendering.txt.ref

# Step 5: Commit renames BEFORE code changes
git commit -m "refactor: Rename Settings files (no code changes yet)"
```

### Phase 3: Update Class Definition
```bash
# Step 6: Edit AppConfiguration.swift
# Change: class Settings → class AppConfiguration
# Change: static let shared = Settings() → static let shared = AppConfiguration()

# Step 7: Update extensions
# AppConfiguration+Persistence.swift: extension Settings → extension AppConfiguration
# AppConfiguration+Themes.swift: extension Settings → extension AppConfiguration
# AppConfiguration+Rendering.swift: extension Settings → extension AppConfiguration

# Step 8: Commit class rename
git commit -m "refactor: Rename Settings class to AppConfiguration"
```

### Phase 4: Update All References
```bash
# Step 9: Find-and-replace in 7 files
# Settings.shared → AppConfiguration.shared (32 occurrences)

# HighlightViewController.swift (13 changes)
# DocumentViewController.swift (10 changes)
# TextDownSettingsView.swift (5 changes)
# + 4 Preferences views (1 change each)

# Step 10: Update @Bindable type annotations (4 files)
# @Bindable var settings: Settings → @Bindable var settings: AppConfiguration

# Step 11: Update Rewriter type annotations (8 files)
# let settings: Settings → let settings: AppConfiguration

# Step 12: Commit reference updates
git commit -m "refactor: Update all Settings → AppConfiguration references"
```

### Phase 5: Build System
```bash
# Step 13: Update Xcode project.pbxproj
# OPTION A: Let Xcode auto-update (open project, Xcode fixes paths)
# OPTION B: Manual sed replacements (RISKY)

# Verify project structure:
plutil -lint TextDown.xcodeproj/project.pbxproj

# Step 14: Commit build system changes
git commit -m "refactor: Update Xcode project references"
```

### Phase 6: Verification
```bash
# Clean build test
xcodebuild -scheme TextDown -configuration Debug clean build

# Runtime test
open TextDown.app
# 1. Open .md file
# 2. Check rendering works
# 3. Open Preferences (Cmd+,)
# 4. Change settings
# 5. Verify persistence (quit & reopen)

# Unit tests
xcodebuild test -scheme TextDown
```

---

## 🚨 RISK MITIGATION

### Critical Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Xcode project corruption** | Medium | High | Use git tags, commit after each step |
| **@Observable macro issues** | Low | Medium | Clean build, delete DerivedData |
| **SwiftUI binding breakage** | Low | Medium | Compiler will catch, fix type annotations |
| **JSON persistence breakage** | Very Low | High | ✅ Codable uses property names (safe) |
| **Missed Settings references** | Medium | Low | Compiler errors will surface all |
| **Build system path issues** | Medium | Medium | Let Xcode auto-fix, or manual verification |

### Rollback Strategy

**If things go wrong:**
```bash
# OPTION 1: Rollback to tag
git reset --hard pre-rename-settings
git clean -fdx  # Remove untracked files

# OPTION 2: Revert specific commits
git revert HEAD~3..HEAD  # Revert last 3 commits

# OPTION 3: Abandon branch
git checkout main
git branch -D refactor/settings-to-appconfig
```

**Clean DerivedData** (if @Observable issues):
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/TextDown-*
xcodebuild clean -scheme TextDown
```

---

## ⏱️ ESTIMATED TIME

| Phase | Duration | Risk |
|-------|----------|------|
| Preparation (git branch, tags) | 2 min | None |
| File renaming (git mv × 5) | 5 min | Low |
| Class definition update | 10 min | Low |
| Reference updates (32 × Settings.shared) | 30 min | Medium |
| @Bindable updates (4 files) | 5 min | Low |
| Rewriter type annotations (8 files) | 10 min | Low |
| Xcode project.pbxproj | 15 min | High |
| Clean build | 1 min | - |
| Testing (manual + unit tests) | 20 min | - |
| **TOTAL** | **~90 min** | **MODERATE** |

---

## 🎯 RECOMMENDATION

### ✅ PROCEED WITH CAUTION

**Pros:**
- Clear semantic improvement (Settings → AppConfiguration)
- Better code organization (+Persistence, +Themes, +Rendering)
- No JSON breaking changes (Codable safe)
- No Info.plist changes needed
- Compiler will catch 100% of missed references

**Cons:**
- 12 files to update (moderate scope)
- 32 Settings.shared references (error-prone)
- Xcode project.pbxproj manual editing (risky)
- 90 minute time investment
- Potential @Observable macro issues

**Decision Matrix:**

| Criteria | Score (1-5) | Weight | Weighted |
|----------|-------------|--------|----------|
| Semantic clarity | 5 | 0.3 | 1.5 |
| Code maintainability | 4 | 0.2 | 0.8 |
| Breaking change risk | 2 | 0.3 | 0.6 |
| Time investment | 3 | 0.2 | 0.6 |
| **TOTAL** | - | - | **3.5/5** |

**Verdict: PROCEED** ✅

**Best Time to Execute:**
- ✅ After current swift-markdown migration stabilizes
- ✅ Before next major feature work
- ✅ When you have 2 hours for thorough testing
- ❌ NOT during active feature development
- ❌ NOT before release/deadline

---

## 📝 ALTERNATIVE: Conservative Approach

**If you want MINIMAL RISK, rename extensions only:**

```
Settings.swift              → Settings.swift (NO CHANGE)
Settings+NoXPC.swift        → Settings+Persistence.swift
Settings+ext.swift          → Settings+Themes.swift
Settings+render.swift       → Settings+Rendering.swift
Settings+render.txt         → Settings+Rendering.txt.ref
```

**Impact:**
- Only 4 file renames
- NO code changes (just file paths)
- NO Settings.shared updates
- NO @Bindable changes
- Only project.pbxproj paths update

**Time:** 15 minutes
**Risk:** MINIMAL ✅

---

## 🎬 READY TO EXECUTE?

**Checklist before starting:**
- [ ] Current branch is clean (`git status`)
- [ ] Recent backup exists
- [ ] Have 90-120 minutes available
- [ ] No urgent deadlines this week
- [ ] Prepared to rollback if needed

**Command to start:**
```bash
git checkout -b refactor/settings-to-appconfig
git tag -a pre-rename-settings -m "Before Settings → AppConfiguration rename"
# Then follow execution plan above
```

---

📚 Analysis generated with [Claude Code](https://claude.com/claude-code)
