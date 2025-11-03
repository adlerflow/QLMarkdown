//
//  ParagraphView.swift
//  TextDown
//
//  Renders markdown paragraphs with inline formatting
//

import SwiftUI
import Markdown

/// Renders markdown paragraphs with inline elements (bold, italic, code, links, etc.)
struct ParagraphView: View {
    let paragraph: Paragraph

    var body: some View {
        Text(MarkdownInlineRenderer.render(paragraph))
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }
}

// MARK: - Inline Renderer

/// Renders inline markdown elements (bold, italic, code, links, etc.) to AttributedString
struct MarkdownInlineRenderer {

    /// Renders a markup element and its children to an AttributedString
    /// - Parameter markup: The markup element to render (typically Paragraph or inline container)
    /// - Returns: Styled AttributedString with inline formatting
    static func render(_ markup: Markup) -> AttributedString {
        var result = AttributedString()

        for child in markup.children {
            if let text = child as? Markdown.Text {
                result += AttributedString(text.string)
            } else if let strong = child as? Strong {
                result += renderStrong(strong)
            } else if let emphasis = child as? Emphasis {
                result += renderEmphasis(emphasis)
            } else if let code = child as? InlineCode {
                result += renderInlineCode(code)
            } else if let link = child as? Markdown.Link {
                result += renderLink(link)
            } else if let strikethrough = child as? Strikethrough {
                result += renderStrikethrough(strikethrough)
            }
        }

        return result
    }

    // MARK: - Private Renderers

    private static func renderStrong(_ strong: Strong) -> AttributedString {
        var bold = render(strong)
        bold.font = .body.bold()
        return bold
    }

    private static func renderEmphasis(_ emphasis: Emphasis) -> AttributedString {
        var italic = render(emphasis)
        italic.font = .body.italic()
        return italic
    }

    private static func renderInlineCode(_ code: InlineCode) -> AttributedString {
        var codeText = AttributedString(code.code)
        codeText.font = .system(.body, design: .monospaced)
        codeText.backgroundColor = Color.Markdown.inlineCodeBackground
        codeText.foregroundColor = Color.Markdown.inlineCodeForeground
        return codeText
    }

    private static func renderLink(_ link: Markdown.Link) -> AttributedString {
        var linkText = AttributedString(link.plainText)
        linkText.foregroundColor = Color.Markdown.link
        linkText.underlineStyle = .single
        if let url = link.destination {
            linkText.link = URL(string: url)
        }
        return linkText
    }

    private static func renderStrikethrough(_ strikethrough: Strikethrough) -> AttributedString {
        var struck = render(strikethrough)
        struck.strikethroughStyle = .single
        struck.foregroundColor = Color.secondary
        return struck
    }
}
