//
//  TextEditorViewModelTests.swift
//  TextDownTests2
//
//  Unit tests for TextEditorViewModel
//

import XCTest
@testable import TextDown

@MainActor
final class TextEditorViewModelTests: XCTestCase {

    var viewModel: TextEditorViewModel!

    override func setUp() async throws {
        viewModel = TextEditorViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
    }

    // MARK: - Undo/Redo Tests

    func testUndoStackInitiallyEmpty() {
        XCTAssertFalse(viewModel.canUndo, "Undo stack should be empty initially")
    }

    func testRedoStackInitiallyEmpty() {
        XCTAssertFalse(viewModel.canRedo, "Redo stack should be empty initially")
    }

    func testRecordChangeAddsToUndoStack() {
        let oldText = "Hello"
        let newText = "Hello World"

        viewModel.recordChange(oldText: oldText, newText: newText)

        XCTAssertTrue(viewModel.canUndo, "Should be able to undo after recording change")
    }

    func testRecordChangeIgnoresSmallChanges() {
        let oldText = "Hello"
        let newText = "Hella" // Only 1 character difference

        viewModel.recordChange(oldText: oldText, newText: newText)

        XCTAssertFalse(viewModel.canUndo, "Should ignore changes with ≤1 character difference")
    }

    func testPerformUndo() {
        let text1 = "First version"
        let text2 = "Second version here"

        viewModel.recordChange(oldText: text1, newText: text2)

        let result = viewModel.performUndo(currentText: text2)

        XCTAssertEqual(result, text1, "Undo should return previous text")
        XCTAssertTrue(viewModel.canRedo, "Should be able to redo after undo")
        XCTAssertFalse(viewModel.canUndo, "Undo stack should be empty after single undo")
    }

    func testPerformRedo() {
        let text1 = "First version"
        let text2 = "Second version here"

        viewModel.recordChange(oldText: text1, newText: text2)
        _ = viewModel.performUndo(currentText: text2)

        let result = viewModel.performRedo(currentText: text1)

        XCTAssertEqual(result, text2, "Redo should return next text")
        XCTAssertTrue(viewModel.canUndo, "Should be able to undo after redo")
        XCTAssertFalse(viewModel.canRedo, "Redo stack should be empty after single redo")
    }

    func testUndoStackLimit() {
        // Record 60 changes (exceeds 50 limit)
        for i in 0..<60 {
            viewModel.recordChange(
                oldText: "Text \(i)",
                newText: "Text \(i + 1) with more content"
            )
        }

        // Undo 50 times should work
        var undoCount = 0
        while viewModel.canUndo {
            _ = viewModel.performUndo(currentText: "dummy")
            undoCount += 1
        }

        XCTAssertEqual(undoCount, 50, "Undo stack should be limited to 50 entries")
    }

    func testRecordChangeClearsRedoStack() {
        let text1 = "Version 1"
        let text2 = "Version 2 extended"
        let text3 = "Version 3 extended more"

        viewModel.recordChange(oldText: text1, newText: text2)
        _ = viewModel.performUndo(currentText: text2)

        XCTAssertTrue(viewModel.canRedo, "Should have redo available")

        viewModel.recordChange(oldText: text1, newText: text3)

        XCTAssertFalse(viewModel.canRedo, "Recording new change should clear redo stack")
    }

    // MARK: - Search Tests

    func testUpdateMatchCountEmptyQuery() {
        viewModel.searchText = ""
        viewModel.updateMatchCount(in: "Hello World")

        XCTAssertEqual(viewModel.matchCount, 0, "Empty query should have 0 matches")
    }

    func testUpdateMatchCountSingleMatch() {
        viewModel.searchText = "Swift"
        viewModel.updateMatchCount(in: "Swift is great")

        XCTAssertEqual(viewModel.matchCount, 1, "Should find 1 match")
    }

    func testUpdateMatchCountMultipleMatches() {
        viewModel.searchText = "the"
        viewModel.updateMatchCount(in: "The quick brown fox jumps over the lazy dog")

        XCTAssertEqual(viewModel.matchCount, 2, "Should find 2 matches (case-insensitive)")
    }

    func testUpdateMatchCountCaseInsensitive() {
        viewModel.searchText = "MARKDOWN"
        viewModel.updateMatchCount(in: "Markdown is markdown and MarkDown")

        XCTAssertEqual(viewModel.matchCount, 3, "Search should be case-insensitive")
    }

    func testUpdateMatchCountNoMatches() {
        viewModel.searchText = "xyz"
        viewModel.updateMatchCount(in: "Hello World")

        XCTAssertEqual(viewModel.matchCount, 0, "Should find 0 matches")
    }

    // MARK: - Find Bar Tests

    func testToggleFindBar() {
        XCTAssertFalse(viewModel.showingFindBar, "Find bar should be hidden initially")

        viewModel.toggleFindBar()
        XCTAssertTrue(viewModel.showingFindBar, "Find bar should be visible after toggle")

        viewModel.toggleFindBar()
        XCTAssertFalse(viewModel.showingFindBar, "Find bar should be hidden after second toggle")
    }

    func testCloseFindBar() {
        viewModel.searchText = "test query"
        viewModel.showingFindBar = true

        viewModel.closeFindBar()

        XCTAssertFalse(viewModel.showingFindBar, "Find bar should be hidden")
        XCTAssertEqual(viewModel.searchText, "", "Search text should be cleared")
        XCTAssertEqual(viewModel.matchCount, 0, "Match count should be reset")
    }

    // MARK: - File Validation Tests

    func testIsMarkdownFileWithMdExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.md")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), ".md should be recognized")
    }

    func testIsMarkdownFileWithMarkdownExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.markdown")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), ".markdown should be recognized")
    }

    func testIsMarkdownFileWithRmdExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.rmd")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), ".rmd should be recognized")
    }

    func testIsMarkdownFileWithQmdExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.qmd")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), ".qmd should be recognized")
    }

    func testIsMarkdownFileWithTxtExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.txt")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), ".txt should be recognized")
    }

    func testIsMarkdownFileWithInvalidExtension() {
        let url = URL(fileURLWithPath: "/tmp/test.pdf")
        XCTAssertFalse(viewModel.isMarkdownFile(url: url), ".pdf should not be recognized")
    }

    func testIsMarkdownFileCaseInsensitive() {
        let url = URL(fileURLWithPath: "/tmp/test.MD")
        XCTAssertTrue(viewModel.isMarkdownFile(url: url), "Extension check should be case-insensitive")
    }
}
