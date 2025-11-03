//
//  SettingsTests.swift
//  TextDownTests
//
//  Created by Claude Code on 2025-11-02.
//  Updated for AppState migration on 2025-11-03
//  Phase 2: AppState JSON Persistence Tests
//

import XCTest
@testable import TextDown

@MainActor
final class SettingsTests: XCTestCase {
    var appState: AppState!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        // Create a fresh AppState instance (factory defaults)
        appState = AppState(loadFromDisk: false)

        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        appState = nil
        tempDirectory = nil
        super.tearDown()
    }

    // MARK: - JSON Persistence Tests

    func testJSONRoundtrip() throws {
        // Set all 39 properties to non-default values

        // UI Behavior (4)
        appState.autoRefresh = false
        appState.openInlineLink = true
        appState.debug = true
        appState.about = true

        // GFM Extensions (6)
        appState.enableTable = false
        appState.enableAutolink = false
        appState.enableTagFilter = false
        appState.enableTaskList = false
        appState.enableYAML = false
        appState.enableYAMLAll = true

        // Custom Extensions (12)
        appState.enableEmoji = false
        appState.enableEmojiImages = true
        appState.enableHeads = false
        appState.enableHighlight = true
        appState.enableInlineImage = false
        appState.enableMath = false
        appState.enableMention = true
        appState.enableSubscript = true
        appState.enableSuperscript = true
        appState.enableStrikethrough = false
        appState.enableStrikethroughDoubleTilde = true
        appState.enableCheckbox = true

        // Syntax Highlighting (6)
        appState.enableSyntaxHighlighting = false
        appState.syntaxLineNumbers = true
        appState.syntaxTabWidth = 8
        appState.syntaxWordWrap = 120
        appState.syntaxThemeLight = "solarized-light"
        appState.syntaxThemeDark = "solarized-dark"

        // Parser Options (6)
        appState.enableFootnotes = false
        appState.enableHardBreaks = true
        appState.disableSoftBreaks = true
        appState.allowUnsafeHTML = true
        appState.enableSmartQuotes = false
        appState.validateUTF8 = true

        // CSS Theming (4)
        appState.customCSS = URL(fileURLWithPath: "/tmp/custom.css")
        appState.customCSSCode = "body { color: red; }"
        appState.customCSSFetched = true
        appState.customCSSOverride = true

        // Create Settings struct
        let settings = Settings(
            autoRefresh: appState.autoRefresh,
            openInlineLink: appState.openInlineLink,
            debug: appState.debug,
            about: appState.about,
            enableAutolink: appState.enableAutolink,
            enableTable: appState.enableTable,
            enableTagFilter: appState.enableTagFilter,
            enableTaskList: appState.enableTaskList,
            enableYAML: appState.enableYAML,
            enableYAMLAll: appState.enableYAMLAll,
            enableCheckbox: appState.enableCheckbox,
            enableEmoji: appState.enableEmoji,
            enableEmojiImages: appState.enableEmojiImages,
            enableHeads: appState.enableHeads,
            enableHighlight: appState.enableHighlight,
            enableInlineImage: appState.enableInlineImage,
            enableMath: appState.enableMath,
            enableMention: appState.enableMention,
            enableStrikethrough: appState.enableStrikethrough,
            enableStrikethroughDoubleTilde: appState.enableStrikethroughDoubleTilde,
            enableSubscript: appState.enableSubscript,
            enableSuperscript: appState.enableSuperscript,
            enableSyntaxHighlighting: appState.enableSyntaxHighlighting,
            syntaxLineNumbers: appState.syntaxLineNumbers,
            syntaxTabWidth: appState.syntaxTabWidth,
            syntaxWordWrap: appState.syntaxWordWrap,
            syntaxThemeLight: appState.syntaxThemeLight,
            syntaxThemeDark: appState.syntaxThemeDark,
            enableFootnotes: appState.enableFootnotes,
            enableHardBreaks: appState.enableHardBreaks,
            disableSoftBreaks: appState.disableSoftBreaks,
            allowUnsafeHTML: appState.allowUnsafeHTML,
            enableSmartQuotes: appState.enableSmartQuotes,
            validateUTF8: appState.validateUTF8,
            customCSS: appState.customCSS,
            customCSSCode: appState.customCSSCode,
            customCSSFetched: appState.customCSSFetched,
            customCSSOverride: appState.customCSSOverride
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)

        // Decode from JSON
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Settings.self, from: data)

        // Verify all 39 properties match

        // UI Behavior
        XCTAssertEqual(decoded.autoRefresh, appState.autoRefresh, "autoRefresh mismatch")
        XCTAssertEqual(decoded.openInlineLink, appState.openInlineLink, "openInlineLink mismatch")
        XCTAssertEqual(decoded.debug, appState.debug, "debug mismatch")
        XCTAssertEqual(decoded.about, appState.about, "about mismatch")

        // GFM Extensions
        XCTAssertEqual(decoded.enableTable, appState.enableTable, "enableTable mismatch")
        XCTAssertEqual(decoded.enableAutolink, appState.enableAutolink, "enableAutolink mismatch")
        XCTAssertEqual(decoded.enableTagFilter, appState.enableTagFilter, "enableTagFilter mismatch")
        XCTAssertEqual(decoded.enableTaskList, appState.enableTaskList, "enableTaskList mismatch")
        XCTAssertEqual(decoded.enableYAML, appState.enableYAML, "enableYAML mismatch")
        XCTAssertEqual(decoded.enableYAMLAll, appState.enableYAMLAll, "enableYAMLAll mismatch")

        // Custom Extensions
        XCTAssertEqual(decoded.enableEmoji, appState.enableEmoji, "enableEmoji mismatch")
        XCTAssertEqual(decoded.enableEmojiImages, appState.enableEmojiImages, "enableEmojiImages mismatch")
        XCTAssertEqual(decoded.enableHeads, appState.enableHeads, "enableHeads mismatch")
        XCTAssertEqual(decoded.enableHighlight, appState.enableHighlight, "enableHighlight mismatch")
        XCTAssertEqual(decoded.enableInlineImage, appState.enableInlineImage, "enableInlineImage mismatch")
        XCTAssertEqual(decoded.enableMath, appState.enableMath, "enableMath mismatch")
        XCTAssertEqual(decoded.enableMention, appState.enableMention, "enableMention mismatch")
        XCTAssertEqual(decoded.enableSubscript, appState.enableSubscript, "enableSubscript mismatch")
        XCTAssertEqual(decoded.enableSuperscript, appState.enableSuperscript, "enableSuperscript mismatch")
        XCTAssertEqual(decoded.enableStrikethrough, appState.enableStrikethrough, "enableStrikethrough mismatch")
        XCTAssertEqual(decoded.enableStrikethroughDoubleTilde, appState.enableStrikethroughDoubleTilde, "enableStrikethroughDoubleTilde mismatch")
        XCTAssertEqual(decoded.enableCheckbox, appState.enableCheckbox, "enableCheckbox mismatch")

        // Syntax Highlighting
        XCTAssertEqual(decoded.enableSyntaxHighlighting, appState.enableSyntaxHighlighting, "enableSyntaxHighlighting mismatch")
        XCTAssertEqual(decoded.syntaxLineNumbers, appState.syntaxLineNumbers, "syntaxLineNumbers mismatch")
        XCTAssertEqual(decoded.syntaxTabWidth, appState.syntaxTabWidth, "syntaxTabWidth mismatch")
        XCTAssertEqual(decoded.syntaxWordWrap, appState.syntaxWordWrap, "syntaxWordWrap mismatch")
        XCTAssertEqual(decoded.syntaxThemeLight, appState.syntaxThemeLight, "syntaxThemeLight mismatch")
        XCTAssertEqual(decoded.syntaxThemeDark, appState.syntaxThemeDark, "syntaxThemeDark mismatch")

        // Parser Options
        XCTAssertEqual(decoded.enableFootnotes, appState.enableFootnotes, "enableFootnotes mismatch")
        XCTAssertEqual(decoded.enableHardBreaks, appState.enableHardBreaks, "enableHardBreaks mismatch")
        XCTAssertEqual(decoded.disableSoftBreaks, appState.disableSoftBreaks, "disableSoftBreaks mismatch")
        XCTAssertEqual(decoded.allowUnsafeHTML, appState.allowUnsafeHTML, "allowUnsafeHTML mismatch")
        XCTAssertEqual(decoded.enableSmartQuotes, appState.enableSmartQuotes, "enableSmartQuotes mismatch")
        XCTAssertEqual(decoded.validateUTF8, appState.validateUTF8, "validateUTF8 mismatch")

        // CSS Theming
        XCTAssertEqual(decoded.customCSS, appState.customCSS, "customCSS mismatch")
        XCTAssertEqual(decoded.customCSSCode, appState.customCSSCode, "customCSSCode mismatch")
        XCTAssertEqual(decoded.customCSSFetched, appState.customCSSFetched, "customCSSFetched mismatch")
        XCTAssertEqual(decoded.customCSSOverride, appState.customCSSOverride, "customCSSOverride mismatch")
    }

    func testFactoryDefaults() {
        let factory = AppState(loadFromDisk: false)

        // Verify default values for all 39 properties

        // UI Behavior
        XCTAssertTrue(factory.autoRefresh, "autoRefresh default should be true")
        XCTAssertFalse(factory.openInlineLink, "openInlineLink default should be false")
        XCTAssertFalse(factory.debug, "debug default should be false")
        XCTAssertFalse(factory.about, "about default should be false")

        // GFM Extensions (default: all true except enableYAMLAll)
        XCTAssertTrue(factory.enableTable, "enableTable default should be true")
        XCTAssertTrue(factory.enableAutolink, "enableAutolink default should be true")
        XCTAssertTrue(factory.enableTagFilter, "enableTagFilter default should be true")
        XCTAssertTrue(factory.enableTaskList, "enableTaskList default should be true")
        XCTAssertTrue(factory.enableYAML, "enableYAML default should be true")
        XCTAssertFalse(factory.enableYAMLAll, "enableYAMLAll default should be false")

        // Custom Extensions
        XCTAssertTrue(factory.enableEmoji, "enableEmoji default should be true")
        XCTAssertFalse(factory.enableEmojiImages, "enableEmojiImages default should be false")
        XCTAssertTrue(factory.enableHeads, "enableHeads default should be true")
        XCTAssertFalse(factory.enableHighlight, "enableHighlight default should be false")
        XCTAssertTrue(factory.enableInlineImage, "enableInlineImage default should be true")
        XCTAssertTrue(factory.enableMath, "enableMath default should be true")
        XCTAssertFalse(factory.enableMention, "enableMention default should be false")
        XCTAssertFalse(factory.enableSubscript, "enableSubscript default should be false")
        XCTAssertFalse(factory.enableSuperscript, "enableSuperscript default should be false")
        XCTAssertTrue(factory.enableStrikethrough, "enableStrikethrough default should be true")
        XCTAssertFalse(factory.enableStrikethroughDoubleTilde, "enableStrikethroughDoubleTilde default should be false")
        XCTAssertFalse(factory.enableCheckbox, "enableCheckbox default should be false")

        // Syntax Highlighting
        XCTAssertTrue(factory.enableSyntaxHighlighting, "enableSyntaxHighlighting default should be true")
        XCTAssertFalse(factory.syntaxLineNumbers, "syntaxLineNumbers default should be false")
        XCTAssertEqual(factory.syntaxTabWidth, 4, "syntaxTabWidth default should be 4")
        XCTAssertEqual(factory.syntaxWordWrap, 0, "syntaxWordWrap default should be 0")
        XCTAssertEqual(factory.syntaxThemeLight, "github", "syntaxThemeLight default should be 'github'")
        XCTAssertEqual(factory.syntaxThemeDark, "github-dark", "syntaxThemeDark default should be 'github-dark'")

        // Parser Options
        XCTAssertTrue(factory.enableFootnotes, "enableFootnotes default should be true")
        XCTAssertFalse(factory.enableHardBreaks, "enableHardBreaks default should be false")
        XCTAssertFalse(factory.disableSoftBreaks, "disableSoftBreaks default should be false")
        XCTAssertFalse(factory.allowUnsafeHTML, "allowUnsafeHTML default should be false")
        XCTAssertTrue(factory.enableSmartQuotes, "enableSmartQuotes default should be true")
        XCTAssertFalse(factory.validateUTF8, "validateUTF8 default should be false")

        // CSS Theming
        XCTAssertNil(factory.customCSS, "customCSS default should be nil")
        XCTAssertNil(factory.customCSSCode, "customCSSCode default should be nil")
        XCTAssertFalse(factory.customCSSFetched, "customCSSFetched default should be false")
        XCTAssertFalse(factory.customCSSOverride, "customCSSOverride default should be false")
    }

    func testSettingsFileIO() throws {
        let fileURL = tempDirectory.appendingPathComponent("settings.json")

        // Set some non-default values
        appState.enableTable = false
        appState.enableEmoji = false
        appState.syntaxThemeLight = "solarized-light"

        // Save settings using AppState method
        appState.saveSettings()

        // Manually write to our temp file for testing
        let settings = Settings(
            autoRefresh: appState.autoRefresh,
            openInlineLink: appState.openInlineLink,
            debug: appState.debug,
            about: appState.about,
            enableAutolink: appState.enableAutolink,
            enableTable: appState.enableTable,
            enableTagFilter: appState.enableTagFilter,
            enableTaskList: appState.enableTaskList,
            enableYAML: appState.enableYAML,
            enableYAMLAll: appState.enableYAMLAll,
            enableCheckbox: appState.enableCheckbox,
            enableEmoji: appState.enableEmoji,
            enableEmojiImages: appState.enableEmojiImages,
            enableHeads: appState.enableHeads,
            enableHighlight: appState.enableHighlight,
            enableInlineImage: appState.enableInlineImage,
            enableMath: appState.enableMath,
            enableMention: appState.enableMention,
            enableStrikethrough: appState.enableStrikethrough,
            enableStrikethroughDoubleTilde: appState.enableStrikethroughDoubleTilde,
            enableSubscript: appState.enableSubscript,
            enableSuperscript: appState.enableSuperscript,
            enableSyntaxHighlighting: appState.enableSyntaxHighlighting,
            syntaxLineNumbers: appState.syntaxLineNumbers,
            syntaxTabWidth: appState.syntaxTabWidth,
            syntaxWordWrap: appState.syntaxWordWrap,
            syntaxThemeLight: appState.syntaxThemeLight,
            syntaxThemeDark: appState.syntaxThemeDark,
            enableFootnotes: appState.enableFootnotes,
            enableHardBreaks: appState.enableHardBreaks,
            disableSoftBreaks: appState.disableSoftBreaks,
            allowUnsafeHTML: appState.allowUnsafeHTML,
            enableSmartQuotes: appState.enableSmartQuotes,
            validateUTF8: appState.validateUTF8,
            customCSS: appState.customCSS,
            customCSSCode: appState.customCSSCode,
            customCSSFetched: appState.customCSSFetched,
            customCSSOverride: appState.customCSSOverride
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        try data.write(to: fileURL, options: .atomic)

        // Verify file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "Settings file should exist")

        // Read settings from file
        let readData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode(Settings.self, from: readData)

        // Verify properties match
        XCTAssertEqual(loaded.enableTable, appState.enableTable)
        XCTAssertEqual(loaded.enableEmoji, appState.enableEmoji)
        XCTAssertEqual(loaded.syntaxThemeLight, appState.syntaxThemeLight)
    }

    // MARK: - Property Validation Tests

    func testSyntaxThemeValidation() {
        // Valid themes
        appState.syntaxThemeLight = "github"
        appState.syntaxThemeDark = "github-dark"
        XCTAssertEqual(appState.syntaxThemeLight, "github")
        XCTAssertEqual(appState.syntaxThemeDark, "github-dark")

        // Change to different valid themes
        appState.syntaxThemeLight = "solarized-light"
        appState.syntaxThemeDark = "solarized-dark"
        XCTAssertEqual(appState.syntaxThemeLight, "solarized-light")
        XCTAssertEqual(appState.syntaxThemeDark, "solarized-dark")

        // Invalid theme (should not crash, just store the value)
        appState.syntaxThemeLight = "nonexistent-theme"
        XCTAssertEqual(appState.syntaxThemeLight, "nonexistent-theme")
    }

    func testSyntaxTabWidth() {
        // Valid tab widths
        appState.syntaxTabWidth = 2
        XCTAssertEqual(appState.syntaxTabWidth, 2)

        appState.syntaxTabWidth = 4
        XCTAssertEqual(appState.syntaxTabWidth, 4)

        appState.syntaxTabWidth = 8
        XCTAssertEqual(appState.syntaxTabWidth, 8)

        // Edge cases
        appState.syntaxTabWidth = 0
        XCTAssertEqual(appState.syntaxTabWidth, 0)

        appState.syntaxTabWidth = 100
        XCTAssertEqual(appState.syntaxTabWidth, 100)
    }

    // MARK: - Edge Cases

    func testEmptyCustomCSS() {
        appState.customCSS = nil
        appState.customCSSCode = nil
        appState.customCSSOverride = false

        XCTAssertNil(appState.customCSS)
        XCTAssertNil(appState.customCSSCode)
        XCTAssertFalse(appState.customCSSOverride)
    }

    func testMultipleExtensionsEnabled() {
        // Enable all extensions
        appState.enableTable = true
        appState.enableEmoji = true
        appState.enableMath = true
        appState.enableStrikethrough = true
        appState.enableHeads = true
        appState.enableSyntaxHighlighting = true

        XCTAssertTrue(appState.enableTable)
        XCTAssertTrue(appState.enableEmoji)
        XCTAssertTrue(appState.enableMath)
        XCTAssertTrue(appState.enableStrikethrough)
        XCTAssertTrue(appState.enableHeads)
        XCTAssertTrue(appState.enableSyntaxHighlighting)
    }

    func testAllExtensionsDisabled() {
        // Disable all extensions
        appState.enableTable = false
        appState.enableAutolink = false
        appState.enableTagFilter = false
        appState.enableTaskList = false
        appState.enableYAML = false
        appState.enableEmoji = false
        appState.enableHeads = false
        appState.enableHighlight = false
        appState.enableInlineImage = false
        appState.enableMath = false
        appState.enableMention = false
        appState.enableSubscript = false
        appState.enableSuperscript = false
        appState.enableStrikethrough = false
        appState.enableSyntaxHighlighting = false
        appState.enableCheckbox = false

        XCTAssertFalse(appState.enableTable)
        XCTAssertFalse(appState.enableAutolink)
        XCTAssertFalse(appState.enableEmoji)
        XCTAssertFalse(appState.enableMath)
        XCTAssertFalse(appState.enableSyntaxHighlighting)
    }
}
