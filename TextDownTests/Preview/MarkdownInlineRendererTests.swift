//
//  MarkdownInlineRendererTests.swift
//  TextDownTests2
//
//  Unit tests for MarkdownInlineRenderer
//

import XCTest
import Markdown
@testable import TextDown

final class MarkdownInlineRendererTests: XCTestCase {

    // MARK: - Plain Text Tests

    func testRenderPlainText() {
        let markdown = "Simple plain text"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertEqual(String(result.characters), "Simple plain text")
    }

    // MARK: - Bold Text Tests

    func testRenderBoldText() {
        let markdown = "This is **bold** text"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("bold"), "Should contain bold text")
    }

    // MARK: - Italic Text Tests

    func testRenderItalicText() {
        let markdown = "This is *italic* text"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("italic"), "Should contain italic text")
    }

    // MARK: - Inline Code Tests

    func testRenderInlineCode() {
        let markdown = "Use `code` in markdown"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("code"), "Should contain code text")
    }

    // MARK: - Link Tests

    func testRenderLink() {
        let markdown = "Visit [GitHub](https://github.com)"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("GitHub"), "Should contain link text")
    }

    // MARK: - Strikethrough Tests

    func testRenderStrikethrough() {
        let markdown = "This is ~~deleted~~ text"
        let document = Document(parsing: markdown, options: [])

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("deleted"), "Should contain strikethrough text")
    }

    // MARK: - Mixed Formatting Tests

    func testRenderMixedFormatting() {
        let markdown = "This has **bold**, *italic*, and `code` together"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        let text = String(result.characters)
        XCTAssertTrue(text.contains("bold"), "Should contain bold text")
        XCTAssertTrue(text.contains("italic"), "Should contain italic text")
        XCTAssertTrue(text.contains("code"), "Should contain code text")
    }

    // MARK: - Nested Formatting Tests

    func testRenderNestedFormatting() {
        let markdown = "This is ***bold and italic*** text"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertTrue(String(result.characters).contains("bold and italic"), "Should handle nested formatting")
    }

    // MARK: - Empty Content Tests

    func testRenderEmptyParagraph() {
        let markdown = ""
        let document = Document(parsing: markdown)

        // Empty markdown creates empty document
        if document.childCount == 0 {
            // This is expected for truly empty content
            return
        }

        guard let paragraph = document.children.first as? Paragraph else {
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        XCTAssertEqual(result.characters.count, 0, "Empty paragraph should produce empty result")
    }

    // MARK: - Complex Inline Tests

    func testRenderComplexInlineContent() {
        let markdown = "Check out [this **bold link**](https://example.com) and `some code` with ~~strikethrough~~"
        let document = Document(parsing: markdown)

        guard let paragraph = document.children.first as? Paragraph else {
            XCTFail("Expected paragraph")
            return
        }

        let result = MarkdownInlineRenderer.render(paragraph)

        let text = String(result.characters)
        XCTAssertTrue(text.contains("this"), "Should contain text")
        XCTAssertTrue(text.contains("bold link"), "Should contain bold link text")
        XCTAssertTrue(text.contains("some code"), "Should contain code")
        XCTAssertTrue(text.contains("strikethrough"), "Should contain strikethrough")
    }
}
