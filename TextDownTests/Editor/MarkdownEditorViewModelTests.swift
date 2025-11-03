//
//  MarkdownEditorViewModelTests.swift
//  TextDownTests2
//
//  Unit tests for MarkdownEditorViewModel
//

import XCTest
import Markdown
@testable import TextDown

@MainActor
final class MarkdownEditorViewModelTests: XCTestCase {

    var viewModel: MarkdownEditorViewModel!

    override func setUp() async throws {
        viewModel = MarkdownEditorViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
    }

    // MARK: - Rendering Tests

    func testRenderCreatesDocument() {
        let markdown = "# Hello World\n\nThis is a test."

        viewModel.render(content: markdown, parseOptions: [])

        XCTAssertNotNil(viewModel.renderedDocument, "Should create rendered document")
    }

    func testRenderWithEmptyString() {
        viewModel.render(content: "", parseOptions: [])

        XCTAssertNotNil(viewModel.renderedDocument, "Should handle empty string")
        XCTAssertEqual(viewModel.renderedDocument?.childCount, 0, "Empty markdown should have no children")
    }

    func testRenderWithHeading() {
        let markdown = "# Heading Level 1"

        viewModel.render(content: markdown, parseOptions: [])

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 0, "Should parse heading")

        if let heading = document.children.first as? Heading {
            XCTAssertEqual(heading.level, 1, "Should be level 1 heading")
            XCTAssertEqual(heading.plainText, "Heading Level 1")
        } else {
            XCTFail("First child should be a Heading")
        }
    }

    func testRenderWithParagraph() {
        let markdown = "This is a simple paragraph."

        viewModel.render(content: markdown, parseOptions: [])

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 0, "Should parse paragraph")

        if let paragraph = document.children.first as? Paragraph {
            XCTAssertEqual(paragraph.plainText, "This is a simple paragraph.")
        } else {
            XCTFail("First child should be a Paragraph")
        }
    }

    func testRenderWithCodeBlock() {
        let markdown = """
        ```swift
        let x = 42
        ```
        """

        viewModel.render(content: markdown, parseOptions: [])

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 0, "Should parse code block")

        if let codeBlock = document.children.first as? CodeBlock {
            XCTAssertEqual(codeBlock.language, "swift")
            XCTAssertTrue(codeBlock.code.contains("let x = 42"))
        } else {
            XCTFail("First child should be a CodeBlock")
        }
    }

    // MARK: - Debouncing Tests

    func testDebounceRenderWithAutoRefreshDisabled() async {
        let markdown = "# Test"

        viewModel.debounceRender(
            content: markdown,
            autoRefresh: false,
            parseOptions: []
        )

        // Wait a bit
        try? await Task.sleep(for: .milliseconds(600))

        XCTAssertNil(viewModel.renderedDocument, "Should not render when autoRefresh is disabled")
    }

    func testDebounceRenderWithAutoRefreshEnabled() async {
        let markdown = "# Test Heading"

        viewModel.debounceRender(
            content: markdown,
            autoRefresh: true,
            parseOptions: []
        )

        // Wait for debounce to complete (500ms + buffer)
        try? await Task.sleep(for: .milliseconds(600))

        XCTAssertNotNil(viewModel.renderedDocument, "Should render after debounce delay")
    }

    func testDebounceRenderCancellation() async {
        let markdown1 = "# First"
        let markdown2 = "# Second"

        // Start first debounce
        viewModel.debounceRender(
            content: markdown1,
            autoRefresh: true,
            parseOptions: []
        )

        // Wait a bit but not enough to complete
        try? await Task.sleep(for: .milliseconds(200))

        // Start second debounce (should cancel first)
        viewModel.debounceRender(
            content: markdown2,
            autoRefresh: true,
            parseOptions: []
        )

        // Wait for second debounce to complete
        try? await Task.sleep(for: .milliseconds(600))

        // Should have rendered the second content
        if let heading = viewModel.renderedDocument?.children.first as? Heading {
            XCTAssertEqual(heading.plainText, "Second", "Should render the second content (first was cancelled)")
        } else {
            XCTFail("Should have rendered a heading")
        }
    }

    // MARK: - Force Render Tests

    func testForceRenderImmediateExecution() {
        let markdown = "# Immediate"

        viewModel.forceRender(content: markdown, parseOptions: [])

        XCTAssertNotNil(viewModel.renderedDocument, "Force render should execute immediately")

        if let heading = viewModel.renderedDocument?.children.first as? Heading {
            XCTAssertEqual(heading.plainText, "Immediate")
        }
    }

    func testForceRenderCancelsDebounce() async {
        let markdown1 = "# Debounced"
        let markdown2 = "# Forced"

        // Start debounce
        viewModel.debounceRender(
            content: markdown1,
            autoRefresh: true,
            parseOptions: []
        )

        // Immediately force render
        viewModel.forceRender(content: markdown2, parseOptions: [])

        // Wait to ensure debounce would have completed
        try? await Task.sleep(for: .milliseconds(600))

        // Should have the forced content
        if let heading = viewModel.renderedDocument?.children.first as? Heading {
            XCTAssertEqual(heading.plainText, "Forced", "Force render should override debounce")
        } else {
            XCTFail("Should have rendered a heading")
        }
    }

    // MARK: - Parse Options Tests

    func testCreateParseOptionsReturnsEmptyOptions() {
        let appState = AppState(loadFromDisk: false)

        let options = viewModel.createParseOptions(from: appState)

        // Currently returns empty options (swift-markdown limitation)
        XCTAssertTrue(options.isEmpty, "Should return empty options (swift-markdown 0.5.0 limitation)")
    }

    // MARK: - Complex Markdown Tests

    func testRenderComplexDocument() {
        let markdown = """
        # Main Heading

        This is a paragraph with **bold** and *italic* text.

        ## Subheading

        - List item 1
        - List item 2

        ```python
        def hello():
            print("Hello, World!")
        ```

        > A quote block
        """

        viewModel.render(content: markdown, parseOptions: [])

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 5, "Should parse multiple elements")
    }
}
