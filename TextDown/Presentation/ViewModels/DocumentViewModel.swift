import SwiftUI
import Markdown
import OSLog

/// ViewModel for document operations (parse, save, etc.)
/// Manages a single markdown document's lifecycle
@MainActor
class DocumentViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Raw markdown content
    @Published var content: String

    /// Parsed markdown AST (for preview)
    @Published var parsedDocument: Document?

    /// Whether document is currently being parsed
    @Published var isParsing: Bool = false

    /// Current document URL (if saved)
    @Published var documentURL: URL?

    // MARK: - Dependencies

    private let parseMarkdownUseCase: ParseMarkdownUseCase
    private let saveDocumentUseCase: SaveDocumentUseCase
    private let settingsViewModel: SettingsViewModel

    // MARK: - Initialization

    init(
        content: String = "",
        parseMarkdownUseCase: ParseMarkdownUseCase,
        saveDocumentUseCase: SaveDocumentUseCase,
        settingsViewModel: SettingsViewModel
    ) {
        self.content = content
        self.parseMarkdownUseCase = parseMarkdownUseCase
        self.saveDocumentUseCase = saveDocumentUseCase
        self.settingsViewModel = settingsViewModel

        // Parse initial content
        Task {
            await parseContent()
        }
    }

    // MARK: - Document Operations

    /// Parses current content using configured settings
    func parseContent() async {
        isParsing = true
        defer { isParsing = false }

        do {
            let document = try await parseMarkdownUseCase.execute(
                markdown: content,
                settings: settingsViewModel.settings.markdown
            )
            parsedDocument = document
        } catch {
            os_log("Parse error: %{public}@", log: .document, type: .error, String(describing: error))
            parsedDocument = nil
        }
    }

    /// Saves document to current URL
    func saveDocument() async throws {
        guard let url = documentURL else {
            throw DocumentError.fileNotFound(URL(fileURLWithPath: ""))
        }

        try await saveDocumentUseCase.execute(content: content, to: url)
    }

    /// Saves document to a new URL
    func saveDocument(to url: URL) async throws {
        try await saveDocumentUseCase.execute(content: content, to: url)
        documentURL = url
    }

    /// Updates content and triggers parse
    func updateContent(_ newContent: String) {
        content = newContent

        // Debounced parsing happens automatically via subscription
        // (implemented in parent view or via Combine)
    }
}
