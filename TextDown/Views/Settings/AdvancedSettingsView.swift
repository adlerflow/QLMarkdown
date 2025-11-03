//
//  AdvancedSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("cmark Parser Options") {
                Toggle("Footnotes", isOn: $appState.enableFootnotes)
                    .help("Enable footnote syntax: [^1] and [^1]: footnote text")

                Toggle("Hard line breaks", isOn: $appState.enableHardBreaks)
                    .help("Treat single line breaks (\\n) as <br> tags")

                Toggle("Disable soft line breaks", isOn: $appState.disableSoftBreaks)
                    .help("Don't convert soft line breaks to spaces")

                Toggle("Allow unsafe HTML", isOn: $appState.allowUnsafeHTML)
                    .help("⚠️ Allow raw HTML in markdown (security risk!)")

                Toggle("Smart quotes", isOn: $appState.enableSmartQuotes)
                    .help("Convert straight quotes to \"curly quotes\"")

                Toggle("Validate UTF-8 strictly", isOn: $appState.validateUTF8)
                    .help("Enforce strict UTF-8 validation (may reject some files)")
            }

            Section("Reset") {
                Button("Reset All Settings to Factory Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)

                Text("This will reset all settings to their default values. Changes are auto-saved after 1 second.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }

    private func resetToDefaults() {
        let defaults = AppState()

        // UI Behavior
        appState.autoRefresh = defaults.autoRefresh
        appState.openInlineLink = defaults.openInlineLink
        appState.debug = defaults.debug
        appState.about = defaults.about

        // GitHub Flavored Markdown
        appState.enableAutolink = defaults.enableAutolink
        appState.enableTable = defaults.enableTable
        appState.enableTagFilter = defaults.enableTagFilter
        appState.enableTaskList = defaults.enableTaskList
        appState.enableYAML = defaults.enableYAML
        appState.enableYAMLAll = defaults.enableYAMLAll

        // Custom Extensions
        appState.enableCheckbox = defaults.enableCheckbox
        appState.enableEmoji = defaults.enableEmoji
        appState.enableEmojiImages = defaults.enableEmojiImages
        appState.enableHeads = defaults.enableHeads
        appState.enableHighlight = defaults.enableHighlight
        appState.enableInlineImage = defaults.enableInlineImage
        appState.enableMath = defaults.enableMath
        appState.enableMention = defaults.enableMention
        appState.enableStrikethrough = defaults.enableStrikethrough
        appState.enableStrikethroughDoubleTilde = defaults.enableStrikethroughDoubleTilde
        appState.enableSubscript = defaults.enableSubscript
        appState.enableSuperscript = defaults.enableSuperscript

        // Syntax Highlighting
        appState.enableSyntaxHighlighting = defaults.enableSyntaxHighlighting
        appState.syntaxLineNumbers = defaults.syntaxLineNumbers
        appState.syntaxTabWidth = defaults.syntaxTabWidth
        appState.syntaxWordWrap = defaults.syntaxWordWrap
        appState.syntaxThemeLight = defaults.syntaxThemeLight
        appState.syntaxThemeDark = defaults.syntaxThemeDark

        // Parser Options
        appState.enableFootnotes = defaults.enableFootnotes
        appState.enableHardBreaks = defaults.enableHardBreaks
        appState.disableSoftBreaks = defaults.disableSoftBreaks
        appState.allowUnsafeHTML = defaults.allowUnsafeHTML
        appState.enableSmartQuotes = defaults.enableSmartQuotes
        appState.validateUTF8 = defaults.validateUTF8

        // CSS Theming
        appState.customCSS = defaults.customCSS
        appState.customCSSCode = defaults.customCSSCode
        appState.customCSSFetched = defaults.customCSSFetched
        appState.customCSSOverride = defaults.customCSSOverride
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(AppState())
        .frame(width: 600, height: 500)
}
