//
//  MarkdownEditorViewModelTests.swift
//  TextDownTests2
//
//  Unit tests for MarkdownEditorViewModel (Clean Architecture)
//

import XCTest
import Markdown
@testable import TextDown

@MainActor
final class MarkdownEditorViewModelTests: XCTestCase {

    var viewModel: MarkdownEditorViewModel!
    var settingsViewModel: SettingsViewModel!
    var parseUseCase: ParseMarkdownUseCase!
    var tempDirectory: URL!

    override func setUp() async throws {
        // Create temporary directory for test settings
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let tempSettingsURL = tempDirectory.appendingPathComponent("test_settings.json")

        // Create dependencies
        let settingsRepo = SettingsRepositoryImpl(settingsURL: tempSettingsURL)
        let parserRepo = MarkdownParserRepositoryImpl()
        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
        let validateUseCase = ValidateSettingsUseCase()

        settingsViewModel = SettingsViewModel(
            loadSettingsUseCase: loadUseCase,
            saveSettingsUseCase: saveUseCase,
            validateSettingsUseCase: validateUseCase
        )

        parseUseCase = ParseMarkdownUseCase(parserRepository: parserRepo)

        viewModel = MarkdownEditorViewModel(
            parseMarkdownUseCase: parseUseCase,
            settingsViewModel: settingsViewModel
        )

        // Wait for settings to load
        try? await Task.sleep(for: .milliseconds(100))
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        viewModel = nil
        settingsViewModel = nil
        parseUseCase = nil
        tempDirectory = nil
    }

    // MARK: - Rendering Tests

    func testRenderCreatesDocument() async {
        let markdown = "# Hello World\n\nThis is a test."

        await viewModel.render(content: markdown)

        XCTAssertNotNil(viewModel.renderedDocument, "Should create rendered document")
    }

    func testRenderWithEmptyString() async {
        await viewModel.render(content: "")

        XCTAssertNotNil(viewModel.renderedDocument, "Should handle empty string")
        XCTAssertEqual(viewModel.renderedDocument?.childCount, 0, "Empty markdown should have no children")
    }

    func testRenderWithHeading() async {
        let markdown = "# Heading Level 1"

        await viewModel.render(content: markdown)

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 0, "Should parse heading")

