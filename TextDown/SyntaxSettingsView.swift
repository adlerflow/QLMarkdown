//
//  SyntaxSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct SyntaxSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Syntax Highlighting") {
                Toggle("Enable syntax highlighting", isOn: $viewModel.syntaxHighlightExtension)
                    .help("Apply color syntax highlighting to fenced code blocks")

                if viewModel.syntaxHighlightExtension {
                    Toggle("Show line numbers", isOn: $viewModel.syntaxLineNumbersOption)
                        .padding(.leading, 20)
                        .help("Display line numbers in code blocks")

                    HStack {
                        Text("Tab width:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Tab width", value: $viewModel.syntaxTabsOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("spaces")
                    }
                    .padding(.leading, 20)
                    .help("Number of spaces per tab character")

                    HStack {
                        Text("Word wrap:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Word wrap", value: $viewModel.syntaxWordWrapOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("characters (0 = disabled)")
                    }
                    .padding(.leading, 20)
                    .help("Wrap lines at specified column (0 to disable)")
                }
            }

            Section("Language Detection") {
                Picker("Detect language for unmarked code blocks:", selection: $viewModel.guessEngine) {
                    Text("Disabled").tag(GuessEngine.none)
                    Text("Simple (libmagic MIME)").tag(GuessEngine.simple)
                    Text("Accurate (GitHub Linguist)").tag(GuessEngine.accurate)
                }
                .pickerStyle(.radioGroup)
                .help("Automatically detect programming language when code fence has no language tag")

                Text("Note: Language detection only applies to code blocks without explicit language tags (e.g., ``` without specifying ```python).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            Section("Theme") {
                // TODO: Implement theme selector with 97 themes
                Text("Theme selector coming soon")
                    .foregroundStyle(.secondary)
                Text("Themes: solarized-dark, github, zenburn, and 94 more available in highlight/themes/")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    SyntaxSettingsView(viewModel: SettingsViewModel(from: Settings.shared))
        .frame(width: 600, height: 500)
}
