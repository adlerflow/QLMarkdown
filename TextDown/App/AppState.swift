import SwiftUI
import Combine
import Foundation

/// App-weiter State (ersetzt AppDelegate + AppConfiguration)
@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties

    // MARK: - UI Behavior
    @Published var autoRefresh: Bool = true
    @Published var openInlineLink: Bool = false
    @Published var debug: Bool = false
    @Published var about: Bool = false

    // MARK: - GitHub Flavored Markdown
    @Published var enableAutolink: Bool = true
    @Published var enableTable: Bool = true
    @Published var enableTagFilter: Bool = true
    @Published var enableTaskList: Bool = true
    @Published var enableYAML: Bool = true
    @Published var enableYAMLAll: Bool = false

    // MARK: - Custom Extensions
    @Published var enableCheckbox: Bool = false
    @Published var enableEmoji: Bool = true
    @Published var enableEmojiImages: Bool = false
    @Published var enableHeads: Bool = true
    @Published var enableHighlight: Bool = false
    @Published var enableInlineImage: Bool = true
    @Published var enableMath: Bool = true
    @Published var enableMention: Bool = false
    @Published var enableStrikethrough: Bool = true
    @Published var enableStrikethroughDoubleTilde: Bool = false
    @Published var enableSubscript: Bool = false
    @Published var enableSuperscript: Bool = false

    // MARK: - Syntax Highlighting
    @Published var enableSyntaxHighlighting: Bool = true
    @Published var syntaxLineNumbers: Bool = false
    @Published var syntaxTabWidth: Int = 4
    @Published var syntaxWordWrap: Int = 0
    @Published var syntaxThemeLight: String = "github"
    @Published var syntaxThemeDark: String = "github-dark"

    // MARK: - Parser Options
    @Published var enableFootnotes: Bool = true
    @Published var enableHardBreaks: Bool = false
    @Published var disableSoftBreaks: Bool = false
    @Published var allowUnsafeHTML: Bool = false
    @Published var enableSmartQuotes: Bool = true
    @Published var validateUTF8: Bool = false

    // MARK: - Custom CSS
    @Published var customCSS: URL? = nil
    @Published var customCSSCode: String? = nil
    @Published var customCSSFetched: Bool = false
    @Published var customCSSOverride: Bool = false

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

        // UI Behavior
        autoRefresh = decoded.autoRefresh
        openInlineLink = decoded.openInlineLink
        debug = decoded.debug
        about = decoded.about

        // GFM
        enableAutolink = decoded.enableAutolink
        enableTable = decoded.enableTable
        enableTagFilter = decoded.enableTagFilter
        enableTaskList = decoded.enableTaskList
        enableYAML = decoded.enableYAML
        enableYAMLAll = decoded.enableYAMLAll

        // Custom Extensions
        enableCheckbox = decoded.enableCheckbox
        enableEmoji = decoded.enableEmoji
        enableEmojiImages = decoded.enableEmojiImages
        enableHeads = decoded.enableHeads
        enableHighlight = decoded.enableHighlight
        enableInlineImage = decoded.enableInlineImage
        enableMath = decoded.enableMath
        enableMention = decoded.enableMention
        enableStrikethrough = decoded.enableStrikethrough
        enableStrikethroughDoubleTilde = decoded.enableStrikethroughDoubleTilde
        enableSubscript = decoded.enableSubscript
        enableSuperscript = decoded.enableSuperscript

        // Syntax
        enableSyntaxHighlighting = decoded.enableSyntaxHighlighting
        syntaxLineNumbers = decoded.syntaxLineNumbers
        syntaxTabWidth = decoded.syntaxTabWidth
        syntaxWordWrap = decoded.syntaxWordWrap
        syntaxThemeLight = decoded.syntaxThemeLight
        syntaxThemeDark = decoded.syntaxThemeDark

        // Parser
        enableFootnotes = decoded.enableFootnotes
        enableHardBreaks = decoded.enableHardBreaks
        disableSoftBreaks = decoded.disableSoftBreaks
        allowUnsafeHTML = decoded.allowUnsafeHTML
        enableSmartQuotes = decoded.enableSmartQuotes
        validateUTF8 = decoded.validateUTF8

        // CSS
        customCSS = decoded.customCSS
        customCSSCode = decoded.customCSSCode
        customCSSFetched = decoded.customCSSFetched
        customCSSOverride = decoded.customCSSOverride
    }

    func saveSettings() {
        let settings = Settings(
            // UI Behavior
            autoRefresh: autoRefresh,
            openInlineLink: openInlineLink,
            debug: debug,
            about: about,
            // GFM
            enableAutolink: enableAutolink,
            enableTable: enableTable,
            enableTagFilter: enableTagFilter,
            enableTaskList: enableTaskList,
            enableYAML: enableYAML,
            enableYAMLAll: enableYAMLAll,
            // Custom Extensions
            enableCheckbox: enableCheckbox,
            enableEmoji: enableEmoji,
            enableEmojiImages: enableEmojiImages,
            enableHeads: enableHeads,
            enableHighlight: enableHighlight,
            enableInlineImage: enableInlineImage,
            enableMath: enableMath,
            enableMention: enableMention,
            enableStrikethrough: enableStrikethrough,
            enableStrikethroughDoubleTilde: enableStrikethroughDoubleTilde,
            enableSubscript: enableSubscript,
            enableSuperscript: enableSuperscript,
            // Syntax
            enableSyntaxHighlighting: enableSyntaxHighlighting,
            syntaxLineNumbers: syntaxLineNumbers,
            syntaxTabWidth: syntaxTabWidth,
            syntaxWordWrap: syntaxWordWrap,
            syntaxThemeLight: syntaxThemeLight,
            syntaxThemeDark: syntaxThemeDark,
            // Parser
            enableFootnotes: enableFootnotes,
            enableHardBreaks: enableHardBreaks,
            disableSoftBreaks: disableSoftBreaks,
            allowUnsafeHTML: allowUnsafeHTML,
            enableSmartQuotes: enableSmartQuotes,
            validateUTF8: validateUTF8,
            // CSS
            customCSS: customCSS,
            customCSSCode: customCSSCode,
            customCSSFetched: customCSSFetched,
            customCSSOverride: customCSSOverride
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
        // Auto-save when any property changes (debounced 1 second)
        // Using objectWillChange publisher for all @Published properties
        objectWillChange
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Settings Models

struct Settings: Codable {
    // UI Behavior
    var autoRefresh: Bool
    var openInlineLink: Bool
    var debug: Bool
    var about: Bool

    // GFM
    var enableAutolink: Bool
    var enableTable: Bool
    var enableTagFilter: Bool
    var enableTaskList: Bool
    var enableYAML: Bool
    var enableYAMLAll: Bool

    // Custom Extensions
    var enableCheckbox: Bool
    var enableEmoji: Bool
    var enableEmojiImages: Bool
    var enableHeads: Bool
    var enableHighlight: Bool
    var enableInlineImage: Bool
    var enableMath: Bool
    var enableMention: Bool
    var enableStrikethrough: Bool
    var enableStrikethroughDoubleTilde: Bool
    var enableSubscript: Bool
    var enableSuperscript: Bool

    // Syntax
    var enableSyntaxHighlighting: Bool
    var syntaxLineNumbers: Bool
    var syntaxTabWidth: Int
    var syntaxWordWrap: Int
    var syntaxThemeLight: String
    var syntaxThemeDark: String

    // Parser
    var enableFootnotes: Bool
    var enableHardBreaks: Bool
    var disableSoftBreaks: Bool
    var allowUnsafeHTML: Bool
    var enableSmartQuotes: Bool
    var validateUTF8: Bool

    // CSS
    var customCSS: URL?
    var customCSSCode: String?
    var customCSSFetched: Bool
    var customCSSOverride: Bool
}
