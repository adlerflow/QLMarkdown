import SwiftUI
import UniformTypeIdentifiers

/// Pure SwiftUI Text Editor with Undo/Redo, Native Find, Drag & Drop
struct PureSwiftUITextEditor: View {
    @Binding var text: String
    @StateObject private var viewModel = TextEditorViewModel()
    @Environment(\.openURL) var openURL
    @State private var isFindNavigatorPresented = false

    var body: some View {
        // Main Text Editor
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .findNavigator(isPresented: $isFindNavigatorPresented)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
            .onChange(of: text) { oldValue, newValue in
                viewModel.recordChange(oldText: oldValue, newText: newValue)
            }
        .toolbar(id: "editor") {
            // MARK: - Editor Tools
            ToolbarItem(id: "find", placement: .automatic) {
                Toggle(isOn: $isFindNavigatorPresented) {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .keyboardShortcut("f", modifiers: .command)
                .help("Find and replace (⌘F)")
            }

            ToolbarItem(id: "undo", placement: .automatic) {
                Button {
                    if let previousText = viewModel.performUndo(currentText: text) {
                        text = previousText
                    }
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!viewModel.canUndo)
                .help("Undo last change")
            }

            ToolbarItem(id: "redo", placement: .automatic) {
                Button {
                    if let nextText = viewModel.performRedo(currentText: text) {
                        text = nextText
                    }
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!viewModel.canRedo)
                .help("Redo last undone change")
            }
        }
    }

    // MARK: - Drag & Drop

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil),
                          viewModel.isMarkdownFile(url: url) else {
                        return
                    }

                    // Open in new window via openURL
                    Task { @MainActor in
                        openURL(url)
                    }
                }
                return true
            }
        }
        return false
    }
}
