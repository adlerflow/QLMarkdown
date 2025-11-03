//
//  BlockQuoteView.swift
//  TextDown
//
//  Renders block quotes with accent bar
//

import SwiftUI
import Markdown

/// Renders block quotes (> quoted text)
struct BlockQuoteView: View {
    let blockQuote: BlockQuote

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.Markdown.blockQuoteAccent)
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
