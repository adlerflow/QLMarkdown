//
//  ExtensionsSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct ExtensionsSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("GitHub Flavored Markdown") {
                Toggle("Tables", isOn: $viewModel.tableExtension)
                    .help("Enable GitHub-style table syntax")

                Toggle("Autolink", isOn: $viewModel.autoLinkExtension)
                    .help("Automatically convert URLs to links")

                Toggle("Tag filter", isOn: $viewModel.tagFilterExtension)
                    .help("Filter unsafe HTML tags")

                Toggle("Task lists", isOn: $viewModel.taskListExtension)
                    .help("Enable checkbox task lists: - [ ] unchecked, - [x] checked")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("YAML headers", isOn: $viewModel.yamlExtension)
                        .help("Parse YAML front-matter in documents")

                    if viewModel.yamlExtension {
                        Toggle("Apply to all files (not just .rmd/.qmd)", isOn: $viewModel.yamlExtensionAll)
                            .help("Parse YAML in all markdown files instead of only R Markdown files")
                            .padding(.leading, 20)
                    }
                }
            }

            Section("Custom Extensions") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Emoji", isOn: $viewModel.emojiExtension)
                        .help("Convert :emoji_name: to emoji characters (e.g., :smile: → 😄)")

                    if viewModel.emojiExtension {
                        Toggle("Render as images instead of font", isOn: $viewModel.emojiImageOption)
                            .help("Use emoji images instead of system font")
                            .padding(.leading, 20)
                    }
                }

                Toggle("Headline anchors", isOn: $viewModel.headsExtension)
                    .help("Automatically generate id attributes for headlines (e.g., ## Hello → <h2 id=\"hello\">)")

                Toggle("Highlight", isOn: $viewModel.highlightExtension)
                    .help("Enable ==highlighted text== syntax")

                Toggle("Inline images", isOn: $viewModel.inlineImageExtension)
                    .help("Embed local images as Base64 data URLs")

                Toggle("Math (LaTeX)", isOn: $viewModel.mathExtension)
                    .help("Render LaTeX math expressions: $inline$ or $$display$$")

                Toggle("Mentions", isOn: $viewModel.mentionExtension)
                    .help("Convert @username to GitHub profile links")

                Toggle("Subscript", isOn: $viewModel.subExtension)
                    .help("Enable subscript syntax with tilde: H2O")

                Toggle("Superscript", isOn: $viewModel.supExtension)
                    .help("Enable superscript syntax with caret: x squared")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Strikethrough", isOn: $viewModel.strikethroughExtension)
                        .help("Enable strikethrough text")

                    if viewModel.strikethroughExtension {
                        Toggle("Use double-tilde (~~text~~) instead of single (~text~)", isOn: $viewModel.strikethroughDoubleTildeOption)
                            .help("Require double tilde instead of single tilde syntax")
                            .padding(.leading, 20)
                    }
                }

                Toggle("Custom checkbox styling", isOn: $viewModel.checkboxExtension)
                    .help("Apply custom CSS styling to task list checkboxes")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    ExtensionsSettingsView(viewModel: SettingsViewModel(from: Settings.shared))
        .frame(width: 600, height: 500)
}
