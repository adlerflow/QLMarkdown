//
//  CodeBlockView.swift
//  TextDown
//
//  Renders fenced code blocks with language badge
//

import SwiftUI
import Markdown

/// Renders fenced code blocks (```language)
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
                        .background(Color.Markdown.inlineCodeBackground)
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
        .background(Color.Markdown.codeBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var highlightedCode: AttributedString {
        // Pure SwiftUI rendering: Plain monospaced text
        // Future enhancement: Integrate SwiftHighlighter for syntax coloring
        // Currently displays plain text to maintain Pure SwiftUI architecture
        var attributed = AttributedString(codeBlock.code)
        attributed.font = .system(.body, design: .monospaced)
        return attributed
    }
}
