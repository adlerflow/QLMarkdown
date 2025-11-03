import Foundation

/// Syntax highlighting configuration
/// Thread-safe value type for concurrent access
struct SyntaxTheme: Sendable, Codable, Equatable {
    // MARK: - Properties

    /// Enable syntax highlighting for code blocks
    var enabled: Bool

    /// Show line numbers in code blocks
    var showLineNumbers: Bool

    /// Tab width (spaces per tab)
    var tabWidth: Int

    /// Word wrap column (0 = no wrap)
    var wordWrapColumn: Int

    /// Theme name for light mode
    var lightTheme: String

    /// Theme name for dark mode
    var darkTheme: String

    // MARK: - Defaults

    static let `default` = SyntaxTheme(
        enabled: true,
        showLineNumbers: false,
        tabWidth: 4,
        wordWrapColumn: 0,
        lightTheme: "github",
        darkTheme: "github-dark"
    )

    // MARK: - Available Themes

    /// Supported syntax highlighting themes
    static let availableThemes = [
        "github",
        "github-dark"
    ]

    // MARK: - Validation

    /// Validates syntax theme settings
    /// - Returns: Validated settings with corrections applied
    func validated() -> SyntaxTheme {
        // Clamp tab width to reasonable range
        let validTabWidth = max(1, min(tabWidth, 16))

        // Clamp word wrap to reasonable range
        let validWordWrap = max(0, min(wordWrapColumn, 500))

        // Validate theme names (fallback to default if invalid)
        let validLightTheme = Self.availableThemes.contains(lightTheme) ? lightTheme : "github"
        let validDarkTheme = Self.availableThemes.contains(darkTheme) ? darkTheme : "github-dark"

        return SyntaxTheme(
            enabled: enabled,
            showLineNumbers: showLineNumbers,
            tabWidth: validTabWidth,
            wordWrapColumn: validWordWrap,
            lightTheme: validLightTheme,
            darkTheme: validDarkTheme
        )
    }
}
