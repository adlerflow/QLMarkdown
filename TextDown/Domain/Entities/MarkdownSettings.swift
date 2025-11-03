import Foundation

/// Markdown parsing and rendering settings
/// Aggregates GitHub Flavored Markdown, custom extensions, and parser options
/// Thread-safe value type for concurrent access
struct MarkdownSettings: Sendable, Codable, Equatable {
    // MARK: - GitHub Flavored Markdown

    /// Enable autolink extension (bare URLs become links)
    var enableAutolink: Bool

    /// Enable table extension (GFM tables)
    var enableTable: Bool

    /// Enable tag filter (strip specific HTML tags)
    var enableTagFilter: Bool

    /// Enable task list extension (- [ ] checkboxes)
    var enableTaskList: Bool

    /// Enable YAML front matter parsing
    var enableYAML: Bool

    /// Parse all YAML blocks (not just front matter)
    var enableYAMLAll: Bool

    // MARK: - Custom Extensions

    /// Enable checkbox syntax (deprecated, use enableTaskList)
    var enableCheckbox: Bool

    /// Enable emoji shortcodes (:smile: → 😄)
    var enableEmoji: Bool

    /// Use emoji images instead of Unicode characters
    var enableEmojiImages: Bool

    /// Auto-generate heading IDs for anchors
    var enableHeads: Bool

    /// Enable highlight syntax (==text==)
    var enableHighlight: Bool

    /// Enable inline image embedding (base64)
    var enableInlineImage: Bool

    /// Enable LaTeX math rendering ($inline$ and $$block$$)
    var enableMath: Bool

    /// Enable @mention syntax (links to GitHub profiles)
    var enableMention: Bool

    /// Enable strikethrough extension (~text~ or ~~text~~)
    var enableStrikethrough: Bool

    /// Require double tilde for strikethrough (~~only~~)
    var enableStrikethroughDoubleTilde: Bool

    /// Enable subscript syntax (~sub~)
    var enableSubscript: Bool

    /// Enable superscript syntax (^sup^)
    var enableSuperscript: Bool

    // MARK: - Parser Options

    /// Enable footnote syntax ([^1])
    var enableFootnotes: Bool

    /// Treat single line breaks as <br> (GitHub style)
    var enableHardBreaks: Bool

    /// Disable soft line breaks (preserve all whitespace)
    var disableSoftBreaks: Bool

    /// Allow raw HTML in markdown (security risk!)
    var allowUnsafeHTML: Bool

    /// Convert straight quotes to curly quotes ("" → "" '')
    var enableSmartQuotes: Bool

    /// Validate UTF-8 encoding (reject invalid bytes)
    var validateUTF8: Bool

    // MARK: - Defaults

    static let `default` = MarkdownSettings(
        // GFM
        enableAutolink: true,
        enableTable: true,
        enableTagFilter: true,
        enableTaskList: true,
        enableYAML: true,
        enableYAMLAll: false,
        // Custom Extensions
        enableCheckbox: false,
        enableEmoji: true,
        enableEmojiImages: false,
        enableHeads: true,
        enableHighlight: false,
        enableInlineImage: true,
        enableMath: true,
        enableMention: false,
        enableStrikethrough: true,
        enableStrikethroughDoubleTilde: false,
        enableSubscript: false,
        enableSuperscript: false,
        // Parser Options
        enableFootnotes: true,
        enableHardBreaks: false,
        disableSoftBreaks: false,
        allowUnsafeHTML: false,
        enableSmartQuotes: true,
        validateUTF8: false
    )

    // MARK: - Validation

