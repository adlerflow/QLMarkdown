//
//  HighlightRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for ==highlighted text==
//  Converts ==text== → <mark>text</mark>
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown

/// Rewriter that converts ==text== to <mark> HTML elements
///
/// Example: `==highlighted==` → `<mark>highlighted</mark>`
///
/// ⚠️ FRAGILE: Uses regex on text nodes, may break with:
/// - Escaped delimiters: `\==not highlighted\==`
/// - Nested formatting: `==**bold highlight**==`
/// - Multi-line spans
struct HighlightRewriter: MarkupRewriter {
    let enabled: Bool

    init(enabled: Bool = true) {
        self.enabled = enabled
    }

    mutating func visitText(_ text: Markdown.Text) -> Markup? {
        guard enabled else { return text }

        // Don't process text inside code blocks or code spans
        if isInCodeContext(text) {
            return text
        }

        let input = text.string

        // Pattern: ==text== (non-greedy, no newlines)
        // Matches: ==hello==, ==multiple words==
        // Avoids: ==multi
        //         line==
        let pattern = /==([^\n=]+)==/

        var result = input
        for match in input.matches(of: pattern) {
            let content = String(match.1)
            let original = "==\(content)=="
            let replacement = "<mark>\(content)</mark>"
            result = result.replacingOccurrences(of: original, with: replacement)
        }

        if result != input {
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
