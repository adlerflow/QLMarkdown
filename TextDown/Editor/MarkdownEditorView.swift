import SwiftUI
import Markdown

/// Haupt-Editor-View mit Split-Layout (Editor | Preview)
struct MarkdownEditorView: View {
    @Binding var document: MarkdownFileDocument
    @EnvironmentObject var appState: AppState

    @State private var renderedDocument: Document?
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        HSplitView {
            // Links: Pure SwiftUI Text Editor
            PureSwiftUITextEditor(
                text: $document.content
            )
            .frame(minWidth: 300)
            .focusedSceneValue(\.editorText, $document.content)

            // Rechts: Native SwiftUI Markdown Renderer
            MarkdownASTView(document: renderedDocument)
                .frame(minWidth: 300)
        }
        .frame(minHeight: 400)
        .onChange(of: document.content) { oldValue, newValue in
            debounceRender()
        }
        .onAppear {
            renderMarkdown()
        }
        .onReceive(NotificationCenter.default.publisher(for: .forceRefresh)) { _ in
            renderMarkdown()
        }
    }

    // MARK: - Rendering

    private func debounceRender() {
        guard appState.autoRefresh else { return }

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            if !Task.isCancelled {
                renderMarkdown()
            }
        }
    }

    @MainActor
    private func renderMarkdown() {
        // Parse with swift-markdown
        let parseOptions: ParseOptions = appState.enableTable
            ? [] // GFM options not yet exposed in swift-markdown 0.5.0
            : []

        renderedDocument = Document(
            parsing: document.content,
            options: parseOptions
        )
    }
}

// MARK: - FocusedValue für Commands

extension FocusedValues {
    var editorText: Binding<String>? {
        get { self[EditorTextKey.self] }
        set { self[EditorTextKey.self] = newValue }
    }
}

private struct EditorTextKey: FocusedValueKey {
    typealias Value = Binding<String>
}

// MARK: - Notification Names

extension Notification.Name {
    static let forceRefresh = Notification.Name("forceRefresh")
}
