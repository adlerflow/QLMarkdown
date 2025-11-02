//
//  SettingsTests.swift
//  TextDownTests
//
//  Created by Claude Code on 2025-11-02.
//  Phase 0: Test Suite Creation - Settings JSON Persistence Tests
//

import XCTest
@testable import TextDown

final class SettingsTests: XCTestCase {
    var settings: AppConfiguration!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        // Create a fresh settings instance by decoding factory settings
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try! encoder.encode(AppConfiguration.factorySettings)
        settings = try! decoder.decode(AppConfiguration.self, from: data)

        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        settings = nil
        tempDirectory = nil
        super.tearDown()
    }

    // MARK: - JSON Persistence Tests

    func testJSONRoundtrip() throws {
        // Set all 40 properties to non-default values

        // GFM Extensions (6)
        settings.tableExtension = false
        settings.autoLinkExtension = false
        settings.tagFilterExtension = false
        settings.taskListExtension = false
        settings.yamlExtension = false
        settings.yamlExtensionAll = true

        // Custom Extensions (11)
        settings.emojiExtension = false
        settings.emojiImageOption = true
        settings.headsExtension = false
        settings.highlightExtension = true
        settings.inlineImageExtension = false
        settings.mathExtension = false
        settings.mentionExtension = true
        settings.subExtension = true
        settings.supExtension = true
        settings.strikethroughExtension = false
        settings.strikethroughDoubleTildeOption = true
        settings.checkboxExtension = true

        // Syntax Highlighting (7)
        settings.syntaxHighlightExtension = false
        settings.syntaxWordWrapOption = 120
        settings.syntaxLineNumbersOption = true
        settings.syntaxTabsOption = 8
        settings.syntaxThemeLightOption = "solarized-light"
        settings.syntaxThemeDarkOption = "solarized-dark"

        // Parser Options (6)
        settings.footnotesOption = false
        settings.hardBreakOption = true
        settings.noSoftBreakOption = true
        settings.unsafeHTMLOption = true
        settings.smartQuotesOption = false
        settings.validateUTFOption = true

        // CSS Theming (4)
        settings.customCSS = URL(fileURLWithPath: "/tmp/custom.css")
        settings.customCSSCode = "body { color: red; }"
        settings.customCSSFetched = true
        settings.customCSSOverride = true

        // Application Behavior (6)
        settings.openInlineLink = true
        settings.renderAsCode = true
        settings.useLegacyPreview = true
        settings.qlWindowWidth = 1024
        settings.qlWindowHeight = 768
        settings.about = true
        settings.debug = true

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)

        // Decode from JSON
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppConfiguration.self, from: data)

        // Verify all 40 properties match

        // GFM Extensions
        XCTAssertEqual(decoded.tableExtension, settings.tableExtension, "tableExtension mismatch")
        XCTAssertEqual(decoded.autoLinkExtension, settings.autoLinkExtension, "autoLinkExtension mismatch")
        XCTAssertEqual(decoded.tagFilterExtension, settings.tagFilterExtension, "tagFilterExtension mismatch")
        XCTAssertEqual(decoded.taskListExtension, settings.taskListExtension, "taskListExtension mismatch")
        XCTAssertEqual(decoded.yamlExtension, settings.yamlExtension, "yamlExtension mismatch")
        XCTAssertEqual(decoded.yamlExtensionAll, settings.yamlExtensionAll, "yamlExtensionAll mismatch")

        // Custom Extensions
        XCTAssertEqual(decoded.emojiExtension, settings.emojiExtension, "emojiExtension mismatch")
        XCTAssertEqual(decoded.emojiImageOption, settings.emojiImageOption, "emojiImageOption mismatch")
        XCTAssertEqual(decoded.headsExtension, settings.headsExtension, "headsExtension mismatch")
        XCTAssertEqual(decoded.highlightExtension, settings.highlightExtension, "highlightExtension mismatch")
        XCTAssertEqual(decoded.inlineImageExtension, settings.inlineImageExtension, "inlineImageExtension mismatch")
        XCTAssertEqual(decoded.mathExtension, settings.mathExtension, "mathExtension mismatch")
        XCTAssertEqual(decoded.mentionExtension, settings.mentionExtension, "mentionExtension mismatch")
        XCTAssertEqual(decoded.subExtension, settings.subExtension, "subExtension mismatch")
        XCTAssertEqual(decoded.supExtension, settings.supExtension, "supExtension mismatch")
        XCTAssertEqual(decoded.strikethroughExtension, settings.strikethroughExtension, "strikethroughExtension mismatch")
        XCTAssertEqual(decoded.strikethroughDoubleTildeOption, settings.strikethroughDoubleTildeOption, "strikethroughDoubleTildeOption mismatch")
        XCTAssertEqual(decoded.checkboxExtension, settings.checkboxExtension, "checkboxExtension mismatch")

        // Syntax Highlighting
        XCTAssertEqual(decoded.syntaxHighlightExtension, settings.syntaxHighlightExtension, "syntaxHighlightExtension mismatch")
        XCTAssertEqual(decoded.syntaxWordWrapOption, settings.syntaxWordWrapOption, "syntaxWordWrapOption mismatch")
        XCTAssertEqual(decoded.syntaxLineNumbersOption, settings.syntaxLineNumbersOption, "syntaxLineNumbersOption mismatch")
        XCTAssertEqual(decoded.syntaxTabsOption, settings.syntaxTabsOption, "syntaxTabsOption mismatch")
        XCTAssertEqual(decoded.syntaxThemeLightOption, settings.syntaxThemeLightOption, "syntaxThemeLightOption mismatch")
        XCTAssertEqual(decoded.syntaxThemeDarkOption, settings.syntaxThemeDarkOption, "syntaxThemeDarkOption mismatch")

        // Parser Options
        XCTAssertEqual(decoded.footnotesOption, settings.footnotesOption, "footnotesOption mismatch")
        XCTAssertEqual(decoded.hardBreakOption, settings.hardBreakOption, "hardBreakOption mismatch")
        XCTAssertEqual(decoded.noSoftBreakOption, settings.noSoftBreakOption, "noSoftBreakOption mismatch")
        XCTAssertEqual(decoded.unsafeHTMLOption, settings.unsafeHTMLOption, "unsafeHTMLOption mismatch")
        XCTAssertEqual(decoded.smartQuotesOption, settings.smartQuotesOption, "smartQuotesOption mismatch")
        XCTAssertEqual(decoded.validateUTFOption, settings.validateUTFOption, "validateUTFOption mismatch")

        // CSS Theming
        XCTAssertEqual(decoded.customCSS, settings.customCSS, "customCSS mismatch")
        XCTAssertEqual(decoded.customCSSCode, settings.customCSSCode, "customCSSCode mismatch")
        XCTAssertEqual(decoded.customCSSFetched, settings.customCSSFetched, "customCSSFetched mismatch")
        XCTAssertEqual(decoded.customCSSOverride, settings.customCSSOverride, "customCSSOverride mismatch")

        // Application Behavior
        XCTAssertEqual(decoded.openInlineLink, settings.openInlineLink, "openInlineLink mismatch")
        XCTAssertEqual(decoded.renderAsCode, settings.renderAsCode, "renderAsCode mismatch")
        XCTAssertEqual(decoded.useLegacyPreview, settings.useLegacyPreview, "useLegacyPreview mismatch")
        XCTAssertEqual(decoded.qlWindowWidth, settings.qlWindowWidth, "qlWindowWidth mismatch")
        XCTAssertEqual(decoded.qlWindowHeight, settings.qlWindowHeight, "qlWindowHeight mismatch")
        XCTAssertEqual(decoded.about, settings.about, "about mismatch")
        XCTAssertEqual(decoded.debug, settings.debug, "debug mismatch")
    }

    func testFactoryDefaults() {
        let factory = AppConfiguration.factorySettings

        // Verify default values for all 40 properties

        // GFM Extensions (default: all true except yamlExtensionAll)
        XCTAssertTrue(factory.tableExtension, "tableExtension default should be true")
        XCTAssertTrue(factory.autoLinkExtension, "autoLinkExtension default should be true")
        XCTAssertTrue(factory.tagFilterExtension, "tagFilterExtension default should be true")
        XCTAssertTrue(factory.taskListExtension, "taskListExtension default should be true")
        XCTAssertTrue(factory.yamlExtension, "yamlExtension default should be true")
        XCTAssertFalse(factory.yamlExtensionAll, "yamlExtensionAll default should be false")

        // Custom Extensions
        XCTAssertTrue(factory.emojiExtension, "emojiExtension default should be true")
        XCTAssertFalse(factory.emojiImageOption, "emojiImageOption default should be false")
        XCTAssertTrue(factory.headsExtension, "headsExtension default should be true")
        XCTAssertFalse(factory.highlightExtension, "highlightExtension default should be false")
        XCTAssertTrue(factory.inlineImageExtension, "inlineImageExtension default should be true")
        XCTAssertTrue(factory.mathExtension, "mathExtension default should be true")
        XCTAssertFalse(factory.mentionExtension, "mentionExtension default should be false")
        XCTAssertFalse(factory.subExtension, "subExtension default should be false")
        XCTAssertFalse(factory.supExtension, "supExtension default should be false")
        XCTAssertTrue(factory.strikethroughExtension, "strikethroughExtension default should be true")
        XCTAssertFalse(factory.strikethroughDoubleTildeOption, "strikethroughDoubleTildeOption default should be false")
        XCTAssertFalse(factory.checkboxExtension, "checkboxExtension default should be false")

        // Syntax Highlighting
        XCTAssertTrue(factory.syntaxHighlightExtension, "syntaxHighlightExtension default should be true")
        XCTAssertEqual(factory.syntaxWordWrapOption, 0, "syntaxWordWrapOption default should be 0")
        XCTAssertFalse(factory.syntaxLineNumbersOption, "syntaxLineNumbersOption default should be false")
        XCTAssertEqual(factory.syntaxTabsOption, 4, "syntaxTabsOption default should be 4")
        XCTAssertEqual(factory.syntaxThemeLightOption, "github", "syntaxThemeLightOption default should be 'github'")
        XCTAssertEqual(factory.syntaxThemeDarkOption, "github-dark", "syntaxThemeDarkOption default should be 'github-dark'")

        // Parser Options
        XCTAssertTrue(factory.footnotesOption, "footnotesOption default should be true")
        XCTAssertFalse(factory.hardBreakOption, "hardBreakOption default should be false")
        XCTAssertFalse(factory.noSoftBreakOption, "noSoftBreakOption default should be false")
        XCTAssertFalse(factory.unsafeHTMLOption, "unsafeHTMLOption default should be false")
        XCTAssertTrue(factory.smartQuotesOption, "smartQuotesOption default should be true")
        XCTAssertFalse(factory.validateUTFOption, "validateUTFOption default should be false")

        // CSS Theming
        XCTAssertNil(factory.customCSS, "customCSS default should be nil")
        XCTAssertFalse(factory.customCSSFetched, "customCSSFetched default should be false")
        XCTAssertFalse(factory.customCSSOverride, "customCSSOverride default should be false")

        // Application Behavior
        XCTAssertFalse(factory.openInlineLink, "openInlineLink default should be false")
        XCTAssertFalse(factory.renderAsCode, "renderAsCode default should be false")
        XCTAssertNil(factory.qlWindowWidth, "qlWindowWidth default should be nil")
        XCTAssertNil(factory.qlWindowHeight, "qlWindowHeight default should be nil")
        XCTAssertFalse(factory.debug, "debug default should be false")
        XCTAssertFalse(factory.about, "about default should be false")
    }

    func testSettingsFileIO() throws {
        let fileURL = tempDirectory.appendingPathComponent("settings.json")

        // Set some non-default values
        settings.tableExtension = false
        settings.emojiExtension = false
        settings.syntaxThemeLightOption = "solarized-light"
        settings.qlWindowWidth = 800
        settings.qlWindowHeight = 600

        // Write settings to file
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        try data.write(to: fileURL, options: .atomic)

        // Verify file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "Settings file should exist")

        // Read settings from file
        let readData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode(AppConfiguration.self, from: readData)

        // Verify properties match
        XCTAssertEqual(loaded.tableExtension, settings.tableExtension)
        XCTAssertEqual(loaded.emojiExtension, settings.emojiExtension)
        XCTAssertEqual(loaded.syntaxThemeLightOption, settings.syntaxThemeLightOption)
        XCTAssertEqual(loaded.qlWindowWidth, settings.qlWindowWidth)
        XCTAssertEqual(loaded.qlWindowHeight, settings.qlWindowHeight)
    }

    // MARK: - Property Validation Tests

    func testSyntaxThemeValidation() {
        // Valid themes
        settings.syntaxThemeLightOption = "github"
        settings.syntaxThemeDarkOption = "github-dark"
        XCTAssertEqual(settings.syntaxThemeLightOption, "github")
        XCTAssertEqual(settings.syntaxThemeDarkOption, "github-dark")

        // Change to different valid themes
        settings.syntaxThemeLightOption = "solarized-light"
        settings.syntaxThemeDarkOption = "solarized-dark"
        XCTAssertEqual(settings.syntaxThemeLightOption, "solarized-light")
        XCTAssertEqual(settings.syntaxThemeDarkOption, "solarized-dark")

        // Invalid theme (should not crash, just store the value)
        settings.syntaxThemeLightOption = "nonexistent-theme"
        XCTAssertEqual(settings.syntaxThemeLightOption, "nonexistent-theme")
    }

    func testWindowSizeValidation() {
        // Valid sizes
        settings.qlWindowWidth = 800
        settings.qlWindowHeight = 600
        XCTAssertEqual(settings.qlWindowSize, CGSize(width: 800, height: 600))

        // Zero/negative values (should result in zero size)
        settings.qlWindowWidth = 0
        settings.qlWindowHeight = 0
        XCTAssertEqual(settings.qlWindowSize, CGSize(width: 0, height: 0))

        settings.qlWindowWidth = -100
        settings.qlWindowHeight = -100
        XCTAssertEqual(settings.qlWindowSize, CGSize(width: 0, height: 0))

        // Nil values (should result in zero size)
        settings.qlWindowWidth = nil
        settings.qlWindowHeight = nil
        XCTAssertEqual(settings.qlWindowSize, CGSize(width: 0, height: 0))

        // Mixed nil and valid
        settings.qlWindowWidth = 800
        settings.qlWindowHeight = nil
        XCTAssertEqual(settings.qlWindowSize, CGSize(width: 0, height: 0))
    }

    func testSyntaxTabsOption() {
        // Valid tab widths
        settings.syntaxTabsOption = 2
        XCTAssertEqual(settings.syntaxTabsOption, 2)

        settings.syntaxTabsOption = 4
        XCTAssertEqual(settings.syntaxTabsOption, 4)

        settings.syntaxTabsOption = 8
        XCTAssertEqual(settings.syntaxTabsOption, 8)

        // Edge cases
        settings.syntaxTabsOption = 0
        XCTAssertEqual(settings.syntaxTabsOption, 0)

        settings.syntaxTabsOption = 100
        XCTAssertEqual(settings.syntaxTabsOption, 100)
    }

    // MARK: - Computed Properties Tests

    func testAppVersion() {
        let version = settings.app_version
        XCTAssertFalse(version.isEmpty, "app_version should not be empty")
        XCTAssertTrue(version.contains("TextDown"), "app_version should contain 'TextDown'")
        // Should contain HTML link and version info
        XCTAssertTrue(version.contains("<a"), "app_version should contain HTML link")
    }

    func testAppVersion2() {
        let version2 = settings.app_version2
        XCTAssertFalse(version2.isEmpty, "app_version2 should not be empty")
        XCTAssertTrue(version2.contains("TextDown"), "app_version2 should contain 'TextDown'")
        // Should be an HTML comment
        XCTAssertTrue(version2.hasPrefix("<!--"), "app_version2 should start with HTML comment")
        XCTAssertTrue(version2.hasSuffix("-->\n"), "app_version2 should end with HTML comment")
    }

    func testResourceBundle() {
        let bundle = settings.resourceBundle
        XCTAssertNotNil(bundle, "resourceBundle should not be nil")

        // Verify key resources exist
        let defaultCSS = bundle.path(forResource: "default", ofType: "css")
        XCTAssertNotNil(defaultCSS, "default.css should exist in bundle")

        let highlightJS = bundle.path(forResource: "highlight.min", ofType: "js", inDirectory: "highlight.js/lib")
        XCTAssertNotNil(highlightJS, "highlight.js should exist in bundle")
    }

    // MARK: - Edge Cases

    func testEmptyCustomCSS() {
        settings.customCSS = nil
        settings.customCSSCode = nil
        settings.customCSSOverride = false

        XCTAssertNil(settings.customCSS)
        XCTAssertNil(settings.customCSSCode)
        XCTAssertFalse(settings.customCSSOverride)
    }

    func testMultipleExtensionsEnabled() {
        // Enable all extensions
        settings.tableExtension = true
        settings.emojiExtension = true
        settings.mathExtension = true
        settings.strikethroughExtension = true
        settings.headsExtension = true
        settings.syntaxHighlightExtension = true

        XCTAssertTrue(settings.tableExtension)
        XCTAssertTrue(settings.emojiExtension)
        XCTAssertTrue(settings.mathExtension)
        XCTAssertTrue(settings.strikethroughExtension)
        XCTAssertTrue(settings.headsExtension)
        XCTAssertTrue(settings.syntaxHighlightExtension)
    }

    func testAllExtensionsDisabled() {
        // Disable all extensions
        settings.tableExtension = false
        settings.autoLinkExtension = false
        settings.tagFilterExtension = false
        settings.taskListExtension = false
        settings.yamlExtension = false
        settings.emojiExtension = false
        settings.headsExtension = false
        settings.highlightExtension = false
        settings.inlineImageExtension = false
        settings.mathExtension = false
        settings.mentionExtension = false
        settings.subExtension = false
        settings.supExtension = false
        settings.strikethroughExtension = false
        settings.syntaxHighlightExtension = false
        settings.checkboxExtension = false

        XCTAssertFalse(settings.tableExtension)
        XCTAssertFalse(settings.autoLinkExtension)
        XCTAssertFalse(settings.emojiExtension)
        XCTAssertFalse(settings.mathExtension)
        XCTAssertFalse(settings.syntaxHighlightExtension)
    }
}
