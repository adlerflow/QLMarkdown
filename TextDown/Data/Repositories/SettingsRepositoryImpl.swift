import Foundation

/// Concrete implementation of SettingsRepository using JSON file persistence
/// Stores settings in ~/Library/Application Support/{bundleIdentifier}/settings.json
actor SettingsRepositoryImpl: SettingsRepository {
    // MARK: - Properties

    private let settingsURL: URL
    private let fileManager: FileManager

    // MARK: - Initialization

    init() {
        self.fileManager = FileManager.default

        let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let bundleID = Bundle.main.bundleIdentifier ?? "org.advison.TextDown"
        let appDirectory = appSupport
            .appendingPathComponent(bundleID, isDirectory: true)

        self.settingsURL = appDirectory
            .appendingPathComponent("settings.json")

        try? fileManager.createDirectory(
            at: appDirectory,
            withIntermediateDirectories: true
        )
    }

    init(settingsURL: URL) {
        self.fileManager = FileManager.default
        self.settingsURL = settingsURL

        let directory = settingsURL.deletingLastPathComponent()
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    // MARK: - SettingsRepository

    func load() async throws -> AppSettings? {
        guard fileManager.fileExists(atPath: settingsURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: settingsURL)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        return settings
    }

    func save(_ settings: AppSettings) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        try data.write(to: settingsURL, options: [.atomic])
    }

    func resetToDefaults() async throws {
        if fileManager.fileExists(atPath: settingsURL.path) {
            try fileManager.removeItem(at: settingsURL)
        }
    }

    func hasSettings() async -> Bool {
        fileManager.fileExists(atPath: settingsURL.path)
    }
}
