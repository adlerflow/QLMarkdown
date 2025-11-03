import SwiftUI

/// SwiftUI Commands (ersetzt Storyboard Menu Bar)
struct TextDownCommands: Commands {
    @FocusedBinding(\.editorText) var editorText: String?
    @AppStorage("auto-refresh") var autoRefresh: Bool = true
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL

    var body: some Commands {
        // MARK: - File Menu Ergänzungen

        CommandGroup(after: .saveItem) {
            Button("Export as HTML...") {
                // TODO: Implement HTML export via .fileExporter
                print("Export HTML action")
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(editorText == nil)
        }

        // MARK: - View Menu

        CommandMenu("View") {
            Toggle("Preview Auto-Refresh", isOn: $autoRefresh)
                .keyboardShortcut("r", modifiers: .command)

            Button("Refresh Preview") {
                // Force refresh via Notification
                NotificationCenter.default.post(name: .forceRefresh, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            .disabled(editorText == nil)

            Divider()

            Button("Toggle Toolbar") {
                // macOS handles this automatically
            }
            .keyboardShortcut("t", modifiers: [.command, .option])
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
