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
                        Toggle("Apply to all files (not just .rmd/.qmd)", isOn: $settingsViewModel.settings.markdown.enableYAMLAll)
                            .padding(.leading, 20)
                            .help("Parse YAML in all markdown files instead of only R Markdown files")
                    }
                }
            }

            Section("Custom Extensions") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Emoji", isOn: $settingsViewModel.settings.markdown.enableEmoji)
                        .help("Convert :emoji_name: to emoji characters (e.g., :smile: → 😄)")

                    if settingsViewModel.settings.markdown.enableEmoji {
                        Toggle("Render as images instead of font", isOn: $settingsViewModel.settings.markdown.enableEmojiImages)
                            .padding(.leading, 20)
                            .help("Use emoji images instead of system font")
                    }
                }

                Toggle("Headline anchors", isOn: $settingsViewModel.settings.markdown.enableHeads)
                    .help("Automatically generate id attributes for headlines (e.g., ## Hello → <h2 id=\"hello\">)")

                Toggle("Highlight", isOn: $settingsViewModel.settings.markdown.enableHighlight)
                    .help("Enable ==highlighted text== syntax")

                Toggle("Inline images", isOn: $settingsViewModel.settings.markdown.enableInlineImage)
                    .help("Embed local images as Base64 data URLs")

                Toggle("Math (LaTeX)", isOn: $settingsViewModel.settings.markdown.enableMath)
                    .help("Render LaTeX math expressions: $inline$ or $$display$$")

                Toggle("Mentions", isOn: $settingsViewModel.settings.markdown.enableMention)
                    .help("Convert @username to GitHub profile links")

                Toggle("Subscript", isOn: $settingsViewModel.settings.markdown.enableSubscript)
                    .help("Enable subscript syntax: ~text~")

                Toggle("Superscript", isOn: $settingsViewModel.settings.markdown.enableSuperscript)
                    .help("Enable superscript syntax: ^text^")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Strikethrough", isOn: $settingsViewModel.settings.markdown.enableStrikethrough)
                        .help("Enable strikethrough text")

                    if settingsViewModel.settings.markdown.enableStrikethrough {
                        Toggle("Use double-tilde (~~text~~) instead of single (~text~)", isOn: $settingsViewModel.settings.markdown.enableStrikethroughDoubleTilde)
                            .padding(.leading, 20)
                            .help("Require ~~double~~ instead of ~single~ tilde syntax")
                    }
                }

                Toggle("Custom checkbox styling", isOn: $settingsViewModel.settings.markdown.enableCheckbox)
                    .help("Apply custom CSS styling to task list checkboxes")
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
