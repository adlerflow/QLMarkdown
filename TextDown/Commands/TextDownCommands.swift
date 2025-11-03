import SwiftUI

/// SwiftUI Commands (ersetzt Storyboard Menu Bar)
struct TextDownCommands: Commands {
    @FocusedBinding(\.editorText) var editorText: String?
    @FocusedObject var appState: AppState?
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL

    var body: some Commands {
        // MARK: - File Menu Ergänzungen

        CommandGroup(after: .saveItem) {
            Button("Export as HTML...") {
                // Future enhancement: Implement HTML export via .fileExporter
                // Requires: 1) AST → HTML conversion, 2) SwiftUI .fileExporter modifier
                // Currently not implemented due to Pure SwiftUI architecture
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(true)  // Disabled until implementation
        }

        // MARK: - View Menu

        CommandGroup(after: .toolbar) {
            if let appState = appState {
                Toggle("Preview Auto-Refresh", isOn: Binding(
                    get: { appState.autoRefresh },
                    set: { appState.autoRefresh = $0 }
                ))
                .keyboardShortcut("r", modifiers: .command)

                Button("Refresh Preview") {
                    // Force refresh via reactive trigger
                    appState.refreshTrigger = UUID()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                .disabled(editorText == nil)
            }
        }

        // MARK: - Window Menu

        CommandGroup(replacing: .windowArrangement) {
            Button("About TextDown") {
                openWindow(id: "about")
            }

            Divider()

            Button("Minimize") {
                // macOS handles this
            }
            .keyboardShortcut("m", modifiers: .command)

            Button("Zoom") {
                // macOS handles this
            }

            Divider()

            Button("Bring All to Front") {
                // macOS handles this
            }
        }

        // MARK: - Help Menu

        CommandGroup(replacing: .help) {
            Button("TextDown Help") {
                if let url = URL(string: "https://github.com/adlerflow/TextDown") {
                    openURL(url)
                }
            }
            .keyboardShortcut("?", modifiers: .command)
        }
    }
}
