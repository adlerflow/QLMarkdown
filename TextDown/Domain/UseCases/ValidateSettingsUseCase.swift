import Foundation

/// Use case for validating app settings consistency
/// Thread-safe actor that checks for conflicts and invalid values
actor ValidateSettingsUseCase {
    // MARK: - Initialization

    init() {}

    // MARK: - Business Logic

    /// Validates settings and returns corrected version
    /// - Parameter settings: Settings to validate
    /// - Returns: Validated settings with corrections applied
    func execute(_ settings: AppSettings) async -> AppSettings {
        settings.validated()
    }

    /// Validates settings and returns list of issues found
    /// - Parameter settings: Settings to validate
    /// - Returns: Array of validation issue descriptions
    func validate(_ settings: AppSettings) async -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        // Check markdown settings conflicts
        let markdown = settings.markdown

        if markdown.enableStrikethroughDoubleTilde && !markdown.enableStrikethrough {
            issues.append(ValidationIssue(
                severity: .error,
                property: "enableStrikethroughDoubleTilde",
                message: "Double tilde strikethrough requires enableStrikethrough=true"
            ))
        }

        if markdown.enableYAMLAll && !markdown.enableYAML {
            issues.append(ValidationIssue(
                severity: .error,
                property: "enableYAMLAll",
                message: "YAMLAll requires enableYAML=true"
            ))
        }

        if markdown.enableEmojiImages && !markdown.enableEmoji {
            issues.append(ValidationIssue(
                severity: .error,
                property: "enableEmojiImages",
                message: "Emoji images require enableEmoji=true"
            ))
        }

        if markdown.enableHardBreaks && markdown.disableSoftBreaks {
            issues.append(ValidationIssue(
                severity: .warning,
                property: "enableHardBreaks + disableSoftBreaks",
                message: "Conflicting line break options - hard breaks take precedence"
            ))
        }

        if markdown.allowUnsafeHTML {
            issues.append(ValidationIssue(
                severity: .warning,
                property: "allowUnsafeHTML",
                message: "Unsafe HTML is enabled - potential security risk"
            ))
        }

        // Check syntax theme
        let syntax = settings.syntaxTheme

        if syntax.tabWidth < 1 || syntax.tabWidth > 16 {
            issues.append(ValidationIssue(
                severity: .error,
                property: "tabWidth",
                message: "Tab width must be between 1 and 16 (got \(syntax.tabWidth))"
            ))
        }

        if syntax.wordWrapColumn < 0 || syntax.wordWrapColumn > 500 {
            issues.append(ValidationIssue(
                severity: .warning,
                property: "wordWrapColumn",
                message: "Word wrap column out of recommended range (0-500)"
            ))
        }

        if !SyntaxTheme.availableThemes.contains(syntax.lightTheme) {
            issues.append(ValidationIssue(
                severity: .error,
                property: "lightTheme",
                message: "Unknown light theme '\(syntax.lightTheme)'"
            ))
        }

        if !SyntaxTheme.availableThemes.contains(syntax.darkTheme) {
            issues.append(ValidationIssue(
                severity: .error,
                property: "darkTheme",
                message: "Unknown dark theme '\(syntax.darkTheme)'"
            ))
        }

        // Check CSS settings
        let css = settings.css

        if css.customCSSOverride && !css.hasCustomCSS {
            issues.append(ValidationIssue(
                severity: .warning,
                property: "customCSSOverride",
                message: "CSS override enabled but no custom CSS configured"
            ))
        }

        return issues
    }

    /// Checks if settings have any validation errors
    /// - Parameter settings: Settings to check
    /// - Returns: True if settings are valid
    func isValid(_ settings: AppSettings) async -> Bool {
        let issues = await validate(settings)
        return issues.filter { $0.severity == .error }.isEmpty
    }
}

// MARK: - Validation Issue Model

/// Represents a settings validation issue
struct ValidationIssue: Sendable {
    enum Severity: String, Sendable {
        case error = "ERROR"
        case warning = "WARNING"
        case info = "INFO"
    }

    let severity: Severity
    let property: String
    let message: String
}
