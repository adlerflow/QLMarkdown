//
//  MarkdownDocument.swift
//  TextDown
//
//  Created by Claude Code on 2025-10-31.
//

import Cocoa
import OSLog

/// NSDocument subclass for managing Markdown files
/// Handles file I/O, dirty state tracking, and auto-save
class MarkdownDocument: NSDocument {

    // MARK: - Properties

    /// The markdown content of the document
    private(set) var markdownContent: String = ""

    /// Logger for document operations
    private let log = OSLog(subsystem: "org.advison.TextDown", category: "Document")

    // MARK: - Document Configuration

    override class var autosavesInPlace: Bool {
        return true
    }

    override class var usesUbiquitousStorage: Bool {
        return false  // Set to true later for iCloud support
    }

    // MARK: - Window Management

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        guard let windowController = storyboard.instantiateController(
            withIdentifier: "Document Window Controller"
        ) as? MarkdownWindowController else {
            os_log(.error, log: log, "Failed to instantiate MarkdownWindowController")
            return
        }

        addWindowController(windowController)
    }

    // MARK: - Reading and Writing

    override func data(ofType typeName: String) throws -> Data {
        guard let data = markdownContent.data(using: .utf8) else {
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: unimpErr,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to encode markdown content as UTF-8"
                ]
            )
        }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: unimpErr,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to decode file as UTF-8"
                ]
            )
        }

        markdownContent = content
        os_log(.info, log: log, "Document loaded: %{public}@ (%d bytes)",
               fileURL?.lastPathComponent ?? "untitled", content.utf8.count)
    }

    // MARK: - Content Management

    /// Update the document content and mark as modified
    /// - Parameter newContent: The new markdown content
    func updateContent(_ newContent: String) {
        guard newContent != markdownContent else {
            return  // No change
        }

        undoManager?.registerUndo(withTarget: self) { document in
            document.updateContent(document.markdownContent)
        }

        markdownContent = newContent
        updateChangeCount(.changeDone)
    }

    // MARK: - Printing

    override func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) throws -> NSPrintOperation {
        // TODO: Implement printing (optional)
        return try super.printOperation(withSettings: printSettings)
    }
}