    /// Validates markdown settings for consistency
    /// - Returns: Validated settings with corrections applied
    func validated() -> MarkdownSettings {
        // Validate conflicting options
        var validated = self

        // If enableStrikethroughDoubleTilde is true, enableStrikethrough must also be true
        if enableStrikethroughDoubleTilde && !enableStrikethrough {
            validated = MarkdownSettings(
                enableAutolink: enableAutolink,
                enableTable: enableTable,
                enableTagFilter: enableTagFilter,
                enableTaskList: enableTaskList,
                enableYAML: enableYAML,
                enableYAMLAll: enableYAMLAll,
                enableCheckbox: enableCheckbox,
                enableEmoji: enableEmoji,
                enableEmojiImages: enableEmojiImages,
                enableHeads: enableHeads,
                enableHighlight: enableHighlight,
                enableInlineImage: enableInlineImage,
                enableMath: enableMath,
                enableMention: enableMention,
                enableStrikethrough: true, // Force enable
                enableStrikethroughDoubleTilde: enableStrikethroughDoubleTilde,
                enableSubscript: enableSubscript,
                enableSuperscript: enableSuperscript,
                enableFootnotes: enableFootnotes,
                enableHardBreaks: enableHardBreaks,
                disableSoftBreaks: disableSoftBreaks,
                allowUnsafeHTML: allowUnsafeHTML,
                enableSmartQuotes: enableSmartQuotes,
                validateUTF8: validateUTF8
            )
        }

        // If enableYAMLAll is true, enableYAML must also be true
        if enableYAMLAll && !enableYAML {
            validated = MarkdownSettings(
                enableAutolink: validated.enableAutolink,
                enableTable: validated.enableTable,
                enableTagFilter: validated.enableTagFilter,
                enableTaskList: validated.enableTaskList,
                enableYAML: true, // Force enable
                enableYAMLAll: validated.enableYAMLAll,
                enableCheckbox: validated.enableCheckbox,
                enableEmoji: validated.enableEmoji,
                enableEmojiImages: validated.enableEmojiImages,
                enableHeads: validated.enableHeads,
                enableHighlight: validated.enableHighlight,
                enableInlineImage: validated.enableInlineImage,
                enableMath: validated.enableMath,
                enableMention: validated.enableMention,
                enableStrikethrough: validated.enableStrikethrough,
                enableStrikethroughDoubleTilde: validated.enableStrikethroughDoubleTilde,
                enableSubscript: validated.enableSubscript,
                enableSuperscript: validated.enableSuperscript,
                enableFootnotes: validated.enableFootnotes,
                enableHardBreaks: validated.enableHardBreaks,
                disableSoftBreaks: validated.disableSoftBreaks,
                allowUnsafeHTML: validated.allowUnsafeHTML,
                enableSmartQuotes: validated.enableSmartQuotes,
                validateUTF8: validated.validateUTF8
            )
        }

        // If enableEmojiImages is true, enableEmoji must also be true
        if enableEmojiImages && !enableEmoji {
            validated = MarkdownSettings(
                enableAutolink: validated.enableAutolink,
                enableTable: validated.enableTable,
                enableTagFilter: validated.enableTagFilter,
                enableTaskList: validated.enableTaskList,
                enableYAML: validated.enableYAML,
                enableYAMLAll: validated.enableYAMLAll,
                enableCheckbox: validated.enableCheckbox,
                enableEmoji: true, // Force enable
                enableEmojiImages: validated.enableEmojiImages,
                enableHeads: validated.enableHeads,
                enableHighlight: validated.enableHighlight,
                enableInlineImage: validated.enableInlineImage,
                enableMath: validated.enableMath,
                enableMention: validated.enableMention,
                enableStrikethrough: validated.enableStrikethrough,
                enableStrikethroughDoubleTilde: validated.enableStrikethroughDoubleTilde,
                enableSubscript: validated.enableSubscript,
                enableSuperscript: validated.enableSuperscript,
                enableFootnotes: validated.enableFootnotes,
                enableHardBreaks: validated.enableHardBreaks,
                disableSoftBreaks: validated.enableHardBreaks, // disableSoftBreaks conflicts with enableHardBreaks
                allowUnsafeHTML: validated.allowUnsafeHTML,
                enableSmartQuotes: validated.enableSmartQuotes,
                validateUTF8: validated.validateUTF8
            )
        }

        return validated
    }
}
