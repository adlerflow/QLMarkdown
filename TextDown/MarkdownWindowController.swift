//
//  MarkdownWindowController.swift
//  TextDown
//
//  Created by Claude Code on 2025-10-31.
//

import Cocoa
import OSLog

/// Window controller for markdown documents
/// Manages window lifecycle and tab support
class MarkdownWindowController: NSWindowController, NSWindowDelegate {

    // MARK: - Properties

    private let log = OSLog(subsystem: "org.advison.TextDown", category: "WindowController")

    // MARK: - Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()

        setupWindow()
        setupTabSupport()

        // NOTE: Document loading happens in MarkdownDocument.makeWindowControllers()
        // after addWindowController() is called. We cannot load the document here because
        // windowDidLoad() is called DURING storyboard.instantiateController(), which happens
        // BEFORE addWindowController() sets self.document (so self.document is nil here)
    }

    // MARK: - Window Setup

    private func setupWindow() {
        guard let window = window else { return }

        // Window appearance
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false

        // Auto-save window frame
        windowFrameAutosaveName = "MarkdownDocumentWindow"

        os_log(.debug, log: log, "Window setup complete")
    }

    private func setupTabSupport() {
        guard let window = window else { return }

        // Native tab support (macOS 10.12+)
        window.tabbingMode = .preferred
        window.tabbingIdentifier = "MarkdownDocument"

        os_log(.debug, log: log, "Tab support enabled")
    }

    /// Update window to reflect document state (called after document is loaded)
    func updateDocumentDisplay() {
        guard let window = window,
              let document = self.document as? MarkdownDocument else {
            return
        }

        // Set represented URL to enable document proxy features (version browser, move, rename, etc.)
        window.representedURL = document.fileURL

        os_log(.info, log: log, "Updated document display with URL: %{public}@",
               document.fileURL?.path ?? "nil")
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        os_log(.debug, log: log, "Window closing: %{public}@",
               document?.displayName ?? "unknown")
    }

    func windowDidBecomeKey(_ notification: Notification) {
        // Optional: Update menu state when window becomes active
    }
}
