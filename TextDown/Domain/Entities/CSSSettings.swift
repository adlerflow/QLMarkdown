import Foundation

/// Custom CSS configuration for markdown preview
/// Thread-safe value type for concurrent access
struct CSSSettings: Sendable, Codable, Equatable {
    // MARK: - Properties

    /// URL to external CSS file
    var customCSS: URL?

    /// Inline CSS code
    var customCSSCode: String?

    /// Whether CSS has been fetched from URL
    var customCSSFetched: Bool

    /// Override default styles completely (vs merge)
    var customCSSOverride: Bool

    // MARK: - Defaults

    static let `default` = CSSSettings(
        customCSS: nil,
        customCSSCode: nil,
        customCSSFetched: false,
        customCSSOverride: false
    )

    // MARK: - Computed Properties

    /// Whether any custom CSS is configured
    var hasCustomCSS: Bool {
        customCSS != nil || customCSSCode != nil
    }

    /// Whether custom CSS should be loaded from URL
    var shouldFetchCSS: Bool {
        customCSS != nil && !customCSSFetched
    }

    // MARK: - Validation

    /// Validates CSS settings
    /// - Returns: Validated settings with corrections applied
    func validated() -> CSSSettings {
        // If no CSS URL, clear the fetched flag
        if customCSS == nil && customCSSFetched {
            return CSSSettings(
                customCSS: nil,
                customCSSCode: customCSSCode,
                customCSSFetched: false,
                customCSSOverride: customCSSOverride
            )
        }

        // If override is enabled but no custom CSS, disable override
        if customCSSOverride && !hasCustomCSS {
            return CSSSettings(
                customCSS: customCSS,
                customCSSCode: customCSSCode,
                customCSSFetched: customCSSFetched,
                customCSSOverride: false
            )
        }

        return self
    }
}
