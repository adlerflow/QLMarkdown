//
//  SyntaxSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct SyntaxSettingsView: View {
    @Bindable var settings: AppConfiguration

    var body: some View {
        Form {
            Section("Syntax Highlighting") {
                Toggle("Enable syntax highlighting", isOn: $settings.syntaxHighlightExtension)
                    .help("Apply color syntax highlighting to fenced code blocks")

                if settings.syntaxHighlightExtension {
                    Toggle("Show line numbers", isOn: $settings.syntaxLineNumbersOption)
                        .padding(.leading, 20)
                        .help("Display line numbers in code blocks")

                    HStack {
                        Text("Tab width:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Tab width", value: $settings.syntaxTabsOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("spaces")
                    }
                    .padding(.leading, 20)
                    .help("Number of spaces per tab character")

                    HStack {
                        Text("Word wrap:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Word wrap", value: $settings.syntaxWordWrapOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("characters (0 = disabled)")
                    }
                    .padding(.leading, 20)
                    .help("Wrap lines at specified column (0 to disable)")
                }
            }

            Section("Language Detection") {
                Text("Note: Language detection only applies to code blocks without explicit language tags (e.g., ``` without specifying ```python).")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Language detection disabled in current version")
                    .foregroundStyle(.secondary)
            }

            Section("Theme") {
                // TODO: Implement theme selector with 12 highlight.js themes
                Text("Theme selector coming soon")
                    .foregroundStyle(.secondary)
                Text("Available themes: github, github-dark, atom-one-dark, monokai, nord, vs2015, xcode, and 5 more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try! encoder.encode(AppConfiguration.shared)
    let previewSettings = try! decoder.decode(AppConfiguration.self, from: data)

    SyntaxSettingsView(settings: previewSettings)
        .frame(width: 600, height: 500)
}
