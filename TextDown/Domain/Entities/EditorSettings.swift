import Foundation

/// Editor behavior and UI settings
/// Thread-safe value type for concurrent access
struct EditorSettings: Sendable, Codable, Equatable {
    // MARK: - Properties

    /// Automatically refresh preview on content change
    var autoRefresh: Bool

    /// Open inline links in external browser
    var openInlineLink: Bool

    /// Enable debug mode for diagnostics
    var debug: Bool

    // MARK: - Defaults

    static let `default` = EditorSettings(
        autoRefresh: true,
        openInlineLink: false,
        debug: false
    )

    // MARK: - Validation

    /// Validates editor settings
    /// - Returns: Validated settings with corrections applied
    func validated() -> EditorSettings {
        // All current settings are valid (simple booleans)
        // Could add validation rules in future (e.g., performance constraints)
        return self
    }
}
