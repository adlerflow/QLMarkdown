//
//  AdvancedSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @Bindable var settings: Settings

    var body: some View {
        Form {
            Section("cmark Parser Options") {
                Toggle("Footnotes", isOn: $settings.footnotesOption)
                    .help("Enable footnote syntax: [^1] and [^1]: footnote text")

                Toggle("Hard line breaks", isOn: $settings.hardBreakOption)
                    .help("Treat single line breaks (\\n) as <br> tags")

                Toggle("Disable soft line breaks", isOn: $settings.noSoftBreakOption)
                    .help("Don't convert soft line breaks to spaces")

                Toggle("Allow unsafe HTML", isOn: $settings.unsafeHTMLOption)
                    .help("⚠️ Allow raw HTML in markdown (security risk!)")

                Toggle("Smart quotes", isOn: $settings.smartQuotesOption)
                    .help("Convert straight quotes to \"curly quotes\"")

                Toggle("Validate UTF-8 strictly", isOn: $settings.validateUTFOption)
                    .help("Enforce strict UTF-8 validation (may reject some files)")
            }

            Section("Rendering") {
                Toggle("Render as code", isOn: $settings.renderAsCode)
                    .help("Escape HTML and render markdown as plain code block")
            }

            Section("Reset") {
                Button("Reset All Settings to Factory Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)

                Text("This will reset all settings to their default values. You must click Apply to save changes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }

    private func resetToDefaults() {
        let defaults = Settings()

        // GitHub Flavored Markdown
        settings.tableExtension = defaults.tableExtension
        settings.autoLinkExtension = defaults.autoLinkExtension
        settings.tagFilterExtension = defaults.tagFilterExtension
        settings.taskListExtension = defaults.taskListExtension
        settings.yamlExtension = defaults.yamlExtension
        settings.yamlExtensionAll = defaults.yamlExtensionAll

        // Custom Extensions
        settings.emojiExtension = defaults.emojiExtension
        settings.emojiImageOption = defaults.emojiImageOption
        settings.headsExtension = defaults.headsExtension
        settings.highlightExtension = defaults.highlightExtension
        settings.inlineImageExtension = defaults.inlineImageExtension
        settings.mathExtension = defaults.mathExtension
        settings.mentionExtension = defaults.mentionExtension
        settings.subExtension = defaults.subExtension
        settings.supExtension = defaults.supExtension
        settings.strikethroughExtension = defaults.strikethroughExtension
        settings.strikethroughDoubleTildeOption = defaults.strikethroughDoubleTildeOption
        settings.checkboxExtension = defaults.checkboxExtension

        // Syntax Highlighting
        settings.syntaxHighlightExtension = defaults.syntaxHighlightExtension
        settings.syntaxWordWrapOption = defaults.syntaxWordWrapOption
        settings.syntaxLineNumbersOption = defaults.syntaxLineNumbersOption
        settings.syntaxTabsOption = defaults.syntaxTabsOption
        settings.syntaxThemeLightOption = defaults.syntaxThemeLightOption
        settings.syntaxThemeDarkOption = defaults.syntaxThemeDarkOption

        // Parser Options
        settings.footnotesOption = defaults.footnotesOption
        settings.hardBreakOption = defaults.hardBreakOption
        settings.noSoftBreakOption = defaults.noSoftBreakOption
        settings.unsafeHTMLOption = defaults.unsafeHTMLOption
        settings.smartQuotesOption = defaults.smartQuotesOption
        settings.validateUTFOption = defaults.validateUTFOption

        // CSS Theming
        settings.customCSS = defaults.customCSS
        settings.customCSSOverride = defaults.customCSSOverride

        // Application Behavior
        settings.openInlineLink = defaults.openInlineLink
        settings.renderAsCode = defaults.renderAsCode
        settings.qlWindowWidth = defaults.qlWindowWidth
        settings.qlWindowHeight = defaults.qlWindowHeight
        settings.about = defaults.about
        settings.debug = defaults.debug
    }
}

#Preview {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try! encoder.encode(Settings.shared)
    let previewSettings = try! decoder.decode(Settings.self, from: data)

    return AdvancedSettingsView(settings: previewSettings)
        .frame(width: 600, height: 500)
}
