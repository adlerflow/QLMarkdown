//
//  TextEditorViewModel.swift
//  TextDown
//
//  ViewModel for PureSwiftUITextEditor
//  Manages undo/redo stack, search functionality, and business logic
//

import SwiftUI
import UniformTypeIdentifiers

/// ViewModel for text editor functionality
@MainActor
class TextEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Current search query
    @Published var searchText: String = ""

    /// Whether find bar is visible
    @Published var showingFindBar: Bool = false

    /// Number of search matches found
    @Published var matchCount: Int = 0

    // MARK: - Undo/Redo Stack

    private var undoStack: [String] = []
    private var redoStack: [String] = []
    private let maxUndoStackSize = 50

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }

    // MARK: - Text Management

    /// Records a text change for undo/redo (only significant changes)
    func recordChange(oldText: String, newText: String) {
        // Only record significant changes (more than 1 character difference)
        guard abs(oldText.count - newText.count) > 1 else { return }

        undoStack.append(oldText)
        redoStack.removeAll()

        // Limit stack size
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
    }

    /// Performs undo operation
    /// - Parameter currentText: Current text content
    /// - Returns: Previous text state, or nil if undo stack is empty
    func performUndo(currentText: String) -> String? {
        guard let previous = undoStack.popLast() else { return nil }
        redoStack.append(currentText)
        return previous
    }

    /// Performs redo operation
    /// - Parameter currentText: Current text content
    /// - Returns: Next text state, or nil if redo stack is empty
    func performRedo(currentText: String) -> String? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(currentText)
        return next
    }

    // MARK: - Search Functionality

    /// Updates match count for current search query
    /// - Parameter text: Text to search in
    func updateMatchCount(in text: String) {
        guard !searchText.isEmpty else {
            matchCount = 0
            return
        }

        // Count occurrences efficiently using ranges(of:)
        let lowercasedText = text.lowercased()
        let lowercasedQuery = searchText.lowercased()

        var count = 0
        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex

        while let range = lowercasedText.range(of: lowercasedQuery, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<lowercasedText.endIndex
        }

        matchCount = count
    }

    /// Toggle find bar visibility
    func toggleFindBar() {
        showingFindBar.toggle()
    }

    /// Close find bar
    func closeFindBar() {
        showingFindBar = false
        searchText = ""
        matchCount = 0
    }

    // MARK: - File Validation

    /// Checks if URL represents a markdown file
    /// - Parameter url: File URL to check
    /// - Returns: True if file is markdown-compatible
    nonisolated func isMarkdownFile(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["md", "markdown", "rmd", "qmd", "txt"].contains(ext)
    }
}
