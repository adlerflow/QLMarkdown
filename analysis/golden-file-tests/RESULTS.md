# Golden File Test Results

**Last Updated**: 2025-11-01 02:37

---

## Test Execution Log

### Baseline Generation: cmark-gfm

**Date**: 2025-11-01 02:37
**Status**: ✅ **SUCCESS**
**Command**: `./scripts/generate-baseline.sh cmark-gfm`
**Implementation**: cmark-gfm + cmark-extra (pre-migration)
**CLI**: `/Users/home/.local/bin/qlmarkdown_cli` (5.8M, from main branch)

Results:
- Processed: **13 / 13** ✅
- Failed: 0
- Output: `expected/cmark-gfm/`
- Total Lines: 942 LOC
- File Sizes: 1.7KB - 6.5KB per file

**Test Coverage Verified**:
- ✅ GFM core features (tables, task lists, autolinks, strikethrough)
- ✅ Emoji rendering (`:wave:` → 👋, `:heart:` → ❤️)
- ✅ Math support (MathJax integration)
- ✅ Heading anchors (auto-generated IDs)
- ✅ Highlights, subscript, superscript
- ✅ Mentions (`@username`)
- ⚠️ Footnotes (not currently supported - will be implemented in Plan 2)
- ✅ Syntax highlighting (11 languages)

---

### Plan 1: highlight-wrapper → highlight.js

**Date**: _Not yet run_
**Status**: Pending
**Command**: `./scripts/compare.sh plan1-highlightjs`

Expected Changes:
- Test 13 (code-highlighting.md): HTML class changes
  - Before: `<span class="hl kwa">` (libhighlight)
  - After: `<span class="hljs-keyword">` (highlight.js)

Results:
- Passed: 0 / 13
- Failed: 0

---

### Plan 2: cmark-gfm → swift-markdown

**Date**: _Not yet run_
**Status**: Pending
**Command**: `./scripts/compare.sh plan2-swiftmarkdown`

Expected Changes:
- Test 08 (heading-anchors.md): Anchor ID generation differences
- Test 12 (footnotes.md): New Swift implementation

Results:
- Passed: 0 / 13
- Failed: 0

---

## Detailed Test Results

| # | Test | Baseline | Plan 1 | Plan 2 | Notes |
|---|------|----------|--------|--------|-------|
| 01 | gfm-basics | ⏸️ | ⏸️ | ⏸️ | Headings, paragraphs, lists, code, emphasis |
| 02 | gfm-tables | ⏸️ | ⏸️ | ⏸️ | Tables with alignment |
| 03 | gfm-tasklists | ⏸️ | ⏸️ | ⏸️ | Checkboxes |
| 04 | gfm-autolinks | ⏸️ | ⏸️ | ⏸️ | URL and email autolinks |
| 05 | gfm-strikethrough | ⏸️ | ⏸️ | ⏸️ | `~~deleted~~` |
| 06 | emoji | ⏸️ | ⏸️ | ⏸️ | `:emoji:` → 😀 |
| 07 | math | ⏸️ | ⏸️ | ⏸️ | `$math$` MathJax |
| 08 | heading-anchors | ⏸️ | ⏸️ | ⚠️ | Auto-generated IDs |
| 09 | highlight-mark | ⏸️ | ⏸️ | ⏸️ | `==marked==` |
| 10 | subscript-superscript | ⏸️ | ⏸️ | ⏸️ | `~sub~` `^sup^` |
| 11 | mentions | ⏸️ | ⏸️ | ⏸️ | `@username` |
| 12 | footnotes | ⏸️ | ⏸️ | ⚠️ | `[^1]` references |
| 13 | code-highlighting | ⏸️ | ⚠️ | ⚠️ | Syntax highlighting |

**Legend**:
- ✅ Pass: Identical to baseline
- ⚠️ Expected difference: Changed as intended
- ❌ Fail: Unexpected difference
- ⏸️ Not yet run

---

## Issues Found

### Baseline Generation

_No issues yet_

### Plan 1 Testing

_No issues yet_

### Plan 2 Testing

_No issues yet_

---

## Action Items

- [ ] Generate cmark-gfm baseline
- [ ] Review baseline HTML manually
- [ ] Commit baseline to git
- [ ] Run Plan 1 comparison tests
- [ ] Run Plan 2 comparison tests

---

## Notes

- Visual verification required for test 13 (syntax highlighting themes)
- Footnotes test (12) will fail until Swift implementation complete
- Heading anchors (08) may have minor ID generation differences

---

**Template Version**: 1.0
**Created**: 2025-11-01
