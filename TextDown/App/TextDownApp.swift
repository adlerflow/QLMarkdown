import SwiftUI

@main
struct TextDownApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        // Haupt-Dokumenten-Szene
        DocumentGroup(newDocument: MarkdownFileDocument()) { file in
            MarkdownEditorView(document: file.$document)
                .environmentObject(appState)
        }
        .commands {
            TextDownCommands()
        }

        // Einstellungen (bereits SwiftUI)
        Settings {
            TextDownSettingsView()
                .environmentObject(appState)
        }

        // About-Fenster
        Window("About TextDown", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
