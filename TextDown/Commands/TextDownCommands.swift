import SwiftUI

/// SwiftUI Commands (Clean Architecture)
struct TextDownCommands: Commands {
    @FocusedBinding(\.editorText) var editorText: String?
    @FocusedObject var settingsViewModel: SettingsViewModel?
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL

    var body: some Commands {
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
