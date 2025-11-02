//
//  MentionRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for @username mentions
//  Converts @username → <a href="https://github.com/username">@username</a>
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown

/// Rewriter that converts @username to GitHub profile links
///
/// Example: `@octocat` → `<a href="https://github.com/octocat">@octocat</a>`
///
/// ⚠️ FRAGILE: Uses regex, may break with:
/// - Email addresses: `contact@example.com` (should NOT be converted)
/// - Escaped mentions: `\@username`
struct MentionRewriter: MarkupRewriter {
    let enabled: Bool

    init(enabled: Bool = true) {
        self.enabled = enabled
    }

    mutating func visitText(_ text: Markdown.Text) -> Markup? {
        guard enabled else { return text }

        // Don't process text inside code blocks, code spans, or links
        if isInExcludedContext(text) {
            return text
        }

        let input = text.string

        // Pattern: @username (alphanumeric + hyphen)
        // ⚠️ Simplified: May match email addresses like user@host.com
        // Better heuristic: Check if @ is at word boundary
        let pattern = /@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)\b/

        var result = input
        for match in input.matches(of: pattern) {
            let username = String(match.1)
            let original = "@\(username)"

            // Skip if this looks like an email (has @ before the match)
            let matchRange = match.range
            let startIndex = input.index(matchRange.lowerBound, offsetBy: -1, limitedBy: input.startIndex)
            if let startIndex = startIndex, input[startIndex] == "@" {
                continue // Skip @@username or email@@user
            }

            let url = "https://github.com/\(username)"
            let replacement = "<a href=\"\(url)\">@\(username)</a>"

            result = result.replacingOccurrences(of: original, with: replacement)
        }

        if result != input {
            return Markdown.Text(result)
        }

        return text
    }

    private func isInExcludedContext(_ text: Markdown.Text) -> Bool {
        var current: Markup? = text
        while let parent = current?.parent {
            // Skip mentions in code blocks, inline code, or existing links
            if parent is CodeBlock || parent is InlineCode || parent is Link {
                return true
            }
            current = parent
        }
        return false
    }
}
