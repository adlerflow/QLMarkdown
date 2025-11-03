//
//  RenderingTests.swift
//  TextDownTests2
//
//  Created by Claude Code on 2025-11-03.
//  Test suite for markdown rendering pipeline
//

import XCTest
@testable import TextDown
import SwiftSoup

final class RenderingTests: XCTestCase {
    var settings: AppConfiguration!
    var renderer: MarkdownRenderer!

    override func setUp() {
        super.setUp()
        // Use factory settings for consistent test environment
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try! encoder.encode(AppConfiguration.factorySettings)
        settings = try! decoder.decode(AppConfiguration.self, from: data)
        renderer = MarkdownRenderer(settings: settings)
    }

    override func tearDown() {
        renderer = nil
        settings = nil
        super.tearDown()
    }

    // MARK: - Long Document Tests (Regression for 20578-char bug)

    func testLongDocumentNotTruncated() throws {
        // Generate a markdown document with >25,000 characters
        var markdown = "# Long Document Test\n\n"
        markdown += "This test verifies that long documents are not truncated at 20578 characters.\n\n"

        // Add 500 paragraphs with more content to reach >25K
        for i in 1...500 {
            markdown += "Paragraph \(i): Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\n"
        }

        let markdownLength = markdown.count
        XCTAssertGreaterThan(markdownLength, 25000, "Test markdown should be >25K chars (got \(markdownLength))")

        // Render to HTML
        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Verify HTML is complete (should be much larger than markdown due to CSS/JS)
        XCTAssertGreaterThan(html.count, markdownLength, "HTML should be larger than markdown")

        // Verify HTML structure is valid
        XCTAssertTrue(html.contains("<!doctype html>"), "HTML should have doctype")
        XCTAssertTrue(html.contains("</html>"), "HTML should have closing html tag")
        XCTAssertTrue(html.contains("</body>"), "HTML should have closing body tag")
        XCTAssertTrue(html.contains("</head>"), "HTML should have closing head tag")

        // Verify article wrapper exists
        XCTAssertTrue(html.contains("<article class='markdown-body'>"), "HTML should have article wrapper")
        XCTAssertTrue(html.contains("</article>"), "HTML should close article wrapper")

        // Verify content is present (check for first and last paragraph)
        XCTAssertTrue(html.contains("Paragraph 1:"), "HTML should contain first paragraph")
        XCTAssertTrue(html.contains("Paragraph 500:"), "HTML should contain last paragraph")
    }

    func testLongDocumentHTMLValidity() throws {
        // Generate long document with various markdown features
        var markdown = """
        # Test Document with 25K+ Characters

        ## Introduction
        This document tests HTML validity for long content with multiple sections, code blocks, and tables.
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

        """

        // Add code blocks with more content
        for i in 1...50 {
            markdown += """
            ### Section \(i)

            Here is some text with **bold** and *italic* formatting. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
            Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

            ```python
            def function_\(i)():
                # This is function number \(i)
                print("Processing item number \(i)")
                result = \(i) * 2
                return result
            ```

            Additional paragraph with more content to increase the character count significantly.

            """
        }

        // Add tables with more columns and rows
        for i in 1...30 {
            markdown += """
            #### Table \(i)

            | Column A | Column B | Column C | Column D |
            |----------|----------|----------|----------|
            | Row \(i)A | Row \(i)B | Row \(i)C | Row \(i)D |
            | Data \(i*2)A | Data \(i*2)B | Data \(i*2)C | Data \(i*2)D |

            """
        }

        XCTAssertGreaterThan(markdown.count, 25000, "Markdown should exceed 25K chars (got \(markdown.count))")

        // Render
        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Parse HTML with SwiftSoup to verify validity
        let doc = try SwiftSoup.parse(html)

        // Verify document structure
        XCTAssertNotNil(doc.head(), "HTML should have <head>")
        XCTAssertNotNil(doc.body(), "HTML should have <body>")

        // Verify content elements exist
        let headings = try doc.select("h2, h3, h4")
        XCTAssertGreaterThan(headings.count, 70, "Should have >70 headings (got \(headings.count))")

        let codeBlocks = try doc.select("pre code")
        XCTAssertGreaterThan(codeBlocks.count, 40, "Should have >40 code blocks (got \(codeBlocks.count))")

        let tables = try doc.select("table")
        XCTAssertGreaterThan(tables.count, 25, "Should have >25 tables (got \(tables.count))")
    }

    func testVeryLongSingleParagraph() throws {
        // Test with one VERY long paragraph (no line breaks)
        let longText = String(repeating: "A", count: 30000)
        let markdown = "# Test\n\n\(longText)\n"

        XCTAssertEqual(longText.count, 30000, "Test text should be exactly 30K chars")

        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Verify the long text is present in HTML
        XCTAssertTrue(html.contains(longText), "HTML should contain the 30K character paragraph")

        // Verify HTML is valid
        let doc = try SwiftSoup.parse(html)
        let paragraphs = try doc.select("p")

        // Should have at least one paragraph with the long text
        var foundLongParagraph = false
        for p in paragraphs {
            if try p.text().count > 25000 {
                foundLongParagraph = true
                break
            }
        }
        XCTAssertTrue(foundLongParagraph, "Should find paragraph with >25K chars")
    }

