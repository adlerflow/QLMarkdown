# Golden File Test Strategy

**Date**: 2025-11-01
**Purpose**: Testing strategy for Plan 1 and Plan 2 migrations

---

## Overview

This document defines the testing strategy for validating HTML output consistency across three implementations:

1. **Baseline**: cmark-gfm + cmark-extra (current)
2. **Plan 1**: After highlight-wrapper → highlight.js migration
3. **Plan 2**: After cmark-gfm → swift-markdown migration

---

## Test Approach

### Golden File Testing

**Definition**: Compare HTML output against known-good "golden" files

**Process**:
1. **Baseline Capture**: Generate golden files from current implementation
2. **Code Migration**: Make implementation changes
3. **Comparison**: Generate new HTML and compare to golden files
4. **Validation**: Review differences and update golden files if correct

**Benefits**:
- Catches regressions immediately
- Documents expected output
- Provides clear pass/fail criteria
- Enables automated testing

---

## Test Phases

### Phase 0: Baseline Generation

**When**: Before any migration work
**Goal**: Capture current HTML output as baseline

**Steps**:
```bash
# 1. Ensure clean build
cd /Users/home/GitHub/QLMarkdown
xcodebuild clean -scheme TextDown
xcodebuild -scheme TextDown -configuration Debug

# 2. Generate baseline
cd analysis/golden-file-tests
./scripts/generate-baseline.sh cmark-gfm

# 3. Manual review
open expected/cmark-gfm/

# 4. Commit to git
git add expected/cmark-gfm/
git commit -m "test: Add baseline golden files for cmark-gfm"
```

**Acceptance Criteria**:
- ✅ 13/13 files generated successfully
- ✅ Manual review shows correct HTML structure
- ✅ All TextDown extensions working (emoji, math, etc.)
- ✅ Syntax highlighting applied correctly

---

### Phase 1: Plan 1 Testing (highlight-wrapper → highlight.js)

**When**: After each major step in Plan 1
**Goal**: Ensure non-highlighting features unchanged

**Test Frequency**:
- After removing syntaxhighlight.c extension
- After removing highlight-wrapper build system
- After integrating highlight.js
- After theme migration
- Before final commit

**Steps**:
```bash
# 1. Run comparison
./scripts/compare.sh cmark-gfm

# 2. Review failures
# Expected: Test 13 (code-highlighting) will differ
# Unexpected: Tests 01-12 should pass

# 3. Generate new golden files for Plan 1
./scripts/generate-baseline.sh plan1-highlightjs

# 4. Visual verification of syntax highlighting
open expected/plan1-highlightjs/13-code-highlighting.html
# Compare side-by-side with baseline
```

**Acceptance Criteria**:
- ✅ Tests 01-12: 100% match (no regressions)
- ✅ Test 13: Visual appearance correct (despite HTML differences)
- ✅ highlight.js themes work
- ✅ Language detection works

**Known Expected Differences** (Test 13):
```html
<!-- Before (libhighlight) -->
<span class="hl kwa">function</span>

<!-- After (highlight.js) -->
<span class="hljs-keyword">function</span>
```

---

### Phase 2: Plan 2 Testing (cmark-gfm → swift-markdown)

**When**: After each major step in Plan 2
**Goal**: Ensure GFM compliance and extension parity

**Test Frequency**:
- After adding swift-markdown SPM dependency
- After migrating GFM core (tests 01-05)
- After each extension migration (tests 06-13)
- Before final commit

**Steps**:
```bash
# 1. Run comparison against cmark-gfm baseline
./scripts/compare.sh cmark-gfm

# 2. Review failures
# Expected: Tests 08, 12 may differ slightly
# Expected: Test 13 differs (already changed in Plan 1)

# 3. Verify GFM spec compliance
# For any differences in tests 01-05, check GFM spec:
# https://github.github.com/gfm/

# 4. Generate new golden files for Plan 2
./scripts/generate-baseline.sh plan2-swiftmarkdown

# 5. Final verification
./scripts/run-tests.swift plan2-swiftmarkdown
```

