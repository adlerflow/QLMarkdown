//
//  MarkdownASTView.swift
//  TextDown
//
//  Created by adlerflow on 2025-11-03.
//

import SwiftUI
import Markdown

/// Native SwiftUI Markdown Renderer using swift-markdown AST
struct MarkdownASTView: View {
    let document: Document?

    var body: some View {
        ScrollView {
            if let doc = document {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(doc.children.enumerated()), id: \.offset) { index, child in
                        MarkdownBlockView(markup: child)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No preview available")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Start typing markdown in the editor")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.textBackgroundColor))  // SwiftUI semantic color
    }
}

/// Block-Level Renderer (Dispatcher)
struct MarkdownBlockView: View {
    let markup: Markup

    var body: some View {
        Group {
            if let heading = markup as? Heading {
                HeadingView(heading: heading)
            } else if let paragraph = markup as? Paragraph {
                ParagraphView(paragraph: paragraph)
            } else if let codeBlock = markup as? CodeBlock {
                CodeBlockView(codeBlock: codeBlock)
            } else if let list = markup as? UnorderedList {
                UnorderedListView(list: list)
            } else if let list = markup as? OrderedList {
                OrderedListView(list: list)
            } else if let blockQuote = markup as? BlockQuote {
                BlockQuoteView(blockQuote: blockQuote)
            } else if let thematicBreak = markup as? ThematicBreak {
                Divider()
                    .padding(.vertical, 8)
            } else {
                // Fallback für unbekannte Blöcke
                Text("⚠️ Unsupported block: \(String(describing: type(of: markup)))")
                    .foregroundStyle(.orange)
                    .font(.caption)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
}

// MARK: - Heading Renderer

struct HeadingView: View {
    let heading: Heading

    var body: some View {
        Text(heading.plainText)
            .font(fontForLevel(heading.level))
            .fontWeight(.bold)
            .id("heading-\(heading.plainText.hashValue)")  // Für Scroll-Sync
            .padding(.vertical, verticalPaddingForLevel(heading.level))
    }

    private func fontForLevel(_ level: Int) -> Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3: return .title2
        case 4: return .title3
        case 5: return .headline
        default: return .body.bold()
        }
    }

    private func verticalPaddingForLevel(_ level: Int) -> CGFloat {
        switch level {
        case 1: return 8
        case 2: return 6
        case 3, 4: return 4
        default: return 2
        }
    }
}

// MARK: - Paragraph Renderer

struct ParagraphView: View {
    let paragraph: Paragraph

    var body: some View {
        Text(renderInlineText(paragraph))
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }

    private func renderInlineText(_ markup: Markup) -> AttributedString {
        var result = AttributedString()

        for child in markup.children {
            if let text = child as? Markdown.Text {
                result += AttributedString(text.string)
            } else if let strong = child as? Strong {
                var bold = renderInlineText(strong)
                bold.font = .body.bold()
                result += bold
            } else if let emphasis = child as? Emphasis {
                var italic = renderInlineText(emphasis)
                italic.font = .body.italic()
                result += italic
            } else if let code = child as? InlineCode {
                var codeText = AttributedString(code.code)
                codeText.font = .system(.body, design: .monospaced)
                codeText.backgroundColor = Color.gray.opacity(0.15)
                codeText.foregroundColor = Color.pink
                result += codeText
            } else if let link = child as? Markdown.Link {
                var linkText = AttributedString(link.plainText)
                linkText.foregroundColor = Color.blue
                linkText.underlineStyle = Text.LineStyle.Pattern.single
                if let url = link.destination {
                    linkText.link = URL(string: url)
                }
                result += linkText
            } else if let strikethrough = child as? Strikethrough {
                var struck = renderInlineText(strikethrough)
                struck.strikethroughStyle = Text.LineStyle.Pattern.single
                struck.foregroundColor = Color.secondary
                result += struck
            }
        }

        return result
    }
}

// MARK: - Code Block Renderer

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Language Badge (optional)
            if let language = codeBlock.language, !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }

            // Code Content
            ScrollView(.horizontal, showsIndicators: false) {
                Text(highlightedCode)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.controlBackgroundColor))  // SwiftUI semantic color
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var highlightedCode: AttributedString {
        guard appState.renderingSettings.enableSyntaxHighlighting,
              let language = codeBlock.language else {
            return AttributedString(codeBlock.code)
        }

        // Verwende SwiftHighlighter (siehe nächste Datei)
        return SwiftHighlighter.highlight(
            code: codeBlock.code,
            language: language,
            theme: appState.syntaxTheme
        )
    }
}

// MARK: - List Renderers

struct UnorderedListView: View {
    let list: UnorderedList

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.body.bold())
                        .frame(width: 20, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                            MarkdownBlockView(markup: child)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.leading, 20)
    }
}

struct OrderedListView: View {
    let list: OrderedList

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(Int(list.startIndex) + index).")
                        .font(.body)
                        .frame(width: 30, alignment: .trailing)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                            MarkdownBlockView(markup: child)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.leading, 20)
    }
}

// MARK: - Block Quote Renderer

struct BlockQuoteView: View {
    let blockQuote: BlockQuote

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    MarkdownBlockView(markup: child)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 12)
        .padding(.vertical, 8)
    }
}
