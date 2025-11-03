//
//  MarkdownASTView.swift
//  TextDown
//
//  Main container and dispatcher for markdown rendering
//  Individual view implementations are in separate files
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
        .background(Color.Markdown.textBackground)
    }
}

// MARK: - Block Dispatcher

/// Block-Level Renderer (Dispatcher)
/// Routes markdown blocks to appropriate view renderers
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
            } else if markup is ThematicBreak {
                Divider()
                    .padding(.vertical, 8)
            } else {
                // Fallback for unsupported blocks
                Text("⚠️ Unsupported block: \(String(describing: type(of: markup)))")
                    .foregroundStyle(Color.Markdown.warning)
                    .font(.caption)
                    .padding(8)
                    .background(Color.Markdown.warning.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
}
