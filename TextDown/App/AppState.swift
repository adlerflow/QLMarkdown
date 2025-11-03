import SwiftUI
import Combine
import Foundation

/// App-weiter State (ersetzt AppDelegate + AppConfiguration)
@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties

    @Published var autoRefresh: Bool = true
    @Published var syntaxTheme: String = "github-dark"
    @Published var renderingSettings: RenderingSettings = .default

    // MARK: - Settings Persistence

    private let settingsURL: URL
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Settings Location: ~/Library/Application Support/org.advison.TextDown/settings.json
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let appDirectory = appSupport
            .appendingPathComponent("org.advison.TextDown", isDirectory: true)

        settingsURL = appDirectory
            .appendingPathComponent("settings.json")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: appDirectory,
            withIntermediateDirectories: true
        )

        // Load settings
        loadSettings()

        // Auto-save on changes
        setupAutoSave()
    }

    // MARK: - Settings Management

    private func loadSettings() {
        guard let data = try? Data(contentsOf: settingsURL),
              let decoded = try? JSONDecoder().decode(Settings.self, from: data) else {
            print("ℹ️ No saved settings found, using defaults")
            return
        }

        autoRefresh = decoded.autoRefresh
        syntaxTheme = decoded.syntaxTheme
        renderingSettings = decoded.renderingSettings
    }

    func saveSettings() {
        let settings = Settings(
            autoRefresh: autoRefresh,
            syntaxTheme: syntaxTheme,
            renderingSettings: renderingSettings
        )

        guard let data = try? JSONEncoder().encode(settings) else {
            print("❌ Failed to encode settings")
            return
        }

        do {
            try data.write(to: settingsURL, options: .atomic)
            print("✅ Settings saved to \(settingsURL.path)")
        } catch {
            print("❌ Failed to save settings: \(error)")
        }
    }

    private func setupAutoSave() {
        // Auto-save when properties change (debounced)
        Publishers.CombineLatest3(
            $autoRefresh,
            $syntaxTheme,
            $renderingSettings
        )
        .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _, _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
    }
}

// MARK: - Settings Models

struct Settings: Codable {
    var autoRefresh: Bool
    var syntaxTheme: String
    var renderingSettings: RenderingSettings
}

struct RenderingSettings: Codable, Equatable {
    var enableMath: Bool = false  // TODO: Implement pure Swift math renderer
    var enableEmoji: Bool = true
    var enableSyntaxHighlighting: Bool = true
    var enableGFMTables: Bool = false  // TODO: Implement SwiftUI Grid-based renderer
    var enableTaskLists: Bool = false  // TODO: Implement checkbox rendering

    static let `default` = RenderingSettings()
}
