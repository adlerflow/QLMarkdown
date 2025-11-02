//
//  SnapshotTests.swift
//  TextDownTests
//
//  Created by Claude Code on 2025-11-02.
//  Phase 0: Test Suite Creation - HTML Snapshot Regression Tests
//

import XCTest
@testable import TextDown

final class SnapshotTests: XCTestCase {
    var settings: Settings!
    let snapshotsDir = FileManager.default.temporaryDirectory.appendingPathComponent("textdown-snapshots")

    override func setUp() {
        super.setUp()
        settings = Settings.factorySettings
        try? FileManager.default.createDirectory(at: snapshotsDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        // Keep snapshots for comparison (don't delete)
        settings = nil
        super.tearDown()
    }

    // MARK: - Comprehensive Snapshot Test

    func testRenderSnapshot_AllExtensions() throws {
        let markdown = """
        # TextDown Comprehensive Test Document

        This document tests all markdown extensions and rendering features.

        ## Table Extension

        | Feature | Status | Notes |
        |---------|--------|-------|
        | Tables  | ✓      | GFM table syntax |
        | Alignment | ✓   | Left, center, right |
        | Complex | ✓      | Multi-line cells |

        ## List Features

        ### Unordered Lists
        - Item 1
        - Item 2
          - Nested item 2.1
          - Nested item 2.2
        - Item 3

        ### Ordered Lists
        1. First item
        2. Second item
        3. Third item

        ### Task Lists
        - [ ] Unchecked task
        - [x] Checked task
        - [ ] Another unchecked task

        ## Code Blocks

        ### Python Code
        ```python
        def hello_world():
            print("Hello, World!")
            return 42
        ```

        ### JavaScript Code
        ```javascript
        const greeting = (name) => {
            console.log(`Hello, ${name}!`);
        };
        ```

        ### Inline Code
        Use `print()` for output in Python.

        ## Emoji Support

        :smile: :heart: :rocket: :star: :fire:

        ## Math Support

        ### Inline Math
        The formula $E=mc^2$ is Einstein's famous equation.

        ### Display Math
        $$
        \\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}
        $$

        ### Complex Math
        $$
        \\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}
        $$

        ## Text Formatting

        ### Strikethrough
        This is ~~deleted text~~ that was removed.

        ### Highlight
        This is ==highlighted text== for emphasis.

        ### Subscript and Superscript
        Chemical formula: H~2~O

        Mathematical notation: x^2^ + y^2^ = z^2^

        ## Links and Images

        ### Auto-link
        Visit https://github.com for the source code.

        ### Standard Link
        [GitHub](https://github.com)

        ### Reference Link
        Check out [TextDown][1] for more info.

        [1]: https://example.com

        ## Blockquotes

        > This is a blockquote.
        >
        > It can span multiple lines.
        > > And can be nested.

        ## Horizontal Rule

        ---

        ## Smart Quotes

        "Hello world" and 'single quotes' should be smart.

        ## Footnotes

        This text has a footnote.[^1]

        [^1]: This is the footnote content with more details.

        ## HTML Content

        <div class="custom-div">
        This is raw HTML content.
        </div>

        ## Final Notes

        This document exercises all major markdown features to establish a baseline snapshot for regression testing.
        """

        // Enable all extensions
        settings.tableExtension = true
        settings.autoLinkExtension = true
        settings.tagFilterExtension = true
        settings.taskListExtension = true
        settings.yamlExtension = true
        settings.strikethroughExtension = true
        settings.mentionExtension = false  // Not used in this test
        settings.headsExtension = true
        settings.highlightExtension = true
        settings.subExtension = true
        settings.supExtension = true
        settings.emojiExtension = true
        settings.emojiImageOption = false  // Unicode mode
        settings.mathExtension = true
        settings.syntaxHighlightExtension = true

        // Parser options
        settings.footnotesOption = true
        settings.smartQuotesOption = true
        settings.unsafeHTMLOption = true  // Allow raw HTML

        // Appearance options
        settings.debug = false
        settings.about = false

        // Render markdown
        let html = try settings.render(text: markdown, filename: "snapshot_test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Snapshot Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        // Save baseline snapshot
        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_all_extensions.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Snapshot saved to: \(snapshotFile.path)")

        // Verify snapshot contains expected elements
        XCTAssertTrue(completeHTML.contains("<!doctype html>"), "Should have DOCTYPE")
        XCTAssertTrue(completeHTML.contains("<table"), "Should contain table")
        XCTAssertTrue(completeHTML.contains("<code"), "Should contain code blocks")
        XCTAssertTrue(completeHTML.contains("😄") || completeHTML.contains("smile"), "Should contain emoji")
        XCTAssertTrue(completeHTML.contains("$E=mc^2$"), "Should contain math")
        XCTAssertTrue(completeHTML.contains("<del>"), "Should contain strikethrough")

        // For future comparison:
        // let currentHTML = try settings.render(...)
        // XCTAssertEqual(currentHTML, try String(contentsOf: snapshotFile))
    }

    func testRenderSnapshot_MinimalExtensions() throws {
        let markdown = """
        # Minimal Test Document

        This is a simple document with minimal extensions enabled.

        ## Plain Markdown

        Just plain text with **bold** and *italic* formatting.

        ### Code
        ```
        plain code block
        ```

        That's it!
        """

        // Minimal extensions
        settings.tableExtension = false
        settings.autoLinkExtension = false
        settings.emojiExtension = false
        settings.mathExtension = false
        settings.syntaxHighlightExtension = false
        settings.strikethroughExtension = false
        settings.headsExtension = false

        let html = try settings.render(text: markdown, filename: "minimal_test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Minimal Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_minimal.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Minimal snapshot saved to: \(snapshotFile.path)")

        XCTAssertTrue(completeHTML.contains("<h1>"), "Should contain h1 heading")
        XCTAssertTrue(completeHTML.contains("<strong>"), "Should contain bold")
        XCTAssertTrue(completeHTML.contains("<em>"), "Should contain italic")
    }

    func testRenderSnapshot_LightTheme() throws {
        let markdown = """
        # Theme Test Document

        ```python
        def hello():
            print("Testing light theme")
        ```
        """

        settings.syntaxHighlightExtension = true
        settings.syntaxThemeLightOption = "github"

        let html = try settings.render(text: markdown, filename: "theme_test.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Light Theme Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_light_theme.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Light theme snapshot saved to: \(snapshotFile.path)")

        XCTAssertTrue(completeHTML.contains("github") || completeHTML.contains("hljs"),
                     "Should include GitHub theme")
    }

    func testRenderSnapshot_DarkTheme() throws {
        let markdown = """
        # Dark Theme Test Document

        ```javascript
        console.log("Testing dark theme");
        ```
        """

        settings.syntaxHighlightExtension = true
        settings.syntaxThemeDarkOption = "github-dark"

        let html = try settings.render(text: markdown, filename: "theme_test.md",
                                       forAppearance: .dark, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Dark Theme Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .dark
        )

        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_dark_theme.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Dark theme snapshot saved to: \(snapshotFile.path)")

        XCTAssertTrue(completeHTML.contains("github-dark") || completeHTML.contains("hljs"),
                     "Should include GitHub dark theme")
    }

    // MARK: - Snapshot Comparison Utilities

    func testSnapshotDirectory() {
        // Verify snapshots directory exists
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: snapshotsDir.path, isDirectory: &isDirectory)

        XCTAssertTrue(exists, "Snapshots directory should exist")
        XCTAssertTrue(isDirectory.boolValue, "Snapshots path should be a directory")

        // List all snapshot files
        let files = try? FileManager.default.contentsOfDirectory(at: snapshotsDir,
                                                                 includingPropertiesForKeys: nil)

        if let files = files {
            print("\n📸 Snapshot files created:")
            for file in files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                let fileSize = try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int
                print("  - \(file.lastPathComponent) (\(fileSize ?? 0) bytes)")
            }
        }
    }

