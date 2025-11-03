import Foundation

/// Use case for loading app settings from persistent storage
/// Thread-safe actor that handles settings loading with validation
actor LoadSettingsUseCase {
    // MARK: - Dependencies

    private let settingsRepository: SettingsRepository

    // MARK: - Initialization

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    // MARK: - Business Logic

    /// Loads settings from storage with validation
    /// Returns default settings if none exist or loading fails
    /// - Returns: Validated settings (either loaded or default)
    func execute() async -> AppSettings {
        do {
            // Try to load saved settings
            guard let loadedSettings = try await settingsRepository.load() else {
                print("ℹ️ No saved settings found, using defaults")
                return .default
            }

            // Validate loaded settings
            let validatedSettings = loadedSettings.validated()

            // Log if validation changed anything
            if validatedSettings != loadedSettings {
                print("⚠️ Settings were corrected during validation")
            }

            return validatedSettings
        } catch {
            print("❌ Failed to load settings: \(error)")
            print("ℹ️ Using default settings")
            return .default
        }
    }

    /// Checks if saved settings exist
    /// - Returns: True if settings file exists
    func hasSettings() async -> Bool {
        await settingsRepository.hasSettings()
    }
}
