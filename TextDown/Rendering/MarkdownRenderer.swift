//
//  MarkdownRenderer.swift
//  TextDown
//
//  Main orchestration class for swift-markdown rendering pipeline
//  Coordinates: Parsing → Rewriters → HTML → Post-Processing
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown
import SwiftSoup
import OSLog

/// Main markdown rendering engine using swift-markdown
///
/// Pipeline:
/// 1. Parse markdown string → Document AST
/// 2. Apply custom rewriters (emoji, math, images, etc.)
/// 3. Convert to HTML via swift-markdown's HTMLFormatter
/// 4. Post-process HTML (heading IDs, CSS injection, MathJax)
/// 5. Return complete HTML document
struct MarkdownRenderer {
    let settings: AppConfiguration

    init(settings: AppConfiguration) {
        self.settings = settings
    }

    /// Render markdown to HTML
    /// - Parameters:
    ///   - markdown: Raw markdown string
    ///   - filename: Filename for extension-based processing (.rmd, .qmd)
    ///   - baseDirectory: Base directory for resolving relative image paths
    ///   - appearance: Light/Dark mode for styling
    /// - Returns: Complete HTML document string
    /// - Throws: Rendering errors
    func render(markdown: String, filename: String = "", baseDirectory: URL, appearance: Appearance) throws -> String {
        os_log("MarkdownRenderer.render() called with swift-markdown", log: OSLog.rendering, type: .info)

        // STAGE 1: YAML Header Processing (for R Markdown .rmd/.qmd files)
        let yamlProcessor = YamlHeaderProcessor(settings: settings)
        let (processedMarkdown, yamlHeader) = yamlProcessor.extractYamlHeader(from: markdown, filename: filename)

        if !yamlHeader.isEmpty {
            os_log("Extracted YAML header (%d bytes)", log: OSLog.rendering, type: .debug, yamlHeader.count)
        }

        // STAGE 2: Parse Options Configuration
        var parseOptions: ParseOptions = []

        // Disable smart quotes/dashes if user preference set
        if settings.smartQuotesOption {
            // Note: ParseOptions.disableSmartOpts DISABLES smart quotes
            // Our setting is "enable smart quotes", so we DON'T add the option
        } else {
            parseOptions.insert(.disableSmartOpts)
        }

        // STAGE 3: Parse markdown
        let document = Document(parsing: processedMarkdown, options: parseOptions)
        os_log("Parsed markdown document with %d children", log: OSLog.rendering, type: .debug, document.childCount)

        // STEP 2: Apply rewriters
        var transformed = document as Markup

        // Apply rewriters in sequence
        if settings.emojiExtension {
            var rewriter = EmojiRewriter(useCharacters: true)
            transformed = rewriter.visit(transformed) ?? transformed
        }

        if settings.highlightExtension {
            var rewriter = HighlightRewriter(enabled: true)
            transformed = rewriter.visit(transformed) ?? transformed
        }

        if settings.subExtension || settings.supExtension {
            var rewriter = SubSupRewriter(
                subscriptEnabled: settings.subExtension,
                superscriptEnabled: settings.supExtension
            )
            transformed = rewriter.visit(transformed) ?? transformed
        }

        if settings.mentionExtension {
            var rewriter = MentionRewriter(enabled: true)
            transformed = rewriter.visit(transformed) ?? transformed
        }

        if settings.inlineImageExtension {
            var rewriter = InlineImageRewriter(
                baseDirectory: baseDirectory,
                enabled: true
            )
            transformed = rewriter.visit(transformed) ?? transformed
        }

        if settings.mathExtension {
            var rewriter = MathRewriter(enabled: true)
            transformed = rewriter.visit(transformed) ?? transformed
        }

        // STAGE 4: Convert to HTML using HTMLFormatter
        let htmlBody = HTMLFormatter.format(transformed)
        os_log("HTML generation complete, length: %d", log: OSLog.rendering, type: .debug, htmlBody.count)

        // STAGE 5: Post-process HTML
        let finalHTML = try postProcessHTML(htmlBody, yamlHeader: yamlHeader, appearance: appearance)

        return finalHTML
    }

    /// Post-process HTML: Add heading IDs, inject CSS/JS, prepend YAML header
    private func postProcessHTML(_ htmlBody: String, yamlHeader: String, appearance: Appearance) throws -> String {
        // Parse HTML fragment
        let doc = try SwiftSoup.parseBodyFragment(htmlBody)
        guard let body = doc.body() else {
            throw MarkdownRenderingError.postProcessingFailed("Failed to parse HTML body")
        }

        // Add heading IDs (for table of contents, anchor links)
        if settings.headsExtension {
            try addHeadingIDs(to: body)
        }

        // Build complete HTML document with CSS/JS
        return try buildCompleteHTML(body: try body.html(), yamlHeader: yamlHeader, appearance: appearance)
    }

