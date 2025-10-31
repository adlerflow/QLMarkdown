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
@objcMembers
class MarkdownDocument: NSDocument {

    // MARK: - Properties

    /// The markdown content of the document
    private(set) var markdownContent: String = ""

    /// Logger for document operations
    private let log = OSLog(subsystem: "org.advison.TextDown", category: "Document")

    // MARK: - Initialization

    override init() {
        super.init()
        Swift.print("MarkdownDocument: initialized")
        os_log(.info, log: log, "MarkdownDocument initialized")
    }

    // MARK: - Document Configuration

    override class var autosavesInPlace: Bool {
        return true
    }

    override class var usesUbiquitousStorage: Bool {
        return false  // Set to true later for iCloud support
    }

    // MARK: - Window Management

    override func makeWindowControllers() {
        os_log(.info, log: log, "makeWindowControllers called")

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        os_log(.info, log: log, "Storyboard loaded")

        guard let windowController = storyboard.instantiateController(
            withIdentifier: "Document Window Controller"
        ) as? MarkdownWindowController else {
            os_log(.error, log: log, "Failed to instantiate MarkdownWindowController from storyboard")

            // Try to show what we got instead
            let controller = storyboard.instantiateController(withIdentifier: "Document Window Controller")
            os_log(.error, log: log, "Got controller type: %{public}@", String(describing: type(of: controller)))
            return
        }

        os_log(.info, log: log, "Window controller instantiated successfully")
        addWindowController(windowController)
        os_log(.info, log: log, "Window controller added to document")

        // Load document content into view controller
        // This must happen AFTER addWindowController() because windowDidLoad() is called DURING
        // storyboard.instantiateController(), before self.document is set
        if let viewController = windowController.contentViewController as? DocumentViewController {
            Swift.print("MarkdownDocument: Loading document content into view controller (\(markdownContent.count) bytes)")
            viewController.representedObject = self
            viewController.loadDocument(self)
            Swift.print("MarkdownDocument: Document content loaded successfully")
        } else {
            Swift.print("MarkdownDocument: ERROR - Could not get DocumentViewController")
        }

        // Update window display with document info (enables document proxy, version browser, etc.)
        windowController.updateDocumentDisplay()
    }

    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        Swift.print("MarkdownDocument: windowControllerDidLoadNib called, content: \(markdownContent.count) bytes")
        os_log(.info, log: log, "windowControllerDidLoadNib called, content: %d bytes", markdownContent.count)

        // Notify view controller that document content is ready
        if let markdownWindowController = windowController as? MarkdownWindowController,
           let viewController = markdownWindowController.contentViewController as? DocumentViewController {
            Swift.print("MarkdownDocument: Loading document into view controller")
            viewController.representedObject = self
            viewController.loadDocument(self)
            Swift.print("MarkdownDocument: Document content loaded into view controller")
            os_log(.info, log: log, "Document content loaded into view controller")
        } else {
            Swift.print("MarkdownDocument: ERROR - Could not get view controller")
        }
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
        Swift.print("MarkdownDocument: read(from:ofType:) called with \(data.count) bytes, type: \(typeName)")
        os_log(.info, log: log, "read(from:ofType:) called with %d bytes, type: %{public}@",
               data.count, typeName)

        guard let content = String(data: data, encoding: .utf8) else {
            Swift.print("MarkdownDocument: ERROR - Failed to decode data as UTF-8")
            os_log(.error, log: log, "Failed to decode data as UTF-8")
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: unimpErr,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to decode file as UTF-8"
                ]
            )
        }

        markdownContent = content
        Swift.print("MarkdownDocument: Document loaded: \(fileURL?.lastPathComponent ?? "untitled") (\(content.utf8.count) bytes)")
        Swift.print("MarkdownDocument: Content preview: \(String(content.prefix(100)))")
        os_log(.info, log: log, "Document loaded: %{public}@ (%d bytes)",
               fileURL?.lastPathComponent ?? "untitled", content.utf8.count)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        Swift.print("MarkdownDocument: read(from url:ofType:) called: \(url.path)")
        os_log(.info, log: log, "read(from url:ofType:) called: %{public}@", url.path)
        try super.read(from: url, ofType: typeName)
    }

    // MARK: - Saving

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: saveOperation) { [weak self] error in
            if error == nil {
                // Update window display after successful save
                Swift.print("MarkdownDocument: Document saved to: \(url.path)")
                self?.updateWindowDisplay()
            }
            completionHandler(error)
        }
    }

    private func updateWindowDisplay() {
        for windowController in windowControllers {
            if let markdownWindowController = windowController as? MarkdownWindowController {
                markdownWindowController.updateDocumentDisplay()
            }
        }
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
