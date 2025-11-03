//
//  ExtensionsSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct ExtensionsSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("GitHub Flavored Markdown") {
                Toggle("Tables", isOn: $settingsViewModel.settings.markdown.enableTable)
                    .help("Enable GitHub-style table syntax")

                Toggle("Autolink", isOn: $settingsViewModel.settings.markdown.enableAutolink)
                    .help("Automatically convert URLs to links")

                Toggle("Tag filter", isOn: $settingsViewModel.settings.markdown.enableTagFilter)
                    .help("Filter unsafe HTML tags")

                Toggle("Task lists", isOn: $settingsViewModel.settings.markdown.enableTaskList)
                    .help("Enable checkbox task lists: - [ ] unchecked, - [x] checked")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("YAML headers", isOn: $settingsViewModel.settings.markdown.enableYAML)
                        .help("Parse YAML front-matter in documents")

                    if settingsViewModel.settings.markdown.enableYAML {
                        HStack {
                            Toggle("Apply to all files (not just .rmd/.qmd)", isOn: $settingsViewModel.settings.markdown.enableYAMLAll)
                        }
                        .help("Parse YAML in all markdown files instead of only R Markdown files")
                        .padding(.leading, 20)
                    }
                }
            }

            Section("GFM Extensions") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Strikethrough", isOn: $settingsViewModel.settings.markdown.enableStrikethrough)
                        .help("Enable strikethrough text")

                    if settingsViewModel.settings.markdown.enableStrikethrough {
                        HStack {
                            Toggle("Use double-tilde (~~) instead of single-tilde (~)", isOn: $settingsViewModel.settings.markdown.enableStrikethroughDoubleTilde)
                        }
                        .help("Require double-tilde syntax")
                        .padding(.leading, 20)
                    }
                }
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

    return ExtensionsSettingsView()
        .environmentObject(viewModel)
        .frame(width: 600, height: 500)
}