    // MARK: - Extension Combination Tests

    func testRenderSnapshot_TableAndMath() throws {
        let markdown = """
        # Table and Math Combination

        | Formula | Result |
        |---------|--------|
        | $x^2$   | Square |
        | $\\sqrt{x}$ | Root |

        Inline: The equation $E=mc^2$ appears in the table.
        """

        settings.tableExtension = true
        settings.mathExtension = true

        let html = try settings.render(text: markdown, filename: "table_math.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Table + Math Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_table_math.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Table+Math snapshot saved to: \(snapshotFile.path)")

        XCTAssertTrue(completeHTML.contains("<table"), "Should contain table")
        XCTAssertTrue(completeHTML.contains("$E=mc^2$") || completeHTML.contains("E=mc"),
                     "Should contain math")
        XCTAssertTrue(completeHTML.contains("MathJax"), "Should include MathJax script")
    }

    func testRenderSnapshot_EmojiInCode() throws {
        let markdown = """
        # Emoji in Code Blocks

        Regular emoji: :smile: :rocket:

        Code block with emoji reference:
        ```python
        # Print emoji
        print(":smile:")  # This should NOT be converted
        ```
        """

        settings.emojiExtension = true
        settings.emojiImageOption = false
        settings.syntaxHighlightExtension = true

        let html = try settings.render(text: markdown, filename: "emoji_code.md",
                                       forAppearance: .light, baseDir: "/tmp")

        let completeHTML = settings.getCompleteHTML(
            title: "Emoji + Code Test",
            body: html,
            basedir: URL(fileURLWithPath: "/tmp"),
            forAppearance: .light
        )

        let snapshotFile = snapshotsDir.appendingPathComponent("baseline_emoji_code.html")
        try completeHTML.write(to: snapshotFile, atomically: true, encoding: .utf8)

        print("✅ Emoji+Code snapshot saved to: \(snapshotFile.path)")

        // Regular text emoji should be converted
        XCTAssertTrue(completeHTML.contains("😄") || completeHTML.contains("🚀"),
                     "Should contain emoji in regular text")
    }

    // MARK: - Performance Baseline

    func testSnapshotRenderPerformance() {
        // Create a realistic document for performance baseline
        var markdown = """
        # Performance Test Document

        """

        for i in 1...100 {
            markdown += """
            ## Section \(i)

            | Column A | Column B | Column C |
            |----------|----------|----------|
            | Data \(i*1) | Data \(i*2) | Data \(i*3) |

            Some text with :smile: emoji and $x^2$ math.

            ```python
            def function_\(i)():
                return \(i)
            ```


            """
        }

        settings.tableExtension = true
        settings.emojiExtension = true
        settings.mathExtension = true
        settings.syntaxHighlightExtension = true

        measure {
            _ = try? settings.render(text: markdown, filename: "perf_test.md",
                                     forAppearance: .light, baseDir: "/tmp")
        }

        // This establishes the performance baseline
        // After migration, re-run this test to ensure no regression
    }
}
