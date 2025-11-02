//
//  TextDownSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI
import OSLog

struct TextDownSettingsView: View {
    @State private var draftSettings: Settings
    @State private var originalSettings: Settings
    @Environment(\.dismiss) var dismiss

    init() {
        // Create deep copies for draft and original
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        if let data = try? encoder.encode(AppConfiguration.shared),
           let copy1 = try? decoder.decode(Settings.self, from: data),
           let copy2 = try? decoder.decode(Settings.self, from: data) {
            _draftSettings = State(initialValue: copy1)
            _originalSettings = State(initialValue: copy2)
        } else {
            // Fallback: use shared instance
            _draftSettings = State(initialValue: AppConfiguration.shared)
            _originalSettings = State(initialValue: AppConfiguration.shared)
        }
    }

    private var hasChanges: Bool {
        // Compare draft to original using JSON encoding
        let encoder = JSONEncoder()
        let draftData = try? encoder.encode(draftSettings)
        let originalData = try? encoder.encode(originalSettings)
        return draftData != originalData
    }

    var body: some View {
        TabView {
            GeneralSettingsView(settings: draftSettings)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            ExtensionsSettingsView(settings: draftSettings)
                .tabItem {
                    Label("Extensions", systemImage: "puzzlepiece.extension")
                }

            SyntaxSettingsView(settings: draftSettings)
                .tabItem {
                    Label("Syntax", systemImage: "chevron.left.forwardslash.chevron.right")
                }

            AdvancedSettingsView(settings: draftSettings)
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2")
                }
        }
        .frame(width: 650, height: 550)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }

            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Apply") {
                    applyChanges()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!hasChanges)
            }
        }
    }

    private func applyChanges() {
        // Copy all properties from draft to AppConfiguration.shared
        let shared = AppConfiguration.shared

        // GitHub Flavored Markdown
        shared.tableExtension = draftSettings.tableExtension
        shared.autoLinkExtension = draftSettings.autoLinkExtension
        shared.tagFilterExtension = draftSettings.tagFilterExtension
        shared.taskListExtension = draftSettings.taskListExtension
        shared.yamlExtension = draftSettings.yamlExtension
        shared.yamlExtensionAll = draftSettings.yamlExtensionAll

        // Custom Extensions
        shared.emojiExtension = draftSettings.emojiExtension
        shared.emojiImageOption = draftSettings.emojiImageOption
        shared.headsExtension = draftSettings.headsExtension
        shared.highlightExtension = draftSettings.highlightExtension
        shared.inlineImageExtension = draftSettings.inlineImageExtension
        shared.mathExtension = draftSettings.mathExtension
        shared.mentionExtension = draftSettings.mentionExtension
        shared.subExtension = draftSettings.subExtension
        shared.supExtension = draftSettings.supExtension
        shared.strikethroughExtension = draftSettings.strikethroughExtension
        shared.strikethroughDoubleTildeOption = draftSettings.strikethroughDoubleTildeOption
        shared.checkboxExtension = draftSettings.checkboxExtension

        // Syntax Highlighting
        shared.syntaxHighlightExtension = draftSettings.syntaxHighlightExtension
        shared.syntaxWordWrapOption = draftSettings.syntaxWordWrapOption
        shared.syntaxLineNumbersOption = draftSettings.syntaxLineNumbersOption
        shared.syntaxTabsOption = draftSettings.syntaxTabsOption
        shared.syntaxThemeLightOption = draftSettings.syntaxThemeLightOption
        shared.syntaxThemeDarkOption = draftSettings.syntaxThemeDarkOption

        // Parser Options
        shared.footnotesOption = draftSettings.footnotesOption
        shared.hardBreakOption = draftSettings.hardBreakOption
        shared.noSoftBreakOption = draftSettings.noSoftBreakOption
        shared.unsafeHTMLOption = draftSettings.unsafeHTMLOption
        shared.smartQuotesOption = draftSettings.smartQuotesOption
        shared.validateUTFOption = draftSettings.validateUTFOption

        // CSS Theming
        shared.customCSS = draftSettings.customCSS
        shared.customCSSOverride = draftSettings.customCSSOverride

        // Application Behavior
        shared.openInlineLink = draftSettings.openInlineLink
        shared.renderAsCode = draftSettings.renderAsCode
        shared.qlWindowWidth = draftSettings.qlWindowWidth
        shared.qlWindowHeight = draftSettings.qlWindowHeight
        shared.about = draftSettings.about
        shared.debug = draftSettings.debug

        // Save to disk
        let (success, error) = shared.saveToSharedFile()
        if !success {
            os_log(.error, log: .settings, "Failed to save settings: %{public}@",
                   error ?? "unknown error")
        }
    }
}

#Preview {
    TextDownSettingsView()
        .frame(width: 650, height: 550)
}
