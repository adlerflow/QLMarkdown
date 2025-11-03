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

    // MARK: - GFM Extensions (Pure SwiftUI - Nov 2025)
    // Note: HTML-based custom extensions (Emoji, Math, Highlight, etc.) removed
    // Only swift-markdown native extensions supported

    /// Enable strikethrough extension (GFM: ~~text~~)
    var enableStrikethrough: Bool

    /// Require double tilde for strikethrough (~~only~~)
    var enableStrikethroughDoubleTilde: Bool

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
        // GFM Extensions
        enableStrikethrough: true,
        enableStrikethroughDoubleTilde: false,
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
        var validated = self

        // If enableStrikethroughDoubleTilde is true, enableStrikethrough must also be true
        if enableStrikethroughDoubleTilde && !enableStrikethrough {
            validated.enableStrikethrough = true
        }

        // If enableYAMLAll is true, enableYAML must also be true
        if enableYAMLAll && !enableYAML {
            validated.enableYAML = true
        }

        return validated
    }
}
