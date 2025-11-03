//
//  ExtensionsSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct ExtensionsSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("GitHub Flavored Markdown") {
                Toggle("Tables", isOn: $appState.enableTable)
                    .help("Enable GitHub-style table syntax")

                Toggle("Autolink", isOn: $appState.enableAutolink)
                    .help("Automatically convert URLs to links")

                Toggle("Tag filter", isOn: $appState.enableTagFilter)
                    .help("Filter unsafe HTML tags")

                Toggle("Task lists", isOn: $appState.enableTaskList)
                    .help("Enable checkbox task lists: - [ ] unchecked, - [x] checked")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("YAML headers", isOn: $appState.enableYAML)
                        .help("Parse YAML front-matter in documents")

                    if appState.enableYAML {
                        Toggle("Apply to all files (not just .rmd/.qmd)", isOn: $appState.enableYAMLAll)
                            .padding(.leading, 20)
                            .help("Parse YAML in all markdown files instead of only R Markdown files")
                    }
                }
            }

            Section("Custom Extensions") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Emoji", isOn: $appState.enableEmoji)
                        .help("Convert :emoji_name: to emoji characters (e.g., :smile: → 😄)")

                    if appState.enableEmoji {
                        Toggle("Render as images instead of font", isOn: $appState.enableEmojiImages)
                            .padding(.leading, 20)
                            .help("Use emoji images instead of system font")
                    }
                }

                Toggle("Headline anchors", isOn: $appState.enableHeads)
                    .help("Automatically generate id attributes for headlines (e.g., ## Hello → <h2 id=\"hello\">)")

                Toggle("Highlight", isOn: $appState.enableHighlight)
                    .help("Enable ==highlighted text== syntax")

                Toggle("Inline images", isOn: $appState.enableInlineImage)
                    .help("Embed local images as Base64 data URLs")

                Toggle("Math (LaTeX)", isOn: $appState.enableMath)
                    .help("Render LaTeX math expressions: $inline$ or $$display$$")

                Toggle("Mentions", isOn: $appState.enableMention)
                    .help("Convert @username to GitHub profile links")

                Toggle("Subscript", isOn: $appState.enableSubscript)
                    .help("Enable subscript syntax: ~text~")

                Toggle("Superscript", isOn: $appState.enableSuperscript)
                    .help("Enable superscript syntax: ^text^")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Strikethrough", isOn: $appState.enableStrikethrough)
                        .help("Enable strikethrough text")

                    if appState.enableStrikethrough {
                        Toggle("Use double-tilde (~~text~~) instead of single (~text~)", isOn: $appState.enableStrikethroughDoubleTilde)
                            .padding(.leading, 20)
                            .help("Require ~~double~~ instead of ~single~ tilde syntax")
                    }
                }

                Toggle("Custom checkbox styling", isOn: $appState.enableCheckbox)
                    .help("Apply custom CSS styling to task list checkboxes")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    ExtensionsSettingsView()
        .environmentObject(AppState())
        .frame(width: 600, height: 500)
}
