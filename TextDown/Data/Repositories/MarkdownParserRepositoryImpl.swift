import Foundation
import Markdown

/// Concrete implementation of MarkdownParserRepository using swift-markdown
/// Wraps Apple's swift-markdown library and converts to domain entities
actor MarkdownParserRepositoryImpl: MarkdownParserRepository {
    // MARK: - Initialization

    init() {}

    // MARK: - MarkdownParserRepository

    func parse(_ markdown: String, settings: MarkdownSettings) async throws -> Document {
        // Parse using swift-markdown
        var document = Document(parsing: markdown)

        // Apply GitHub Flavored Markdown options
        // Note: swift-markdown has built-in GFM support, configuration happens at parse time
        // The settings parameter is available for future custom processing

        return document
    }

    func validate(_ markdown: String) async -> Bool {
        // swift-markdown is lenient and doesn't fail on invalid syntax
        // We consider markdown valid if it can be parsed without crashing
        do {
            _ = Document(parsing: markdown)
            return true
        } catch {
            return false
        }
    }

    func estimateComplexity(_ markdown: String) async -> Int {
        // Simple heuristic based on content size and structure
        let lineCount = markdown.components(separatedBy: .newlines).count
        let characterCount = markdown.count

        // Estimate: ~0.1ms per line + ~0.001ms per character
        let estimatedMS = (lineCount / 10) + (characterCount / 1000)

        return max(1, estimatedMS)
    }
}