**Acceptance Criteria**:
- ✅ Tests 01-05: GFM spec compliant (may differ from cmark-gfm)
- ✅ Tests 06-11: Swift post-processing works (emoji, math, etc.)
- ✅ Test 08: Heading anchors generated correctly
- ✅ Test 12: Footnotes work (new Swift implementation)
- ✅ Test 13: Syntax highlighting works (from Plan 1)

**Known Expected Differences**:

**Test 08** (heading-anchors):
```html
<!-- Possible difference in anchor ID generation -->
<!-- Before (heads.c + libpcre2) -->
<h2 id="hello-world">Hello World!</h2>

<!-- After (Swift post-processing) -->
<h2 id="hello-world">Hello World!</h2>
<!-- (Should match, but algorithm may differ slightly) -->
```

**Test 12** (footnotes):
```html
<!-- New implementation in Swift -->
<!-- Before (not supported in swift-markdown) -->
[^1] remains as-is

<!-- After (Swift post-processing) -->
<sup id="fnref-1"><a href="#fn-1">1</a></sup>
```

---

## Test Coverage Analysis

### GFM Features (5 tests)

| Feature | Test | cmark-gfm | swift-markdown | Risk |
|---------|------|-----------|----------------|------|
| Headings, Paragraphs | 01 | ✅ | ✅ | Low |
| Tables | 02 | ✅ | ✅ | Low |
| Task Lists | 03 | ✅ | ✅ | Low |
| Autolinks | 04 | ✅ | ✅ | Low |
| Strikethrough | 05 | ✅ | ✅ | Low |

**Risk Assessment**: **LOW**
- All features supported natively in swift-markdown
- Well-defined GFM spec
- Extensive test coverage in swift-markdown repo

### TextDown Extensions (8 tests)

| Extension | Test | Current | Plan 1 | Plan 2 | Risk |
|-----------|------|---------|--------|--------|------|
| Emoji | 06 | emoji.c | emoji.c | Swift | Medium |
| Math | 07 | math_ext.c | math_ext.c | Swift | Low |
| Heading Anchors | 08 | heads.c | heads.c | Swift | Medium |
| Highlight | 09 | highlight.c | highlight.c | Swift | Low |
| Sub/Sup | 10 | sub/sup.c | sub/sup.c | Swift | Low |
| Mentions | 11 | mention.c | mention.c | Swift | Low |
| Footnotes | 12 | ❌ Not impl | ❌ Not impl | Swift | High |
| Syntax Highlight | 13 | wrapper_highlight | highlight.js | highlight.js | High |

**Risk Assessment**:

- **Low Risk** (Tests 07, 09, 10, 11): Simple regex replacements
- **Medium Risk** (Tests 06, 08): More complex logic, edge cases
- **High Risk** (Tests 12, 13): New implementations

---

## Regression Testing

### Critical User Features

**Must not break**:
1. Syntax highlighting themes (97 themes → 258 themes)
2. Math rendering (MathJax CDN integration)
3. Emoji support (common emojis: smile, heart, fire, etc.)
4. Table alignment (left, center, right)
5. Task list checkboxes (checked vs unchecked)

### Performance Testing

**Not covered by golden files** - requires separate benchmarking:

| Metric | Current | Target | Method |
|--------|---------|--------|--------|
| Parse time (10KB file) | ~5-10ms | ~3-5ms | Instruments Time Profiler |
| Render time (10KB file) | ~20-30ms | ~15-20ms | Instruments Time Profiler |
| Memory usage | ~50MB | ~30MB | Instruments Allocations |
| Bundle size | 50MB | 36-39MB | `du -sh TextDown.app` |
| Build time (clean) | ~15min | ~3-4min | `time xcodebuild clean build` |

---

## Edge Case Testing

### Known Edge Cases

**Test 06** (emoji):
- Invalid emoji names: `:nonexistent_emoji_xyz123:`
- Double colons: `::double_colon::`
- No spacing: `Text:smile:text`

**Test 08** (heading-anchors):
- Empty headings: `##`
- Duplicate headings: Three `## Section One`
- Unicode: `## Café ☕`

**Test 12** (footnotes):
- Undefined references: `[^undefined]`
- Unused definitions: `[^unused]:`
- Multiple references: `[^ref]` used 3 times