    // MARK: - HTML Structure Tests

    func testArticleWrapperPresent() throws {
        let markdown = "# Test\n\nSome content."
        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Verify article wrapper for max-width styling
        XCTAssertTrue(html.contains("<article class='markdown-body'>"), "Should have opening article tag")
        XCTAssertTrue(html.contains("</article>"), "Should have closing article tag")

        // Verify article is between body tags
        let bodyStart = html.range(of: "<body>")
        let bodyEnd = html.range(of: "</body>")
        let articleStart = html.range(of: "<article")
        let articleEnd = html.range(of: "</article>")

        XCTAssertNotNil(bodyStart, "Should have opening body tag")
        XCTAssertNotNil(bodyEnd, "Should have closing body tag")
        XCTAssertNotNil(articleStart, "Should have opening article tag")
        XCTAssertNotNil(articleEnd, "Should have closing article tag")

        if let bodyStartRange = bodyStart,
           let bodyEndRange = bodyEnd,
           let articleStartRange = articleStart,
           let articleEndRange = articleEnd {
            XCTAssertLessThan(bodyStartRange.lowerBound, articleStartRange.lowerBound, "article should be inside body")
            XCTAssertGreaterThan(bodyEndRange.lowerBound, articleEndRange.lowerBound, "article should be inside body")
        }
    }

    func testHTMLStructureIntegrity() throws {
        let markdown = """
        # Heading 1
        ## Heading 2

        Paragraph with **bold** and *italic*.

        ```python
        print("code")
        ```

        - List item 1
        - List item 2
        """

        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Parse with SwiftSoup
        let doc = try SwiftSoup.parse(html)

        // Verify structure
        XCTAssertEqual(try doc.select("h1").size(), 1, "Should have 1 h1")
        XCTAssertEqual(try doc.select("h2").size(), 1, "Should have 1 h2")
        XCTAssertEqual(try doc.select("strong").size(), 1, "Should have 1 bold")
        XCTAssertEqual(try doc.select("em").size(), 1, "Should have 1 italic")
        XCTAssertGreaterThanOrEqual(try doc.select("pre code").size(), 1, "Should have code block")
        XCTAssertEqual(try doc.select("ul").size(), 1, "Should have 1 list")
        XCTAssertEqual(try doc.select("li").size(), 2, "Should have 2 list items")
    }

    // MARK: - SwiftSoup Integration Tests

    func testSwiftSoupParsesLongHTML() throws {
        // Test that SwiftSoup doesn't truncate long HTML
        var markdown = "# Test\n\n"
        for i in 1...1000 {
            markdown += "Paragraph \(i) with some content.\n\n"
        }

        let baseDirectory = FileManager.default.temporaryDirectory
        let html = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        // Parse with SwiftSoup
        let doc = try SwiftSoup.parse(html)
        let paragraphs = try doc.select("p")

        // Should have ~1000 paragraphs
        XCTAssertGreaterThan(paragraphs.size(), 900, "Should parse >900 paragraphs")

        // Verify first and last paragraph exist
        let firstP = paragraphs.first()
        let lastP = paragraphs.last()

        XCTAssertTrue(try firstP?.text().contains("Paragraph 1") ?? false, "First paragraph should exist")
        XCTAssertTrue(try lastP?.text().contains("Paragraph 1000") ?? false, "Last paragraph should exist")
    }

    // MARK: - Appearance Tests

    func testLightAndDarkAppearance() throws {
        let markdown = "# Test\n\nContent with ```python\ncode\n```"
        let baseDirectory = FileManager.default.temporaryDirectory

        let lightHTML = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .light
        )

        let darkHTML = try renderer.render(
            markdown: markdown,
            filename: "test.md",
            baseDirectory: baseDirectory,
            appearance: .dark
        )

        // Both should be valid HTML
        XCTAssertTrue(lightHTML.contains("<!doctype html>"), "Light HTML should have doctype")
        XCTAssertTrue(darkHTML.contains("<!doctype html>"), "Dark HTML should have doctype")

        // Both should have CSS (inline styles injected)
        XCTAssertTrue(lightHTML.contains("<style>"), "Light HTML should have CSS")
        XCTAssertTrue(darkHTML.contains("<style>"), "Dark HTML should have CSS")

        // Both should be different (different theme CSS)
        XCTAssertNotEqual(lightHTML, darkHTML, "Light and dark HTML should differ")

        // Verify both contain the content
        XCTAssertTrue(lightHTML.contains("<h1"), "Light HTML should contain heading")
        XCTAssertTrue(darkHTML.contains("<h1"), "Dark HTML should contain heading")
    }

    // MARK: - Performance Tests

    func testRenderingPerformance() throws {
        // Generate 10K character document
        var markdown = "# Performance Test\n\n"
        for i in 1...200 {
            markdown += "## Section \(i)\n\nLorem ipsum dolor sit amet.\n\n"
        }

        let baseDirectory = FileManager.default.temporaryDirectory

        // Measure rendering time
        measure {
            _ = try? renderer.render(
                markdown: markdown,
                filename: "test.md",
                baseDirectory: baseDirectory,
                appearance: .light
            )
        }
    }
}
