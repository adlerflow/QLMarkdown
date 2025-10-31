//
//  SettingsViewModel.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    // GitHub Flavored Markdown Core (6 properties)
    @Published var tableExtension: Bool
    @Published var autoLinkExtension: Bool
    @Published var tagFilterExtension: Bool
    @Published var taskListExtension: Bool
    @Published var yamlExtension: Bool
    @Published var yamlExtensionAll: Bool

    // Custom Markdown Extensions (11 properties)
    @Published var emojiExtension: Bool
    @Published var emojiImageOption: Bool
    @Published var headsExtension: Bool
    @Published var highlightExtension: Bool
    @Published var inlineImageExtension: Bool
    @Published var mathExtension: Bool
    @Published var mentionExtension: Bool
    @Published var subExtension: Bool
    @Published var supExtension: Bool
    @Published var strikethroughExtension: Bool
    @Published var strikethroughDoubleTildeOption: Bool
    @Published var checkboxExtension: Bool

    // Syntax Highlighting (6 properties)
    @Published var syntaxHighlightExtension: Bool
    @Published var syntaxWordWrapOption: Int
    @Published var syntaxLineNumbersOption: Bool
    @Published var syntaxTabsOption: Int
    @Published var guessEngine: GuessEngine

    // cmark Parser Options (6 properties)
    @Published var footnotesOption: Bool
    @Published var hardBreakOption: Bool
    @Published var noSoftBreakOption: Bool
    @Published var unsafeHTMLOption: Bool
    @Published var smartQuotesOption: Bool
    @Published var validateUTFOption: Bool

    // CSS Theming (2 properties)
    @Published var customCSS: URL?
    @Published var customCSSOverride: Bool

    // Application Behavior (5 properties)
    @Published var openInlineLink: Bool
    @Published var renderAsCode: Bool
    @Published var qlWindowWidth: Int?
    @Published var qlWindowHeight: Int?
    @Published var about: Bool
    @Published var debug: Bool

    // MARK: - Change Tracking

    @Published var hasUnsavedChanges = false

    private var cancellables = Set<AnyCancellable>()
    private var originalSettings: Settings

    // MARK: - Initialization

    init(from settings: Settings) {
        self.originalSettings = settings

        // Initialize all properties from settings
        self.tableExtension = settings.tableExtension
        self.autoLinkExtension = settings.autoLinkExtension
        self.tagFilterExtension = settings.tagFilterExtension
        self.taskListExtension = settings.taskListExtension
        self.yamlExtension = settings.yamlExtension
        self.yamlExtensionAll = settings.yamlExtensionAll

        self.emojiExtension = settings.emojiExtension
        self.emojiImageOption = settings.emojiImageOption
        self.headsExtension = settings.headsExtension
        self.highlightExtension = settings.highlightExtension
        self.inlineImageExtension = settings.inlineImageExtension
        self.mathExtension = settings.mathExtension
        self.mentionExtension = settings.mentionExtension
        self.subExtension = settings.subExtension
        self.supExtension = settings.supExtension
        self.strikethroughExtension = settings.strikethroughExtension
        self.strikethroughDoubleTildeOption = settings.strikethroughDoubleTildeOption
        self.checkboxExtension = settings.checkboxExtension

        self.syntaxHighlightExtension = settings.syntaxHighlightExtension
        self.syntaxWordWrapOption = settings.syntaxWordWrapOption
        self.syntaxLineNumbersOption = settings.syntaxLineNumbersOption
        self.syntaxTabsOption = settings.syntaxTabsOption
        self.guessEngine = settings.guessEngine

        self.footnotesOption = settings.footnotesOption
        self.hardBreakOption = settings.hardBreakOption
        self.noSoftBreakOption = settings.noSoftBreakOption
        self.unsafeHTMLOption = settings.unsafeHTMLOption
        self.smartQuotesOption = settings.smartQuotesOption
        self.validateUTFOption = settings.validateUTFOption

        self.customCSS = settings.customCSS
        self.customCSSOverride = settings.customCSSOverride

        self.openInlineLink = settings.openInlineLink
        self.renderAsCode = settings.renderAsCode
        self.qlWindowWidth = settings.qlWindowWidth
        self.qlWindowHeight = settings.qlWindowHeight
        self.about = settings.about
        self.debug = settings.debug

        // Setup change tracking after initialization
        setupChangeTracking()
    }

    // MARK: - Change Tracking Setup

    private func setupChangeTracking() {
        // Monitor all @Published properties for changes
        $tableExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $autoLinkExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $tagFilterExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $taskListExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $yamlExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $yamlExtensionAll.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)

        $emojiExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $emojiImageOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $headsExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $highlightExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $inlineImageExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $mathExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $mentionExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $subExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $supExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $strikethroughExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $strikethroughDoubleTildeOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $checkboxExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)

        $syntaxHighlightExtension.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $syntaxWordWrapOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $syntaxLineNumbersOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $syntaxTabsOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $guessEngine.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)

        $footnotesOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $hardBreakOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $noSoftBreakOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $unsafeHTMLOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $smartQuotesOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $validateUTFOption.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)

        $customCSS.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $customCSSOverride.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)

        $openInlineLink.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $renderAsCode.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $qlWindowWidth.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $qlWindowHeight.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $about.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
        $debug.sink { [weak self] _ in self?.hasUnsavedChanges = true }.store(in: &cancellables)
    }

    // MARK: - Public Methods

    func apply() {
        // Update Settings.shared with all current values
        let settings = Settings.shared

        settings.tableExtension = tableExtension
        settings.autoLinkExtension = autoLinkExtension
        settings.tagFilterExtension = tagFilterExtension
        settings.taskListExtension = taskListExtension
        settings.yamlExtension = yamlExtension
        settings.yamlExtensionAll = yamlExtensionAll

        settings.emojiExtension = emojiExtension
        settings.emojiImageOption = emojiImageOption
        settings.headsExtension = headsExtension
        settings.highlightExtension = highlightExtension
        settings.inlineImageExtension = inlineImageExtension
        settings.mathExtension = mathExtension
        settings.mentionExtension = mentionExtension
        settings.subExtension = subExtension
        settings.supExtension = supExtension
        settings.strikethroughExtension = strikethroughExtension
        settings.strikethroughDoubleTildeOption = strikethroughDoubleTildeOption
        settings.checkboxExtension = checkboxExtension

        settings.syntaxHighlightExtension = syntaxHighlightExtension
        settings.syntaxWordWrapOption = syntaxWordWrapOption
        settings.syntaxLineNumbersOption = syntaxLineNumbersOption
        settings.syntaxTabsOption = syntaxTabsOption
        settings.guessEngine = guessEngine

        settings.footnotesOption = footnotesOption
        settings.hardBreakOption = hardBreakOption
        settings.noSoftBreakOption = noSoftBreakOption
        settings.unsafeHTMLOption = unsafeHTMLOption
        settings.smartQuotesOption = smartQuotesOption
        settings.validateUTFOption = validateUTFOption

        settings.customCSS = customCSS
        settings.customCSSOverride = customCSSOverride

        settings.openInlineLink = openInlineLink
        settings.renderAsCode = renderAsCode
        settings.qlWindowWidth = qlWindowWidth
        settings.qlWindowHeight = qlWindowHeight
        settings.about = about
        settings.debug = debug

        // Save to disk
        let (success, error) = settings.saveToSharedFile()
        if !success {
            print("Failed to save settings: \(error ?? "unknown error")")
        }

        // Update original settings and clear dirty flag
        originalSettings = settings
        hasUnsavedChanges = false
    }

    func cancel() {
        // Restore all properties from originalSettings
        tableExtension = originalSettings.tableExtension
        autoLinkExtension = originalSettings.autoLinkExtension
        tagFilterExtension = originalSettings.tagFilterExtension
        taskListExtension = originalSettings.taskListExtension
        yamlExtension = originalSettings.yamlExtension
        yamlExtensionAll = originalSettings.yamlExtensionAll

        emojiExtension = originalSettings.emojiExtension
        emojiImageOption = originalSettings.emojiImageOption
        headsExtension = originalSettings.headsExtension
        highlightExtension = originalSettings.highlightExtension
        inlineImageExtension = originalSettings.inlineImageExtension
        mathExtension = originalSettings.mathExtension
        mentionExtension = originalSettings.mentionExtension
        subExtension = originalSettings.subExtension
        supExtension = originalSettings.supExtension
        strikethroughExtension = originalSettings.strikethroughExtension
        strikethroughDoubleTildeOption = originalSettings.strikethroughDoubleTildeOption
        checkboxExtension = originalSettings.checkboxExtension

        syntaxHighlightExtension = originalSettings.syntaxHighlightExtension
        syntaxWordWrapOption = originalSettings.syntaxWordWrapOption
        syntaxLineNumbersOption = originalSettings.syntaxLineNumbersOption
        syntaxTabsOption = originalSettings.syntaxTabsOption
        guessEngine = originalSettings.guessEngine

        footnotesOption = originalSettings.footnotesOption
        hardBreakOption = originalSettings.hardBreakOption
        noSoftBreakOption = originalSettings.noSoftBreakOption
        unsafeHTMLOption = originalSettings.unsafeHTMLOption
        smartQuotesOption = originalSettings.smartQuotesOption
        validateUTFOption = originalSettings.validateUTFOption

        customCSS = originalSettings.customCSS
        customCSSOverride = originalSettings.customCSSOverride

        openInlineLink = originalSettings.openInlineLink
        renderAsCode = originalSettings.renderAsCode
        qlWindowWidth = originalSettings.qlWindowWidth
        qlWindowHeight = originalSettings.qlWindowHeight
        about = originalSettings.about
        debug = originalSettings.debug

        hasUnsavedChanges = false
    }

    func resetToDefaults() {
        let defaults = Settings()

        // Load factory defaults into all properties
        tableExtension = defaults.tableExtension
        autoLinkExtension = defaults.autoLinkExtension
        tagFilterExtension = defaults.tagFilterExtension
        taskListExtension = defaults.taskListExtension
        yamlExtension = defaults.yamlExtension
        yamlExtensionAll = defaults.yamlExtensionAll

        emojiExtension = defaults.emojiExtension
        emojiImageOption = defaults.emojiImageOption
        headsExtension = defaults.headsExtension
        highlightExtension = defaults.highlightExtension
        inlineImageExtension = defaults.inlineImageExtension
        mathExtension = defaults.mathExtension
        mentionExtension = defaults.mentionExtension
        subExtension = defaults.subExtension
        supExtension = defaults.supExtension
        strikethroughExtension = defaults.strikethroughExtension
        strikethroughDoubleTildeOption = defaults.strikethroughDoubleTildeOption
        checkboxExtension = defaults.checkboxExtension

        syntaxHighlightExtension = defaults.syntaxHighlightExtension
        syntaxWordWrapOption = defaults.syntaxWordWrapOption
        syntaxLineNumbersOption = defaults.syntaxLineNumbersOption
        syntaxTabsOption = defaults.syntaxTabsOption
        guessEngine = defaults.guessEngine

        footnotesOption = defaults.footnotesOption
        hardBreakOption = defaults.hardBreakOption
        noSoftBreakOption = defaults.noSoftBreakOption
        unsafeHTMLOption = defaults.unsafeHTMLOption
        smartQuotesOption = defaults.smartQuotesOption
        validateUTFOption = defaults.validateUTFOption

        customCSS = defaults.customCSS
        customCSSOverride = defaults.customCSSOverride

        openInlineLink = defaults.openInlineLink
        renderAsCode = defaults.renderAsCode
        qlWindowWidth = defaults.qlWindowWidth
        qlWindowHeight = defaults.qlWindowHeight
        about = defaults.about
        debug = defaults.debug

        hasUnsavedChanges = true
    }
}
