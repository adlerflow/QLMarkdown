//
//  EmojiRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for :emoji: shortcodes
//  Converts :smile: → 😄, :heart: → ❤️, etc.
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown

/// Rewriter that converts GitHub-style emoji shortcodes to Unicode characters
///
/// Example: `:smile:` → 😄
struct EmojiRewriter: MarkupRewriter {
    let useCharacters: Bool

    init(useCharacters: Bool = true) {
        self.useCharacters = useCharacters
    }

    /// Visit text nodes and replace emoji shortcodes
    mutating func visitText(_ text: Markdown.Text) -> Markup? {
        // Don't process text inside code blocks or code spans
        if isInCodeContext(text) {
            return text
        }

        guard useCharacters else {
            return text
        }

        let pattern = /:([\w+-]+):/
        let input = text.string

        var result = input
        for match in input.matches(of: pattern) {
            let shortcode = String(match.1)
            if let emoji = Self.emojiMap[shortcode] {
                result = result.replacingOccurrences(of: ":\(shortcode):", with: emoji)
            }
        }

        if result != input {
            return Markdown.Text(result)
        }

        return text
    }

    /// Check if text node is inside code context (code block or inline code)
    private func isInCodeContext(_ text: Markdown.Text) -> Bool {
        // Traverse up the parent chain looking for code contexts
        var current: Markup? = text
        while let parent = current?.parent {
            if parent is CodeBlock || parent is InlineCode {
                return true
            }
            current = parent
        }
        return false
    }

    /// Embedded emoji mapping (most common ~50 emojis)
    /// For full GitHub emoji support, load from JSON file
    static let emojiMap: [String: String] = [
        // Smileys & People
        "smile": "😄",
        "smiley": "😃",
        "grin": "😁",
        "laughing": "😆",
        "sweat_smile": "😅",
        "joy": "😂",
        "rofl": "🤣",
        "relaxed": "☺️",
        "blush": "😊",
        "wink": "😉",
        "heart_eyes": "😍",
        "kissing_heart": "😘",
        "thinking": "🤔",
        "neutral_face": "😐",
        "expressionless": "😑",
        "no_mouth": "😶",
        "smirk": "😏",
        "unamused": "😒",
        "grimacing": "😬",
        "lying_face": "🤥",
        "thumbsup": "👍",
        "thumbsdown": "👎",
        "+1": "👍",
        "-1": "👎",
        "clap": "👏",
        "raised_hands": "🙌",
        "pray": "🙏",
        "wave": "👋",

        // Hearts & Symbols
        "heart": "❤️",
        "green_heart": "💚",
        "blue_heart": "💙",
        "yellow_heart": "💛",
        "purple_heart": "💜",
        "broken_heart": "💔",
        "star": "⭐",
        "fire": "🔥",
        "sparkles": "✨",
        "tada": "🎉",
        "rocket": "🚀",
        "100": "💯",
        "check": "✓",
        "x": "✗",
        "warning": "⚠️",
        "bulb": "💡",
        "lock": "🔒",
        "unlock": "🔓",
        "key": "🔑",
        "mag": "🔍",

        // Nature & Objects
        "sunny": "☀️",
        "cloud": "☁️",
        "snowflake": "❄️",
        "zap": "⚡",
        "umbrella": "☂️",
        "coffee": "☕",
        "beer": "🍺",
        "computer": "💻",
        "iphone": "📱",
        "book": "📖",
        "pencil": "📝",
        "memo": "📝",
        "email": "📧",
        "link": "🔗",

        // Arrows & Misc
        "arrow_right": "➡️",
        "arrow_left": "⬅️",
        "arrow_up": "⬆️",
        "arrow_down": "⬇️",
    ]
}
