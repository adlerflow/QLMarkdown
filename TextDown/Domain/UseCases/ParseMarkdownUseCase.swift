import Foundation
import Markdown

/// Use case for parsing markdown text with configured settings
/// Thread-safe actor that orchestrates markdown parsing operations
actor ParseMarkdownUseCase {
    // MARK: - Dependencies

    private let parserRepository: MarkdownParserRepository

    // MARK: - Initialization

    init(parserRepository: MarkdownParserRepository) {
        self.parserRepository = parserRepository
    }

    // MARK: - Business Logic

    /// Parses markdown text using configured settings
    /// - Parameters:
    ///   - markdown: Raw markdown text
    ///   - settings: Markdown rendering settings
    /// - Returns: Parsed markdown document (AST)
    /// - Throws: ParseError if parsing fails
    func execute(markdown: String, settings: MarkdownSettings) async throws -> Document {
        // Validate settings before parsing
        let validatedSettings = settings.validated()

        // Check complexity for performance warning
        let complexity = await parserRepository.estimateComplexity(markdown)
        if complexity > 5000 {
            print("⚠️ High complexity markdown (\(complexity)ms estimated) - may cause UI lag")
        }

        // Parse with validated settings
        let document = try await parserRepository.parse(markdown, settings: validatedSettings)

        return document
    }

    /// Validates markdown syntax without full parsing
    /// - Parameter markdown: Raw markdown text
    /// - Returns: True if markdown is syntactically valid
    func validate(markdown: String) async -> Bool {
        await parserRepository.validate(markdown)
    }

    /// Estimates parsing time for performance optimization
    /// - Parameter markdown: Raw markdown text
    /// - Returns: Estimated parsing time in milliseconds
    func estimateComplexity(markdown: String) async -> Int {
        await parserRepository.estimateComplexity(markdown)
    }
}
