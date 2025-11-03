//
//  MarkdownEditorViewModel.swift
//  TextDown
//
//  ViewModel for MarkdownEditorView
//  Manages document rendering, debouncing, and parsing coordination
//

import SwiftUI
import Markdown

/// ViewModel for markdown editor and preview coordination
/// Uses Clean Architecture with dependency injection
@MainActor
class MarkdownEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Rendered markdown document (parsed AST)
    @Published var renderedDocument: Document?

    /// Force refresh trigger
    @Published var refreshTrigger: UUID = UUID()

    // MARK: - Dependencies

    private let parseMarkdownUseCase: ParseMarkdownUseCase
    private let settingsViewModel: SettingsViewModel

    // MARK: - Private Properties

    private var debounceTask: Task<Void, Never>?
    private let debounceDelay: Duration = .milliseconds(500)

    // MARK: - Initialization

    init(
        parseMarkdownUseCase: ParseMarkdownUseCase,
        settingsViewModel: SettingsViewModel
    ) {
        self.parseMarkdownUseCase = parseMarkdownUseCase
        self.settingsViewModel = settingsViewModel
    }

    // MARK: - Rendering

    /// Renders markdown content with debouncing
    /// - Parameter content: Raw markdown string
    func debounceRender(content: String) {
        guard settingsViewModel.settings.editor.autoRefresh else { return }

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: debounceDelay)
            if !Task.isCancelled {
                await render(content: content)
            }
        }
    }

    /// Renders markdown content immediately (no debouncing)
    /// - Parameter content: Raw markdown string
    func render(content: String) async {
        do {
            let document = try await parseMarkdownUseCase.execute(
                markdown: content,
                settings: settingsViewModel.settings.markdown
            )
            renderedDocument = document
        } catch {
            print("❌ Parse error: \(error)")
            renderedDocument = nil
        }
    }

    /// Forces immediate render (cancels debounce)
    /// - Parameter content: Raw markdown string
    func forceRender(content: String) {
        debounceTask?.cancel()
        refreshTrigger = UUID()

        Task {
            await render(content: content)
        }
    }

    /// Triggers manual refresh
    func refreshPreview(content: String) {
        forceRender(content: content)
    }
}
