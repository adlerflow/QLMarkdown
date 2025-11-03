import SwiftUI
import UniformTypeIdentifiers

/// Pure SwiftUI FileDocument implementation for markdown files
struct MarkdownFileDocument: FileDocument {
    // MARK: - Readable Content Types

    static var readableContentTypes: [UTType] {
        [
            .plainText,
            UTType("net.daringfireball.markdown")!,
            .rMarkdown,
            .qmdMarkdown
        ]
    }

    // MARK: - Content

    var content: String

    // MARK: - Initialization

    init(content: String = "") {
        self.content = content
    }

    // MARK: - FileDocument Protocol

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        // Try UTF-8 first, fallback to other encodings
        if let string = String(data: data, encoding: .utf8) {
            content = string
        } else if let string = String(data: data, encoding: .isoLatin1) {
            content = string
        } else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Custom UTTypes

extension UTType {
    /// R Markdown (.rmd)
    static let rMarkdown = UTType(
        importedAs: "com.rstudio.rmarkdown",
        conformingTo: .plainText
    )

    /// Quarto Markdown (.qmd)
    static let qmdMarkdown = UTType(
        importedAs: "org.quarto.qmarkdown",
        conformingTo: .plainText
    )
}

// MARK: - UTType Extensions for Markdown

extension UTType {
    /// Check if UTType is a markdown variant
    var isMarkdown: Bool {
        conforms(to: .plainText) ||
        conforms(to: .rMarkdown) ||
        conforms(to: .qmdMarkdown) ||
        identifier == "net.daringfireball.markdown" ||
        identifier == "public.markdown"
    }
}
