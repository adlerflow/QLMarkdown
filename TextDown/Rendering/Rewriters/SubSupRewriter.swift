//
//  SubSupRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for ~subscript~ and ^superscript^
//  Converts ~text~ → <sub>text</sub>, ^text^ → <sup>text</sup>
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown

/// Rewriter that converts ~text~ to <sub> and ^text^ to <sup>
///
/// Examples:
/// - `H~2~O` → `H<sub>2</sub>O`
/// - `E=mc^2^` → `E=mc<sup>2</sup>`
///
/// ⚠️ FRAGILE: Uses regex, may break with:
/// - Escaped delimiters
/// - Nested formatting
/// - Multi-line spans
struct SubSupRewriter: MarkupRewriter {
    let subscriptEnabled: Bool
    let superscriptEnabled: Bool

    init(subscriptEnabled: Bool = true, superscriptEnabled: Bool = true) {
        self.subscriptEnabled = subscriptEnabled
        self.superscriptEnabled = superscriptEnabled
    }

    mutating func visitText(_ text: Markdown.Text) -> Markup? {
        // Don't process text inside code blocks or code spans
        if isInCodeContext(text) {
            return text
        }

        var result = text.string

        // Process subscript ~text~
        if subscriptEnabled {
            // Pattern: ~text~ (non-greedy, no newlines, no spaces at boundaries)
            let subPattern = /~([^\n~ ][^\n~]*[^\n~ ]|[^\n~ ])~/
            for match in result.matches(of: subPattern) {
                let content = String(match.1)
                let original = "~\(content)~"
                let replacement = "<sub>\(content)</sub>"
                result = result.replacingOccurrences(of: original, with: replacement)
            }
        }

        // Process superscript ^text^
        if superscriptEnabled {
            // Pattern: ^text^ (non-greedy, no newlines, no spaces at boundaries)
            let supPattern = /\^([^\n^ ][^\n^]*[^\n^ ]|[^\n^ ])\^/
            for match in result.matches(of: supPattern) {
                let content = String(match.1)
                let original = "^\(content)^"
                let replacement = "<sup>\(content)</sup>"
                result = result.replacingOccurrences(of: original, with: replacement)
            }
        }

        if result != text.string {
            return Markdown.Text(result)
        }

        return text
    }

    private func isInCodeContext(_ text: Markdown.Text) -> Bool {
        var current: Markup? = text
        while let parent = current?.parent {
            if parent is CodeBlock || parent is InlineCode {
                return true
            }
            current = parent
        }
        return false
    }
}
