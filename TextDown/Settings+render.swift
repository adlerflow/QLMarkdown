//
//  Settings+render.swift
//  TextDown
//
//  Created by adlerflow on 06/05/25.
//  swift-markdown migration: 2025-11-02
//

import Foundation
import OSLog
import SwiftSoup
import Yams
import Markdown  // swift-markdown package

extension Settings {
    func render(text: String, filename: String, forAppearance appearance: Appearance, baseDir: String) throws -> String {
        os_log("render() called with swift-markdown", log: OSLog.rendering, type: .info)

        // Use MarkdownRenderer for swift-markdown pipeline
        let renderer = MarkdownRenderer(settings: self)
        let baseDirectory = URL(fileURLWithPath: baseDir)

        return try renderer.render(markdown: text, filename: filename, baseDirectory: baseDirectory, appearance: appearance)
    }

    /// Helper function: Wraps HTML body in complete document structure
    ///
    /// NOTE: This is kept for compatibility with DocumentViewController, but MarkdownRenderer
    /// already generates complete HTML documents, so this may be redundant.
    func getCompleteHTML(title: String, body: String, header: String = "", footer: String = "", basedir: URL, forAppearance appearance: Appearance) -> String {
        // MarkdownRenderer already generates complete HTML, so just return body
        // with minimal wrapping if header/footer are provided
        if header.isEmpty && footer.isEmpty {
            return body
        }

        // Check if body is already a complete HTML document
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedBody.lowercased().hasPrefix("<!doctype html>") || trimmedBody.lowercased().hasPrefix("<html") {
            // Body is already complete HTML - inject header/footer using SwiftSoup
            do {
                let doc = try SwiftSoup.parse(body)

                // Inject header into <head> tag
                if !header.isEmpty, let head = doc.head() {
                    try head.append(header)
                }

                // Inject footer at end of <body> tag
                if !footer.isEmpty, let bodyTag = doc.body() {
                    try bodyTag.append(footer)
                }

                return try doc.html()
            } catch {
                os_log("Failed to inject header/footer into HTML: %{public}@", log: OSLog.rendering, type: .error, error.localizedDescription)
                // Fallback: return body as-is
                return body
            }
        }

        // Body is HTML fragment - wrap it
        return """
        <!doctype html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>\(title)</title>
        </head>
        <body>
            \(header)
            \(body)
            \(footer)
        </body>
        </html>
        """
    }
}

/*
 ===============================================================================
 NOTE: OLD CMARK-GFM IMPLEMENTATION EXTRACTED
 ===============================================================================

 The original 765-line cmark-gfm implementation has been extracted to:
 TextDown/Settings+render.txt

 Use that file as reference for implementing missing features
 Date: 2025-11-02
 ===============================================================================
*/