        if let heading = document.children.first as? Heading {
            XCTAssertEqual(heading.level, 1, "Should be level 1 heading")
            XCTAssertEqual(heading.plainText, "Heading Level 1")
        } else {
            XCTFail("First child should be a Heading")
        }
    }

    func testRenderWithParagraph() async {
        let markdown = "This is a simple paragraph."

        await viewModel.render(content: markdown)

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 0, "Should parse paragraph")

        if let paragraph = document.children.first as? Paragraph {
            XCTAssertEqual(paragraph.plainText, "This is a simple paragraph.")
        } else {
            XCTFail("First child should be a Paragraph")
        }
    }

    func testRenderWithCodeBlock() async {
        let markdown = """
        ```swift
        let x = 42
        ```
        """

        await viewModel.render(content: markdown)

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
        // Disable auto-refresh
        settingsViewModel.settings.editor.autoRefresh = false

        let markdown = "# Test"

        viewModel.debounceRender(content: markdown)

        // Wait for debounce delay
        try? await Task.sleep(for: .milliseconds(600))

        XCTAssertNil(viewModel.renderedDocument, "Should not render when autoRefresh is disabled")
    }

    func testDebounceRenderWithAutoRefreshEnabled() async {
        // Enable auto-refresh
        settingsViewModel.settings.editor.autoRefresh = true

        let markdown = "# Test Heading"

        viewModel.debounceRender(content: markdown)

        // Wait for debounce to complete (500ms + buffer)
        try? await Task.sleep(for: .milliseconds(600))

        XCTAssertNotNil(viewModel.renderedDocument, "Should render after debounce delay")
    }

    func testDebounceRenderCancellation() async {
        // Enable auto-refresh
        settingsViewModel.settings.editor.autoRefresh = true

        let markdown1 = "# First"
        let markdown2 = "# Second"

        // Start first debounce
        viewModel.debounceRender(content: markdown1)

        // Wait a bit but not enough to complete
        try? await Task.sleep(for: .milliseconds(200))

        // Start second debounce (should cancel first)
        viewModel.debounceRender(content: markdown2)

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

    func testForceRenderImmediateExecution() async {
        let markdown = "# Immediate"

        viewModel.forceRender(content: markdown)

        // Wait a moment for async render to complete
        try? await Task.sleep(for: .milliseconds(100))

        XCTAssertNotNil(viewModel.renderedDocument, "Force render should execute immediately")

        if let heading = viewModel.renderedDocument?.children.first as? Heading {
            XCTAssertEqual(heading.plainText, "Immediate")
        }
    }

    func testForceRenderCancelsDebounce() async {
        // Enable auto-refresh
        settingsViewModel.settings.editor.autoRefresh = true

        let markdown1 = "# Debounced"
        let markdown2 = "# Forced"

        // Start debounce
        viewModel.debounceRender(content: markdown1)

        // Immediately force render
        viewModel.forceRender(content: markdown2)

        // Wait to ensure debounce would have completed
        try? await Task.sleep(for: .milliseconds(600))

        // Should have the forced content
        if let heading = viewModel.renderedDocument?.children.first as? Heading {
            XCTAssertEqual(heading.plainText, "Forced", "Force render should override debounce")
        } else {
            XCTFail("Should have rendered a heading")
        }
    }

    func testForceRenderTriggersRefreshUUID() {
        let originalTrigger = viewModel.refreshTrigger

        viewModel.forceRender(content: "# Test")

        XCTAssertNotEqual(viewModel.refreshTrigger, originalTrigger, "Force render should update refresh trigger")
    }

    // MARK: - Settings Integration Tests

    func testRenderUsesMarkdownSettings() async {
        // Modify markdown settings
        settingsViewModel.settings.markdown.enableTable = true
        settingsViewModel.settings.markdown.enableAutolink = true

        let markdown = "# Test"
        await viewModel.render(content: markdown)

        XCTAssertNotNil(viewModel.renderedDocument, "Should render with settings")
    }

    func testAutoRefreshSettingControlsDebounce() async {
        let markdown = "# Test"

        // Test with autoRefresh enabled
        settingsViewModel.settings.editor.autoRefresh = true
        viewModel.debounceRender(content: markdown)
        try? await Task.sleep(for: .milliseconds(600))
        XCTAssertNotNil(viewModel.renderedDocument, "Should render when autoRefresh is enabled")

        // Clear document
        viewModel.renderedDocument = nil

        // Test with autoRefresh disabled
        settingsViewModel.settings.editor.autoRefresh = false
        viewModel.debounceRender(content: markdown)
        try? await Task.sleep(for: .milliseconds(600))
        XCTAssertNil(viewModel.renderedDocument, "Should not render when autoRefresh is disabled")
    }

    // MARK: - Complex Markdown Tests

    func testRenderComplexDocument() async {
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

        await viewModel.render(content: markdown)

        let document = viewModel.renderedDocument!
        XCTAssertGreaterThan(document.childCount, 5, "Should parse multiple elements")
    }

    func testRenderWithGFMFeatures() async {
        // Enable GFM features
        settingsViewModel.settings.markdown.enableTable = true
        settingsViewModel.settings.markdown.enableStrikethrough = true
        settingsViewModel.settings.markdown.enableAutolink = true

        let markdown = """
        | Column 1 | Column 2 |
        |----------|----------|
        | Cell 1   | Cell 2   |

        ~~strikethrough~~

        https://example.com
        """

        await viewModel.render(content: markdown)

        XCTAssertNotNil(viewModel.renderedDocument, "Should render GFM features")
    }

    // MARK: - Error Handling Tests

    func testRenderHandlesInvalidMarkdown() async {
        // Swift-markdown is resilient and parses almost anything
        // But we can test that it doesn't crash
        let invalidMarkdown = String(repeating: "#", count: 1000)

        await viewModel.render(content: invalidMarkdown)

        // Should not crash
        XCTAssertNotNil(viewModel.renderedDocument, "Should handle edge cases gracefully")
    }

    func testRenderHandlesLargeDocument() async {
        // Create a large document
        let largeMarkdown = String(repeating: "# Heading\n\nParagraph text.\n\n", count: 100)

        await viewModel.render(content: largeMarkdown)

        XCTAssertNotNil(viewModel.renderedDocument, "Should handle large documents")
    }
}
