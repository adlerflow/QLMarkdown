//
//  YamlHeaderProcessor.swift
//  TextDown
//
//  YAML frontmatter processing for R Markdown (.rmd) and Quarto (.qmd) files
//  Extracts YAML header and renders as HTML table
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Yams
import OSLog

/// Processes YAML frontmatter in R Markdown and Quarto documents
struct YamlHeaderProcessor {
    let settings: Settings

    /// Extract and process YAML header from markdown text
    /// - Parameters:
    ///   - markdown: Full markdown text (may start with YAML frontmatter)
    ///   - filename: File name for extension-based processing (.rmd, .qmd)
    /// - Returns: Tuple of (processed markdown, html header)
    func extractYamlHeader(from markdown: String, filename: String) -> (markdown: String, header: String) {
        // Check if YAML processing is enabled
        guard settings.yamlExtension else {
            return (markdown, "")
        }

        // Check if file type requires YAML processing
        let shouldProcess = settings.yamlExtensionAll ||
                           filename.lowercased().hasSuffix("rmd") ||
                           filename.lowercased().hasSuffix("qmd")

        guard shouldProcess && markdown.hasPrefix("---") else {
            return (markdown, "")
        }

        // YAML frontmatter pattern:
        // ---
        // key: value
        // ---
        // OR
        // ---
        // key: value
        // ...
        //
        // Pattern explanation:
        // (?s): Dot matches newline (single line mode)
        // (?<=---\n): Positive lookbehind - YAML must start after "---\n"
        // .*?: Match YAML content (non-greedy)
        // (?>\n(?:---|\.\.\.)\n): Atomic group - YAML ends with "---\n" or "...\n"
        let pattern = "(?s)((?<=---\n).*?(?>\n(?:---|\\.\\.\\.)\n))"

        guard let range = markdown.range(of: pattern, options: .regularExpression) else {
            os_log("YAML pattern not matched", log: OSLog.rendering, type: .debug)
            return (markdown, "")
        }

        // Extract YAML content (without closing delimiter)
        let yamlEndIndex = markdown.index(range.upperBound, offsetBy: -4)
        let yamlContent = String(markdown[range.lowerBound..<yamlEndIndex])

        // Remaining markdown after YAML block
        let remainingMarkdown = String(markdown[range.upperBound...])

        // Render YAML as HTML
        let (htmlHeader, isHTML) = renderYamlHeader(yamlContent)

        if isHTML {
            // YAML rendered as HTML table - inject as header, remove from markdown
            return (remainingMarkdown, htmlHeader)
        } else {
            // YAML rendering failed - keep as code block in markdown
            return (htmlHeader + remainingMarkdown, "")
        }
    }

    /// Render YAML frontmatter as HTML table
    /// - Parameter yamlText: Raw YAML text
    /// - Returns: Tuple of (HTML string, isHTML flag)
    private func renderYamlHeader(_ yamlText: String) -> (html: String, isHTML: Bool) {
        guard settings.tableExtension else {
            // Fallback: Render as YAML code block if tables disabled
            return ("```yaml\n\(yamlText)```\n", false)
        }

        do {
            // Parse YAML using Yams library
            guard let node = try Yams.compose(yaml: yamlText),
                  let yamlDict = try parseYamlNode(node) as? [(key: AnyHashable, value: Any)] else {
                // Parsing failed - fallback to code block
                return ("```yaml\n\(yamlText)```\n", false)
            }

            // Successfully parsed - render as HTML table
            let htmlTable = renderYamlAsTable(yamlDict)
            return (htmlTable, true)

        } catch {
            os_log("YAML parsing error: %{public}@", log: OSLog.rendering, type: .error, error.localizedDescription)
            // Fallback: Render as code block
            return ("```yaml\n\(yamlText)```\n", false)
        }
    }

    /// Parse Yams Node into Swift dictionary/array structure
    /// - Parameter node: Yams.Node from compose()
    /// - Returns: Parsed structure (dictionary or array)
    private func parseYamlNode(_ node: Node) throws -> Any? {
        switch node {
        case .scalar(let scalar):
            // Leaf node - return string value
            return scalar.string

        case .mapping(let mapping):
            // Dictionary node - recurse into key-value pairs
            var result: [(key: AnyHashable, value: Any)] = []
            for (keyNode, valueNode) in mapping {
                guard let key = try parseYamlNode(keyNode) as? String else {
                    continue // Skip non-string keys
                }
                if let value = try parseYamlNode(valueNode) {
                    result.append((key: key, value: value))
                }
            }
            return result

        case .sequence(let sequence):
            // Array node - recurse into elements
            var result: [Any] = []
            for itemNode in sequence {
                if let item = try parseYamlNode(itemNode) {
                    result.append(item)
                }
            }
            return result
        }
    }

    /// Render parsed YAML as HTML table
    /// - Parameter yaml: Parsed YAML dictionary
    /// - Returns: HTML table string
    private func renderYamlAsTable(_ yaml: [(key: AnyHashable, value: Any)]) -> String {
        guard !yaml.isEmpty else {
            return ""
        }

        var html = "<table>\n"

        for element in yaml {
            let key = "<strong>\(element.key)</strong>"
            html += "<tr><td align='right'>\(key)</td><td>"

            // Recursively render value based on type
            if let nestedDict = element.value as? [(key: AnyHashable, value: Any)] {
                // Nested dictionary - recurse
                html += renderYamlAsTable(nestedDict)

            } else if let array = element.value as? [Any] {
                // Array - render as <ul>
                html += "<ul>\n"
                html += array.map { item in
                    return "<li>\(item)</li>"
                }.joined(separator: "\n")
                html += "\n</ul>"

            } else if let string = element.value as? String {
                // String value - escape HTML
                html += string

            } else {
                // Other types - convert to string
                html += "\(element.value)"
            }

            html += "</td></tr>\n"
        }

        html += "</table>\n"
        return html
    }
}