**Test 13** (code-highlighting):
- No language specified: ` ``` ` (no language tag)
- Unknown language: ` ```unknown-language-xyz` `

---

## Continuous Integration

### GitHub Actions Workflow (Future)

```yaml
name: Golden File Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build TextDown
        run: |
          xcodebuild clean -scheme TextDown
          xcodebuild -scheme TextDown -configuration Debug
      - name: Run Golden File Tests
        run: |
          cd analysis/golden-file-tests
          swift scripts/run-tests.swift cmark-gfm
      - name: Upload Results
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: analysis/golden-file-tests/RESULTS.md
```

---

## Manual Testing Checklist

### Before Migration

- [ ] Generate baseline golden files
- [ ] Verify baseline correctness (manual review)
- [ ] Test all 97 themes work
- [ ] Commit baseline to git

### During Plan 1

- [ ] Run tests after syntaxhighlight.c removal
- [ ] Run tests after highlight-wrapper removal
- [ ] Run tests after highlight.js integration
- [ ] Visual theme verification (10+ themes)
- [ ] Test language detection edge cases

### During Plan 2

- [ ] Run tests after swift-markdown integration
- [ ] Run tests after each extension migration
- [ ] Verify GFM spec compliance (tests 01-05)
- [ ] Test footnotes thoroughly
- [ ] Performance benchmarking

### Post-Migration

- [ ] Full regression test suite
- [ ] Bundle size verification
- [ ] Build time verification
- [ ] Memory usage verification
- [ ] User acceptance testing

---

## Rollback Criteria

### When to Rollback Plan 1

- ❌ Tests 01-12 fail with unexpected differences
- ❌ Visual theme rendering broken for >5 themes
- ❌ Language detection fails for common languages
- ❌ Bundle size increases instead of decreases
- ❌ Performance regression >20%

### When to Rollback Plan 2

- ❌ GFM core features broken (tests 01-05)
- ❌ Extension migration fails for >2 extensions
- ❌ Footnotes implementation too buggy
- ❌ Performance regression >30%
- ❌ Build breaks on clean build

---

## Success Metrics

### Plan 1 Success

✅ **Quantitative**:
- 12/13 tests pass (test 13 expected to change)
- Bundle size: 50MB → ~44MB (-12%)
- Build time: 15min → ~10min (-33%)
- All 258 highlight.js themes work

✅ **Qualitative**:
- Visual theme appearance matches libhighlight
- No user-reported regressions
- Code is cleaner and more maintainable

### Plan 2 Success

✅ **Quantitative**:
- 13/13 tests pass (with new golden files)
- Bundle size: ~44MB → ~36-39MB (total -22 to -28%)
- Build time: ~10min → ~3-4min (total -73 to -80%)
- 100% GFM feature parity

✅ **Qualitative**:
- Pure Swift codebase (no C dependencies)
- Faster incremental builds (<30s)
- Maintainability improved
- Apple-supported Markdown parser

---

## Documentation

### Test Results Documentation

After each test run, update:
- `RESULTS.md`: Test execution log
- `TODO.md`: Mark tasks complete
- `CLAUDE.md`: Update migration status
- Git commit messages: Clear test status

### Example Commit Message

```
test: Verify Plan 1 HTML output (12/13 pass)

Golden file tests after highlight.js migration:
- ✅ Tests 01-12: No regressions
- ⚠️ Test 13: Expected HTML structure changes
  - libhighlight classes → highlight.js classes
  - Visual appearance verified manually

Next: Generate plan1-highlightjs golden files
```

---

## References

- **GFM Spec**: https://github.github.com/gfm/
- **CommonMark Spec**: https://spec.commonmark.org/
- **swift-markdown Tests**: /Users/home/GitHub/swift-markdown/Tests/
- **cmark-gfm Tests**: /Users/home/GitHub/QLMarkdown/cmark-gfm/test/

---

**Status**: Strategy defined ✅
**Next Steps**:
1. Generate baseline (Phase 0)
2. Begin Plan 1 with test-driven approach
3. Continuous testing throughout migrations

**Created**: 2025-11-01
**Last Updated**: 2025-11-01
