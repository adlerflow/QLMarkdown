import SwiftUI
import UniformTypeIdentifiers

/// Pure SwiftUI Text Editor mit Undo/Redo, Find Bar, Drag & Drop
struct PureSwiftUITextEditor: View {
    @Binding var text: String
    @Binding var isFocused: Bool

    @State private var searchText: String = ""
    @State private var showingFindBar: Bool = false
    @State private var undoStack: [String] = []
    @State private var redoStack: [String] = []
    @State private var lastSavedText: String = ""

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 0) {
            // Find Bar (conditional)
            if showingFindBar {
                FindBar(
                    searchText: $searchText,
                    currentText: text,
                    onClose: { showingFindBar = false },
                    onFindNext: { findNext() },
                    onFindPrevious: { findPrevious() }
                )
            }

            // Main Text Editor
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .focused($isFocused)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
                .onChange(of: text) { oldValue, newValue in
                    // Undo/Redo tracking (only significant changes)
                    if oldValue != newValue && abs(oldValue.count - newValue.count) > 1 {
                        undoStack.append(oldValue)
                        redoStack.removeAll()

                        // Limit undo stack to 50 entries
                        if undoStack.count > 50 {
                            undoStack.removeFirst()
                        }
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Find Button
                Button {
                    showingFindBar.toggle()
                } label: {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .keyboardShortcut("f", modifiers: .command)
                .help("Find in document")

                Divider()

                // Undo Button
                Button {
                    performUndo()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(undoStack.isEmpty)
                .help("Undo last change")

                // Redo Button
                Button {
                    performRedo()
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(redoStack.isEmpty)
                .help("Redo last undone change")
            }
        }
        .onAppear {
            lastSavedText = text
        }
    }

    // MARK: - Undo/Redo

    private func performUndo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(text)
        text = previous
    }

    private func performRedo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(text)
        text = next
    }

    // MARK: - Find Navigation

    private func findNext() {
        guard !searchText.isEmpty else { return }
        // TODO: Implement text search and selection
        // SwiftUI TextEditor doesn't expose selection API yet
        print("Find next: \(searchText)")
    }

    private func findPrevious() {
        guard !searchText.isEmpty else { return }
        // TODO: Implement text search and selection
        print("Find previous: \(searchText)")
    }

    // MARK: - Drag & Drop

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil),
                          isMarkdownFile(url: url) else {
                        return
                    }

                    // Open in new window via openURL
                    DispatchQueue.main.async {
                        openURL(url)
                    }
                }
                return true
            }
        }
        return false
    }

    private func isMarkdownFile(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["md", "markdown", "rmd", "qmd", "txt"].contains(ext)
    }
}

// MARK: - Find Bar

struct FindBar: View {
    @Binding var searchText: String
    let currentText: String
    let onClose: () -> Void
    let onFindNext: () -> Void
    let onFindPrevious: () -> Void

    @State private var matchCount: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Find", text: $searchText)
                .textFieldStyle(.plain)
                .frame(width: 200)

            if !searchText.isEmpty {
                Text("\(matchCount) matches")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 16)

            // Previous Button
            Button {
                onFindPrevious()
            } label: {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.plain)
            .disabled(matchCount == 0)
            .help("Find previous")

            // Next Button
            Button {
                onFindNext()
            } label: {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.plain)
            .disabled(matchCount == 0)
            .help("Find next")

            Spacer()

            // Close Button
            Button {
                onClose()
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
        .onChange(of: searchText) { _, newValue in
            updateMatchCount(newValue)
        }
        .onAppear {
            updateMatchCount(searchText)
        }
    }

    private func updateMatchCount(_ query: String) {
        guard !query.isEmpty else {
            matchCount = 0
            return
        }

        // Count occurrences (case-insensitive)
        matchCount = currentText.lowercased().components(separatedBy: query.lowercased()).count - 1
    }
}
