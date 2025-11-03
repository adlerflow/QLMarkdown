import SwiftUI
import UniformTypeIdentifiers

/// Pure SwiftUI Text Editor mit Undo/Redo, Find Bar, Drag & Drop
struct PureSwiftUITextEditor: View {
    @Binding var text: String
    @StateObject private var viewModel = TextEditorViewModel()
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 0) {
            // Find Bar (conditional)
            if viewModel.showingFindBar {
                FindBar(viewModel: viewModel, currentText: text)
            }

            // Main Text Editor
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
                .onChange(of: text) { oldValue, newValue in
                    viewModel.recordChange(oldText: oldValue, newText: newValue)
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Find Button
                Button {
                    viewModel.toggleFindBar()
                } label: {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .keyboardShortcut("f", modifiers: .command)
                .help("Find in document")

                Divider()

                // Undo Button
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

                // Redo Button
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

// MARK: - Find Bar

struct FindBar: View {
    @ObservedObject var viewModel: TextEditorViewModel
    let currentText: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Find", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .frame(width: 200)

            if !viewModel.searchText.isEmpty {
                Text("\(viewModel.matchCount) matches")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 16)

            // Previous Button (disabled - SwiftUI limitation)
            Button {
                // SwiftUI TextEditor doesn't support programmatic selection
            } label: {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.plain)
            .disabled(true)
            .help("Find previous (not available in SwiftUI TextEditor)")

            // Next Button (disabled - SwiftUI limitation)
            Button {
                // SwiftUI TextEditor doesn't support programmatic selection
            } label: {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.plain)
            .disabled(true)
            .help("Find next (not available in SwiftUI TextEditor)")

            Spacer()

            // Close Button
            Button {
                viewModel.closeFindBar()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Close find bar")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.updateMatchCount(in: currentText)
        }
        .onAppear {
            viewModel.updateMatchCount(in: currentText)
        }
    }
}
