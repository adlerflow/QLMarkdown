//
//  ExtensionsSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct ExtensionsSettingsView: View {
    @Bindable var settings: AppConfiguration

    var body: some View {
        Form {
            Section("GitHub Flavored Markdown") {
                Toggle("Tables", isOn: $settings.tableExtension)
                    .help("Enable GitHub-style table syntax")

                Toggle("Autolink", isOn: $settings.autoLinkExtension)
                    .help("Automatically convert URLs to links")

                Toggle("Tag filter", isOn: $settings.tagFilterExtension)
                    .help("Filter unsafe HTML tags")

                Toggle("Task lists", isOn: $settings.taskListExtension)
                    .help("Enable checkbox task lists: - [ ] unchecked, - [x] checked")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("YAML headers", isOn: $settings.yamlExtension)
                        .help("Parse YAML front-matter in documents")

                    if settings.yamlExtension {
                        Toggle("Apply to all files (not just .rmd/.qmd)", isOn: $settings.yamlExtensionAll)
                            .padding(.leading, 20)
                            .help("Parse YAML in all markdown files instead of only R Markdown files")
                    }
                }
            }

            Section("Custom Extensions") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Emoji", isOn: $settings.emojiExtension)
                        .help("Convert :emoji_name: to emoji characters (e.g., :smile: → 😄)")

                    if settings.emojiExtension {
                        Toggle("Render as images instead of font", isOn: $settings.emojiImageOption)
                            .padding(.leading, 20)
                            .help("Use emoji images instead of system font")
                    }
                }

                Toggle("Headline anchors", isOn: $settings.headsExtension)
                    .help("Automatically generate id attributes for headlines (e.g., ## Hello → <h2 id=\"hello\">)")

                Toggle("Highlight", isOn: $settings.highlightExtension)
                    .help("Enable ==highlighted text== syntax")

                Toggle("Inline images", isOn: $settings.inlineImageExtension)
                    .help("Embed local images as Base64 data URLs")

                Toggle("Math (LaTeX)", isOn: $settings.mathExtension)
                    .help("Render LaTeX math expressions: $inline$ or $$display$$")

                Toggle("Mentions", isOn: $settings.mentionExtension)
                    .help("Convert @username to GitHub profile links")

                Toggle("Subscript", isOn: $settings.subExtension)
                    .help("Enable subscript syntax: ~text~")

                Toggle("Superscript", isOn: $settings.supExtension)
                    .help("Enable superscript syntax: ^text^")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Strikethrough", isOn: $settings.strikethroughExtension)
                        .help("Enable strikethrough text")

                    if settings.strikethroughExtension {
                        Toggle("Use double-tilde (~~text~~) instead of single (~text~)", isOn: $settings.strikethroughDoubleTildeOption)
                            .padding(.leading, 20)
                            .help("Require ~~double~~ instead of ~single~ tilde syntax")
                    }
                }

                Toggle("Custom checkbox styling", isOn: $settings.checkboxExtension)
                    .help("Apply custom CSS styling to task list checkboxes")
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

    ExtensionsSettingsView(settings: previewSettings)
        .frame(width: 600, height: 500)
}
