//
//  SyntaxSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct SyntaxSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Syntax Highlighting") {
                Toggle("Enable syntax highlighting", isOn: $settingsViewModel.settings.syntaxTheme.enabled)
                    .help("Apply color syntax highlighting to fenced code blocks")

                if settingsViewModel.settings.syntaxTheme.enabled {
                    Toggle("Show line numbers", isOn: $settingsViewModel.settings.syntaxTheme.showLineNumbers)
                        .padding(.leading, 20)
                        .help("Display line numbers in code blocks")

                    HStack {
                        Text("Tab width:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Tab width", value: $settingsViewModel.settings.syntaxTheme.tabWidth, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("spaces")
                    }
                    .padding(.leading, 20)
                    .help("Number of spaces per tab character")

                    HStack {
                        Text("Word wrap:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Word wrap", value: $settingsViewModel.settings.syntaxTheme.wordWrapColumn, format: .number)
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
                Text("Note: Syntax highlighting currently shows plain monospaced text")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Future enhancement: SwiftHighlighter integration (github-light, github-dark themes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    let settingsRepo = SettingsRepositoryImpl()
    let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
    let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
    let validateUseCase = ValidateSettingsUseCase()

    let viewModel = SettingsViewModel(
        loadSettingsUseCase: loadUseCase,
        saveSettingsUseCase: saveUseCase,
        validateSettingsUseCase: validateUseCase
    )

    return SyntaxSettingsView()
        .environmentObject(viewModel)
        .frame(width: 600, height: 500)
}
