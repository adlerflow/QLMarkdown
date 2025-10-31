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
        notifyViewControllerOfDocument()
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

    private func notifyViewControllerOfDocument() {
        guard let viewController = contentViewController as? DocumentViewController,
              let document = self.document as? MarkdownDocument else {
            return
        }

        viewController.representedObject = document
        viewController.loadDocument(document)
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
