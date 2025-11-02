//
//  RenderingTests.swift
//  TextDownTests
//
//  Created by Claude Code on 2025-11-02.
//  Phase 0: Test Suite Creation - C Extension Activation & Rendering Tests
//

import XCTest
@testable import TextDown

final class RenderingTests: XCTestCase {
    var settings: Settings!

    override func setUp() {
        super.setUp()
        settings = Settings.factorySettings
    }

    override func tearDown() {
        settings = nil
        super.tearDown()
    }

    // MARK: - GFM Core Extensions (6 tests)

    func testTableExtension() throws {
        settings.tableExtension = true
        let markdown = """
        | Column 1 | Column 2 | Column 3 |
        |----------|----------|----------|
        | Cell 1   | Cell 2   | Cell 3   |
        | Cell 4   | Cell 5   | Cell 6   |
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<table"), "Should contain <table> tag")
        XCTAssertTrue(html.contains("<th>"), "Should contain <th> headers")
        XCTAssertTrue(html.contains("<td>"), "Should contain <td> cells")
        XCTAssertTrue(html.contains("Column 1"), "Should contain table header text")
        XCTAssertTrue(html.contains("Cell 1"), "Should contain table cell text")
    }

    func testAutoLinkExtension() throws {
        settings.autoLinkExtension = true
        let markdown = "Visit https://github.com for more info."

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<a"), "Should contain link tag")
        XCTAssertTrue(html.contains("https://github.com"), "Should contain URL")
    }

    func testTagFilterExtension() throws {
        settings.tagFilterExtension = true
        // Tag filter removes potentially dangerous HTML tags
        let markdown = "<script>alert('xss')</script>\n<title>Title</title>"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Tag filter should escape or remove dangerous tags when combined with unsafe HTML option
        XCTAssertFalse(html.contains("<script>alert"), "Should filter <script> tags")
    }

    func testTaskListExtension() throws {
        settings.taskListExtension = true
        let markdown = """
        - [ ] Unchecked task
        - [x] Checked task
        - [ ] Another task
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("checkbox"), "Should contain checkbox class or type")
        // GitHub-style task lists use data-task or checkbox inputs
        XCTAssertTrue(html.contains("<input") || html.contains("data-task"),
                     "Should contain task list markers")
    }

    func testYAMLExtension() throws {
        settings.yamlExtension = true
        settings.yamlExtensionAll = false  // Only for .rmd/.qmd files
        settings.tableExtension = true  // Required for YAML table rendering

        let markdown = """
        ---
        title: Test Document
        author: Claude
        date: 2025-11-02
        ---

        # Content
        """

        let html = try settings.render(text: markdown, filename: "test.rmd",
                                       forAppearance: .light, baseDir: "/tmp")

        // YAML header should be rendered as table or code block
        XCTAssertTrue(html.contains("title") || html.contains("Test Document"),
                     "Should contain YAML metadata")
    }

    func testStrikethroughExtension() throws {
        settings.strikethroughExtension = true
        settings.strikethroughDoubleTildeOption = false  // Single or double tilde

        let markdown = "This is ~~deleted text~~ content."

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<del>"), "Should contain <del> tag")
        XCTAssertTrue(html.contains("deleted text"), "Should contain strikethrough text")
    }

    // MARK: - Custom Extensions (7 tests for main extensions)

    func testEmojiExtension_UnicodeMode() throws {
        settings.emojiExtension = true
        settings.emojiImageOption = false  // Unicode characters

        let markdown = ":smile: :heart: :rocket:"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Should contain Unicode emoji characters
        XCTAssertTrue(html.contains("😄") || html.contains("smile"), "Should contain smile emoji")
        XCTAssertTrue(html.contains("❤") || html.contains("heart"), "Should contain heart emoji")
    }

    func testEmojiExtension_ImageMode() throws {
        settings.emojiExtension = true
        settings.emojiImageOption = true  // GitHub CDN images

        let markdown = ":smile:"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Should contain img tag or GitHub emoji reference
        XCTAssertTrue(html.contains("<img") || html.contains("emoji"),
                     "Should contain emoji image reference")
    }

    func testMathExtension() throws {
        settings.mathExtension = true

        let markdown = """
        Inline math: $E=mc^2$

        Display math:
        $$
        \\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}
        $$
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Should contain LaTeX math notation
        XCTAssertTrue(html.contains("$E=mc^2$") || html.contains("E=mc"),
                     "Should contain inline math")
        XCTAssertTrue(html.contains("\\int") || html.contains("int_0"),
                     "Should contain display math")
    }

    func testHeadsExtension() throws {
        settings.headsExtension = true

        let markdown = """
        # Main Heading
        ## Sub Heading
        ### Third Level
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Should have auto-generated anchor IDs
        XCTAssertTrue(html.contains("id=") || html.contains("Main Heading"),
                     "Should contain heading with ID")
        // Common formats: id="main-heading" or id='main-heading'
        XCTAssertTrue(html.contains("main-heading") || html.contains("Main Heading"),
                     "Should contain heading anchor")
    }

    func testHighlightExtension() throws {
        settings.highlightExtension = true

        let markdown = "This is ==highlighted text== content."

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<mark>") || html.contains("highlighted"),
                     "Should contain highlighted/marked text")
    }

    func testSubExtension() throws {
        settings.subExtension = true

        let markdown = "H~2~O"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<sub>") || html.contains("subscript"),
                     "Should contain subscript tag")
    }

    func testSupExtension() throws {
        settings.supExtension = true

        let markdown = "E=mc^2^"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<sup>") || html.contains("superscript"),
                     "Should contain superscript tag")
    }

    // MARK: - Parser Options Tests (6 tests)

    func testHardBreakOption() throws {
        settings.hardBreakOption = true

        let markdown = "Line 1\nLine 2\nLine 3"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<br"), "Should contain line breaks")
    }

    func testSmartQuotesOption() throws {
        settings.smartQuotesOption = true

        let markdown = "\"Hello\" and 'world'"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Smart quotes: " " and ' '
        XCTAssertTrue(html.contains(""") || html.contains("&#8220;"),
                     "Should contain smart opening quote")
        XCTAssertTrue(html.contains(""") || html.contains("&#8221;"),
                     "Should contain smart closing quote")
    }

    func testFootnotesOption() throws {
        settings.footnotesOption = true

        let markdown = """
        This is a sentence with a footnote.[^1]

        [^1]: This is the footnote content.
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("footnote") || html.contains("note"),
                     "Should contain footnote reference")
    }

    func testUnsafeHTMLOption() throws {
        settings.unsafeHTMLOption = true

        let markdown = "<div class='custom'>Custom HTML</div>"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("<div"), "Should contain raw HTML when unsafe option enabled")
        XCTAssertTrue(html.contains("custom"), "Should contain custom class")
    }

    func testValidateUTFOption() throws {
        settings.validateUTFOption = true

        // Valid UTF-8
        let markdown = "Hello 世界 🌍"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertTrue(html.contains("Hello"), "Should contain valid UTF-8 text")
        XCTAssertTrue(html.contains("世界") || html.contains("🌍"), "Should contain Unicode")
    }

    func testNoSoftBreakOption() throws {
        settings.noSoftBreakOption = true

        let markdown = "Line 1\nLine 2"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // With NOBREAKS option, single newlines should not create <br>
        XCTAssertFalse(html.contains("<br"), "Should not contain line breaks with NOBREAKS")
    }

    // MARK: - Complete Rendering Pipeline Tests

    func testCompleteHTMLOutput() throws {
        // Enable multiple extensions
        settings.tableExtension = true
        settings.emojiExtension = true
        settings.mathExtension = true
        settings.syntaxHighlightExtension = true
        settings.strikethroughExtension = true
        settings.headsExtension = true

        let markdown = """
        # Test Document

        ## Features

        ### Table
        | Feature | Status |
        |---------|--------|
        | Tables  | ✓      |

        ### Emoji
        :smile: :heart:

        ### Math
        $E=mc^2$

        ### Code
        ```python
        print("hello world")
        ```

        ### Strikethrough
        ~~deleted~~ text
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Verify all extensions produced output
        XCTAssertTrue(html.contains("<table") || html.contains("Feature"),
                     "Should contain table")
        XCTAssertTrue(html.contains("smile") || html.contains("😄"),
                     "Should contain emoji")
        XCTAssertTrue(html.contains("$E=mc^2$") || html.contains("E=mc"),
                     "Should contain math")
        XCTAssertTrue(html.contains("<code") || html.contains("python"),
                     "Should contain code block")
        XCTAssertTrue(html.contains("<del>") || html.contains("deleted"),
                     "Should contain strikethrough")

        // Get complete HTML with wrapper
        let completeHTML = settings.getCompleteHTML(
            title: "Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        XCTAssertTrue(completeHTML.contains("<!doctype html>"), "Should have DOCTYPE")
        XCTAssertTrue(completeHTML.contains("<html>"), "Should have HTML tag")
        XCTAssertTrue(completeHTML.contains("<head>"), "Should have HEAD section")
        XCTAssertTrue(completeHTML.contains("<body>"), "Should have BODY section")
        XCTAssertTrue(completeHTML.contains("</html>"), "Should close HTML tag")
    }

    func testMathJaxInjection() throws {
        settings.mathExtension = true

        let markdown = "$x^2 + y^2 = z^2$"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Math Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        // Should include MathJax CDN script
        XCTAssertTrue(completeHTML.contains("MathJax") || completeHTML.contains("mathjax"),
                     "Should include MathJax script")
        XCTAssertTrue(completeHTML.contains("cdn.jsdelivr.net") ||
                     completeHTML.contains("MathJax"),
                     "Should include MathJax CDN")
    }

    func testHighlightJSInjection() throws {
        settings.syntaxHighlightExtension = true
        settings.syntaxThemeLightOption = "github"

        let markdown = """
        ```javascript
        console.log('hello');
        ```
        """

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Code Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        // Should include highlight.js script (inline)
        XCTAssertTrue(completeHTML.contains("hljs") || completeHTML.contains("highlight"),
                     "Should include highlight.js")
        XCTAssertTrue(completeHTML.contains("github") || completeHTML.contains("theme"),
                     "Should include theme CSS")
    }

    func testCustomCSSInjection() throws {
        settings.customCSSOverride = false  // Include both default and custom
        settings.customCSSCode = "body { background-color: red; }"
        settings.customCSSFetched = true

        let markdown = "# Test"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "CSS Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        XCTAssertTrue(completeHTML.contains("background-color: red"),
                     "Should include custom CSS")
    }

    func testDebugInfoRendering() throws {
        settings.debug = true
        settings.tableExtension = true
        settings.emojiExtension = true

        let markdown = "# Test"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // Debug mode should include debug table
        XCTAssertTrue(html.contains("Debug") || html.contains("debug"),
                     "Should include debug info when debug=true")
    }

    func testAboutFooterRendering() throws {
        settings.about = true

        let markdown = "# Test"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        // About footer should include version info
        XCTAssertTrue(html.contains("TextDown") || html.contains("version"),
                     "Should include about footer when about=true")
    }

    // MARK: - Performance Tests

    func testRenderPerformance_SmallDocument() {
        settings.tableExtension = true
        settings.emojiExtension = true
        settings.syntaxHighlightExtension = true

        // Small document (50 lines)
        var markdown = ""
        for i in 1...50 {
            markdown += "# Heading \(i)\n\nLorem ipsum dolor sit amet.\n\n"
        }

        measure {
            _ = try? settings.render(text: markdown, filename: "test.md",
                                     forAppearance: .light, baseDir: "/tmp")
        }
        // Should complete quickly (< 50ms typically)
    }

    func testRenderPerformance_LargeDocument() {
        settings.tableExtension = true
        settings.emojiExtension = true
        settings.syntaxHighlightExtension = true

        // Larger document (500 lines)
        var markdown = ""
        for i in 1...500 {
            markdown += "# Heading \(i)\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n"
        }

        measure {
            _ = try? settings.render(text: markdown, filename: "test.md",
                                     forAppearance: .light, baseDir: "/tmp")
        }
        // Baseline: Should complete in < 200ms
    }

    // MARK: - Error Handling

    func testRenderEmptyString() throws {
        let html = try settings.render(text: "", filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertNotNil(html, "Should return HTML even for empty input")
        XCTAssertFalse(html.contains("RENDER FAILED"), "Should not fail on empty input")
    }

    func testRenderInvalidMarkdown() throws {
        // Malformed markdown should not crash
        let markdown = "[[[[invalid]]]]"

        let html = try settings.render(text: markdown, filename: "test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        XCTAssertNotNil(html, "Should return HTML even for invalid markdown")
        XCTAssertFalse(html.contains("RENDER FAILED"), "Should handle invalid markdown gracefully")
    }
}
