import Foundation

/// Use case for saving app settings to persistent storage
/// Thread-safe actor that handles settings persistence with validation
actor SaveSettingsUseCase {
    // MARK: - Dependencies

    private let settingsRepository: SettingsRepository

    // MARK: - Initialization

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    // MARK: - Business Logic

    /// Saves settings to storage with validation
    /// - Parameter settings: Settings to persist
    /// - Throws: If save operation fails
    func execute(_ settings: AppSettings) async throws {
        // Validate before saving
        let validatedSettings = settings.validated()

        // Save to storage
        try await settingsRepository.save(validatedSettings)

        print("✅ Settings saved successfully")
    }

    /// Resets settings to factory defaults
    /// - Throws: If reset operation fails
    func resetToDefaults() async throws {
        try await settingsRepository.resetToDefaults()
        print("✅ Settings reset to defaults")
    }
}
