//
//  SettingsTests.swift
//  TextDownTests
//
//  Clean Architecture Settings Tests
//  Tests SettingsViewModel, SettingsRepository, and AppSettings domain entities
//

import XCTest
@testable import TextDown

@MainActor
final class SettingsTests: XCTestCase {
    var settingsViewModel: SettingsViewModel!
    var settingsRepository: SettingsRepositoryImpl!
    var tempDirectory: URL!
    var tempSettingsURL: URL!

    override func setUp() async throws {
        // Create temporary directory for test settings
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        tempSettingsURL = tempDirectory.appendingPathComponent("test_settings.json")

        // Create repository with temp location
        settingsRepository = SettingsRepositoryImpl(settingsURL: tempSettingsURL)

        // Create use cases
        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepository)
        let validateUseCase = ValidateSettingsUseCase()

        // Create view model
        settingsViewModel = SettingsViewModel(
            loadSettingsUseCase: loadUseCase,
            saveSettingsUseCase: saveUseCase,
            validateSettingsUseCase: validateUseCase
        )
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        settingsViewModel = nil
        settingsRepository = nil
        tempDirectory = nil
        tempSettingsURL = nil
    }

    // MARK: - Domain Entity Tests

    func testAppSettingsDefaultValues() {
        let settings = AppSettings.default

        // Editor defaults
        XCTAssertFalse(settings.editor.openInlineLink, "openInlineLink should default to false")
        XCTAssertFalse(settings.editor.debug, "debug should default to false")

        // Markdown GFM defaults
        XCTAssertTrue(settings.markdown.enableAutolink, "enableAutolink should default to true")
        XCTAssertTrue(settings.markdown.enableTable, "enableTable should default to true")
        XCTAssertTrue(settings.markdown.enableTaskList, "enableTaskList should default to true")

        // Syntax theme defaults
        XCTAssertTrue(settings.syntaxTheme.enabled, "syntax highlighting should default to enabled")
        XCTAssertEqual(settings.syntaxTheme.tabWidth, 4, "tab width should default to 4")
        XCTAssertEqual(settings.syntaxTheme.lightTheme, "github", "light theme should default to github")
        XCTAssertEqual(settings.syntaxTheme.darkTheme, "github-dark", "dark theme should default to github-dark")
    }

    func testAppSettingsValidation() {
        var settings = AppSettings.default

        // Test conflicting strikethrough settings
        settings.markdown.enableStrikethrough = false
        settings.markdown.enableStrikethroughDoubleTilde = true

        let validated = settings.validated()

        // Should disable double tilde when strikethrough is disabled
        XCTAssertFalse(validated.markdown.enableStrikethroughDoubleTilde,
                      "Double tilde should be disabled when strikethrough is disabled")
    }

    func testAppSettingsCodableRoundtrip() throws {
        var settings = AppSettings.default

        // Modify some values
        settings.editor.openInlineLink = true
        settings.markdown.enableTable = false
        settings.markdown.enableStrikethrough = false
        settings.syntaxTheme.tabWidth = 8
        settings.syntaxTheme.lightTheme = "solarized-light"

        // Encode
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppSettings.self, from: data)

        // Verify
        XCTAssertEqual(decoded.editor.openInlineLink, true)
        XCTAssertEqual(decoded.markdown.enableTable, false)
        XCTAssertEqual(decoded.markdown.enableStrikethrough, false)
        XCTAssertEqual(decoded.syntaxTheme.tabWidth, 8)
        XCTAssertEqual(decoded.syntaxTheme.lightTheme, "solarized-light")
    }

    // MARK: - Repository Tests

    func testSettingsRepositoryLoad() async throws {
        // No settings file exists yet
        let loaded = try await settingsRepository.load()
        XCTAssertNil(loaded, "Should return nil when no settings file exists")
    }

    func testSettingsRepositorySave() async throws {
        var settings = AppSettings.default
        settings.editor.openInlineLink = true
        settings.markdown.enableTable = false

        // Save
        try await settingsRepository.save(settings)

        // Verify file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempSettingsURL.path),
                     "Settings file should exist")

        // Load
        let loaded = try await settingsRepository.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.editor.openInlineLink, true)
        XCTAssertEqual(loaded?.markdown.enableTable, false)
    }

    func testSettingsRepositoryResetToDefaults() async throws {
        // Save non-default settings
        var settings = AppSettings.default
        settings.editor.openInlineLink = true
        settings.markdown.enableTable = false
        try await settingsRepository.save(settings)

        // Reset (deletes the file)
        try await settingsRepository.resetToDefaults()

        // Load should return nil after reset
        let loaded = try await settingsRepository.load()

        XCTAssertNil(loaded, "Should return nil after reset (file deleted)")

        // LoadSettingsUseCase would handle returning .default for nil
    }

    func testSettingsRepositoryHasSettings() async throws {
        // Initially no settings
        let hasBefore = await settingsRepository.hasSettings()
        XCTAssertFalse(hasBefore, "Should not have settings initially")

        // Save settings
        try await settingsRepository.save(.default)

        // Now has settings
        let hasAfter = await settingsRepository.hasSettings()
        XCTAssertTrue(hasAfter, "Should have settings after save")
    }

    // MARK: - Use Case Tests

    func testLoadSettingsUseCaseWithNoFile() async {
        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)

        let settings = await loadUseCase.execute()

        // Should return defaults when no file exists
        XCTAssertFalse(settings.editor.openInlineLink)
        XCTAssertEqual(settings.markdown.enableTable, true)
    }

    func testLoadSettingsUseCaseWithValidFile() async throws {
        // Save settings first
        var testSettings = AppSettings.default
        testSettings.editor.openInlineLink = true
        testSettings.markdown.enableStrikethrough = false
        try await settingsRepository.save(testSettings)

        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)

        let loaded = await loadUseCase.execute()

        XCTAssertEqual(loaded.editor.openInlineLink, true)
        XCTAssertEqual(loaded.markdown.enableStrikethrough, false)
    }

    func testSaveSettingsUseCaseValidatesBeforeSaving() async throws {
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepository)

        var settings = AppSettings.default
        settings.markdown.enableStrikethrough = false
        settings.markdown.enableStrikethroughDoubleTilde = true  // Invalid!

        try await saveUseCase.execute(settings)

        // Load back
        let loaded = try await settingsRepository.load()

        // Should have validated and fixed the conflict
        XCTAssertNotNil(loaded)
        XCTAssertFalse(loaded!.markdown.enableStrikethroughDoubleTilde,
                      "Should fix conflict during save")
    }

    func testSaveSettingsUseCaseResetToDefaults() async throws {
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepository)

        // Save non-default
        var settings = AppSettings.default
        settings.editor.openInlineLink = true
        try await saveUseCase.execute(settings)

        // Reset (delegates to repository which deletes file)
        try await saveUseCase.resetToDefaults()

        // Verify file was deleted
        let hasSettings = await settingsRepository.hasSettings()
        XCTAssertFalse(hasSettings, "Settings file should be deleted after reset")
    }

    func testValidateSettingsUseCaseFindsConflicts() async {
        let validateUseCase = ValidateSettingsUseCase()

        var settings = AppSettings.default
        settings.markdown.enableStrikethrough = false
        settings.markdown.enableStrikethroughDoubleTilde = true  // Conflict!

        let issues = await validateUseCase.validate(settings)

        XCTAssertGreaterThan(issues.count, 0, "Should find the conflict")
        XCTAssertTrue(issues.contains { $0.property == "enableStrikethroughDoubleTilde" },
                     "Should identify the conflicting property")
    }

    // MARK: - ViewModel Tests

    func testSettingsViewModelInitialization() async {
        // ViewModel should load settings on init
        // Wait a bit for async init to complete
        try? await Task.sleep(for: .milliseconds(100))

        // Should have default settings (no file exists in temp location)
        XCTAssertFalse(settingsViewModel.settings.editor.openInlineLink)
        XCTAssertEqual(settingsViewModel.settings.markdown.enableTable, true)
    }

    func testSettingsViewModelAutoSave() async throws {
        // Wait for initial load
        try await Task.sleep(for: .milliseconds(100))

        // Modify settings
        settingsViewModel.settings.editor.openInlineLink = true

        // Wait for debounced auto-save (1 second + buffer)
        try await Task.sleep(for: .milliseconds(1200))

        // Verify saved to disk
        let loaded = try await settingsRepository.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.editor.openInlineLink, true, "Should auto-save changes")
    }

    func testSettingsViewModelResetToDefaults() async throws {
        // Wait for initial load
        try await Task.sleep(for: .milliseconds(100))

        // Modify settings
        settingsViewModel.settings.editor.openInlineLink = true
        settingsViewModel.settings.markdown.enableTable = false

        // Wait for auto-save
        try await Task.sleep(for: .milliseconds(1200))

        // Reset
        await settingsViewModel.resetToDefaults()

        // Verify reset
        XCTAssertFalse(settingsViewModel.settings.editor.openInlineLink)
        XCTAssertEqual(settingsViewModel.settings.markdown.enableTable, true)
    }

    // MARK: - Integration Tests

    func testFullSettingsPersistenceFlow() async throws {
        // 1. Initial state (defaults)
        XCTAssertFalse(settingsViewModel.settings.editor.openInlineLink)

        // 2. Modify settings
        settingsViewModel.settings.editor.openInlineLink = true
        settingsViewModel.settings.editor.debug = true
        settingsViewModel.settings.markdown.enableTable = false
        settingsViewModel.settings.markdown.enableStrikethrough = false
        settingsViewModel.settings.syntaxTheme.tabWidth = 8

        // 3. Wait for auto-save
        try await Task.sleep(for: .milliseconds(1200))

        // 4. Create new ViewModel (simulates app restart)
        let newLoadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepository)
        let newSaveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepository)
        let newValidateUseCase = ValidateSettingsUseCase()

        let newViewModel = SettingsViewModel(
            loadSettingsUseCase: newLoadUseCase,
            saveSettingsUseCase: newSaveUseCase,
            validateSettingsUseCase: newValidateUseCase
        )

        // 5. Wait for load
        try await Task.sleep(for: .milliseconds(100))

        // 6. Verify persisted values loaded
        XCTAssertEqual(newViewModel.settings.editor.openInlineLink, true)
        XCTAssertEqual(newViewModel.settings.editor.debug, true)
        XCTAssertEqual(newViewModel.settings.markdown.enableTable, false)
        XCTAssertEqual(newViewModel.settings.markdown.enableStrikethrough, false)
        XCTAssertEqual(newViewModel.settings.syntaxTheme.tabWidth, 8)
    }

    func testAllMarkdownSettingsRoundtrip() async throws {
        // Set all markdown settings to non-default values
        settingsViewModel.settings.markdown.enableAutolink = false
        settingsViewModel.settings.markdown.enableTable = false
        settingsViewModel.settings.markdown.enableTagFilter = false
        settingsViewModel.settings.markdown.enableTaskList = false
        settingsViewModel.settings.markdown.enableYAML = false
        settingsViewModel.settings.markdown.enableYAMLAll = true
        settingsViewModel.settings.markdown.enableStrikethrough = false
        settingsViewModel.settings.markdown.enableStrikethroughDoubleTilde = false
        settingsViewModel.settings.markdown.enableFootnotes = false
        settingsViewModel.settings.markdown.enableHardBreaks = true
        settingsViewModel.settings.markdown.disableSoftBreaks = true
        settingsViewModel.settings.markdown.allowUnsafeHTML = true
        settingsViewModel.settings.markdown.enableSmartQuotes = false
        settingsViewModel.settings.markdown.validateUTF8 = true

        // Wait for auto-save
        try await Task.sleep(for: .milliseconds(1200))

        // Load fresh
        let loaded = try await settingsRepository.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.markdown.enableAutolink, false)
        XCTAssertEqual(loaded?.markdown.enableTable, false)
        XCTAssertEqual(loaded?.markdown.enableStrikethrough, false)
        XCTAssertEqual(loaded?.markdown.validateUTF8, true)
    }
}