    /// Add unique ID attributes to all headings
    private func addHeadingIDs(to body: Element) throws {
        var idGenerator = HeadingIDGenerator()

        for heading in try body.select("h1, h2, h3, h4, h5, h6") {
            let text = try heading.text()
            let id = idGenerator.generateID(from: text)
            try heading.attr("id", id)
        }
    }

    /// Build complete HTML document with CSS and JavaScript
    private func buildCompleteHTML(body: String, yamlHeader: String = "", appearance: Appearance) throws -> String {
        var html = """
        <!doctype html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Rendered Markdown</title>
        """

        // Add base CSS
        if let cssPath = settings.resourceBundle.path(forResource: "default", ofType: "css"),
           let css = try? String(contentsOfFile: cssPath, encoding: .utf8) {
            html += "<style>\n\(css)\n</style>\n"
        }

        // Add custom CSS if provided
        if let customCSS = settings.customCSSCode, !customCSS.isEmpty {
            html += "<style>\n\(customCSS)\n</style>\n"
        }

        // Add highlight.js CSS theme
        if settings.syntaxHighlightExtension {
            let theme = appearance == .light ? settings.syntaxThemeLightOption : settings.syntaxThemeDarkOption

            if let cssPath = settings.resourceBundle.path(forResource: "\(theme).min", ofType: "css", inDirectory: "highlight.js/styles"),
               let css = try? String(contentsOfFile: cssPath, encoding: .utf8) {
                html += "<style>\n\(css)\n</style>\n"
            }
        }

        // Add MathJax if math content present
        if settings.mathExtension && body.contains("\\\\(") || body.contains("\\\\[") {
            html += """
            <script>
            MathJax = {
              tex: {
                inlineMath: [['\\\\(', '\\\\)']],
                displayMath: [['\\\\[', '\\\\]']],
              },
              svg: {
                fontCache: 'global'
              }
            };
            </script>
            <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
            """
        }

        html += "</head>\n<body>\n"

        // Add debug info table if enabled
        if settings.debug {
            html += """
            <div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0; background: #f5f5f5;">
                <h4>Debug Information</h4>
                <table style="font-size: 12px; border-collapse: collapse;">
                    <tr><td><strong>Rendering Engine:</strong></td><td>swift-markdown</td></tr>
                    <tr><td><strong>Appearance:</strong></td><td>\(appearance == .light ? "Light" : "Dark")</td></tr>
                    <tr><td><strong>Emoji:</strong></td><td>\(settings.emojiExtension ? "Enabled" : "Disabled")</td></tr>
                    <tr><td><strong>Math:</strong></td><td>\(settings.mathExtension ? "Enabled" : "Disabled")</td></tr>
                    <tr><td><strong>Syntax Highlighting:</strong></td><td>\(settings.syntaxHighlightExtension ? "Enabled" : "Disabled")</td></tr>
                    <tr><td><strong>Tables:</strong></td><td>\(settings.tableExtension ? "Enabled (GFM)" : "Disabled")</td></tr>
                    <tr><td><strong>YAML Header:</strong></td><td>\(!yamlHeader.isEmpty ? "Extracted (\(yamlHeader.count) bytes)" : "None")</td></tr>
                </table>
            </div>
            """
        }

        // Add YAML header if extracted (R Markdown .rmd/.qmd files)
        if !yamlHeader.isEmpty {
            html += yamlHeader + "\n"
        }

        // Add body content
        html += body

        // Add about footer if enabled
        if settings.about {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            html += """
            <hr style="margin-top: 40px;">
            <footer style="text-align: center; color: #888; font-size: 12px; padding: 20px;">
                <p>Rendered with <strong>TextDown</strong> v\(version) (build \(build))</p>
                <p>Powered by swift-markdown | © 2025 adlerflow</p>
            </footer>
            """
        }

        html += "\n</body>\n"

        // Add highlight.js JavaScript
        if settings.syntaxHighlightExtension {
            if let jsPath = settings.resourceBundle.path(forResource: "highlight.min", ofType: "js", inDirectory: "highlight.js/lib"),
               let js = try? String(contentsOfFile: jsPath, encoding: .utf8) {
                html += "<script>\n\(js)\n</script>\n"
                html += """
                <script>
                document.addEventListener('DOMContentLoaded', function() {
                    document.querySelectorAll('pre code').forEach(function(block) {
                        hljs.highlightElement(block);
                    });
                });
                </script>
                """
            }
        }

        html += "</html>"

        return html
    }
}

/// Rendering errors
enum MarkdownRenderingError: Error {
    case notImplemented
    case parsingFailed(String)
    case rewriterFailed(String)
    case postProcessingFailed(String)
}
