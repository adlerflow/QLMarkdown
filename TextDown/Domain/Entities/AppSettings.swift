import Foundation

/// Top-level application settings aggregator
/// Combines all setting categories into a single cohesive entity
/// Thread-safe value type for concurrent access
struct AppSettings: Sendable, Codable, Equatable {
    // MARK: - Properties

    /// Editor behavior and UI settings
    var editor: EditorSettings

    /// Markdown parsing and rendering settings
    var markdown: MarkdownSettings

    /// Syntax highlighting configuration
    var syntaxTheme: SyntaxTheme

    /// Custom CSS configuration
    var css: CSSSettings

    // MARK: - Defaults

    static let `default` = AppSettings(
        editor: .default,
        markdown: .default,
        syntaxTheme: .default,
        css: .default
    )

    // MARK: - Validation

    /// Validates all settings categories
    /// - Returns: Validated settings with corrections applied
    func validated() -> AppSettings {
        AppSettings(
            editor: editor.validated(),
            markdown: markdown.validated(),
            syntaxTheme: syntaxTheme.validated(),
            css: css.validated()
        )
    }
}
