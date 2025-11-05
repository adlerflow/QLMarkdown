import SwiftUI
import Markdown

/// Main editor view with split layout (Editor | Preview)
/// Uses Clean Architecture with dependency injection
struct MarkdownEditorView: View {
    @Binding var document: MarkdownFileDocument
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel: MarkdownEditorViewModel

    init(
        document: Binding<MarkdownFileDocument>,
        parseMarkdownUseCase: ParseMarkdownUseCase,
        settingsViewModel: SettingsViewModel
    ) {
        self._document = document

        // Create ViewModel with injected dependencies
        self._viewModel = StateObject(wrappedValue: MarkdownEditorViewModel(
            parseMarkdownUseCase: parseMarkdownUseCase,
            settingsViewModel: settingsViewModel
        ))

        // Note: settingsViewModel comes via @EnvironmentObject from TextDownApp
        self._settingsViewModel = EnvironmentObject()
    }

    var body: some View {
        HSplitView {
            // Left: Pure SwiftUI Text Editor
            PureSwiftUITextEditor(text: $document.content)
                .frame(minWidth: 300)
                .focusedSceneValue(\.editorText, $document.content)
                .focusedSceneObject(settingsViewModel)

            // Right: Native SwiftUI Markdown Renderer
            MarkdownASTView(document: viewModel.renderedDocument)
                .frame(minWidth: 300)
        }
        .frame(minHeight: 400)
        .onChange(of: document.content) { oldValue, newValue in
            viewModel.debounceRender(content: newValue)
        }
        .onChange(of: viewModel.refreshTrigger) { _, _ in
            viewModel.forceRender(content: document.content)
        }
        .onAppear {
            Task {
                await viewModel.render(content: document.content)
            }
        }
    }
}
