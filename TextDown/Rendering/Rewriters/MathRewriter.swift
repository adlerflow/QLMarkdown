//
//  MathRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for $math$ expressions
//  Converts $E=mc^2$ → \(E=mc^2\) for MathJax rendering
//
//  Created by adlerflow on 2025-11-02
//
//  ⚠️ CRITICAL: THIS IS A FRAGILE IMPLEMENTATION
//  This rewriter has KNOWN LIMITATIONS due to lack of custom inline delimiter
//  parsing in swift-markdown. DO NOT EXPECT PARITY WITH cmark-gfm math extension!
//

import Foundation
import Markdown
import OSLog

/// Rewriter that converts $...$ to MathJax delimiters
///
/// Examples:
/// - Inline: `$E=mc^2$` → `\\(E=mc^2\\)`
/// - Display: `$$x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}$$` → `\\[...\\]`
///
/// ⚠️ KNOWN LIMITATIONS (FRAGILE REGEX-BASED PARSING):
///
/// 1. **Dollar Signs in Text**: May incorrectly match literal $ symbols
///    - Example: `I have $5 and you have $10` → BROKEN
///    - Workaround: Escape with backslash: `\$5`
///
/// 2. **Escaped Delimiters**: Backslash escaping may not work correctly
///    - Example: `\$5` may still be parsed as math start
///
/// 3. **Nested Delimiters**: Cannot handle nested $ inside $$
///    - Example: `$$outer $inner$ outer$$` → BROKEN
///
/// 4. **Multi-Line Math**: Display math must be on single paragraph
///    - Works: `$$x = 1$$` (single line)
///    - Breaks: `$$\nx = 1\n$$` (multi-line in separate nodes)
///
/// 5. **Code Blocks**: May leak into code if text nodes overlap
///
/// 6. **Complex LaTeX**: Commands with $ may break:
///    - Example: `$\text{cost: $5}$` → BROKEN
///
/// For production-grade math support, consider:
/// - Forking swift-markdown to add custom delimiter API
/// - Using a dedicated LaTeX parser (e.g., KaTeX native parser)
///
struct MathRewriter: MarkupRewriter {
    let enabled: Bool
    var mathBlockCount: Int = 0

    init(enabled: Bool = true) {
        self.enabled = enabled
    }

    mutating func visitText(_ text: Markdown.Text) -> Markup? {
        guard enabled else { return text }

        // Don't process text inside code blocks or code spans
        if isInCodeContext(text) {
            return text
        }

        var result = text.string

        // Process display math first ($$...$$) to avoid conflict with inline math
        result = processDisplayMath(in: result)

        // Process inline math ($...$)
        result = processInlineMath(in: result)

        if result != text.string {
            return Markdown.Text(result)
        }

        return text
    }

    /// Process display math $$...$$
    /// Converts to MathJax display delimiter: \\[...\\]
    private mutating func processDisplayMath(in input: String) -> String {
        // Pattern: $$math$$ (non-greedy, single line only)
        // ⚠️ FRAGILE: Won't match multi-line display math
        let pattern = /\$\$([^\n$]+)\$\$/

        var result = input
        for match in input.matches(of: pattern) {
            mathBlockCount += 1
            let content = String(match.1)
            let original = "$$\(content)$$"

            // MathJax display delimiters
            let replacement = "\\\\[\(content)\\\\]"

            result = result.replacingOccurrences(of: original, with: replacement)
        }

        return result
    }

    /// Process inline math $...$
    /// Converts to MathJax inline delimiter: \\(...\\)
    private func processInlineMath(in input: String) -> String {
        // Pattern: $math$ (non-greedy, no newlines, no nested $)
        // ⚠️ FRAGILE: May match unintended dollar signs
        //
        // Heuristics to reduce false positives:
        // - Content must contain at least one letter or backslash (LaTeX command)
        // - No spaces at boundaries (to avoid "I have $5 and $10")
        let pattern = /\$([^\n$]*[a-zA-Z\\][^\n$]*)\$/

        var result = input
        for match in input.matches(of: pattern) {
            let content = String(match.1).trimmingCharacters(in: .whitespaces)

            // Skip if content looks like a price (only digits and punctuation)
            if content.range(of: #"^[\d,.\s]+$"#, options: .regularExpression) != nil {
                os_log("Skipping math pattern that looks like price: $%{public}@$", log: OSLog.rendering, type: .debug, content)
                continue
            }

            let original = "$\(match.1)$"

            // MathJax inline delimiters
            let replacement = "\\\\(\(content)\\\\)"

            result = result.replacingOccurrences(of: original, with: replacement, options: .literal)
        }

        return result
    }

    private func isInCodeContext(_ text: Markdown.Text) -> Bool {
        var current: Markup? = text
        while let parent = current?.parent {
            if parent is CodeBlock || parent is InlineCode {
                return true
            }
            current = parent
        }
        return false
    }

    /// Get count of math blocks processed (for MathJax inclusion decision)
    func hasMathContent() -> Bool {
        return mathBlockCount > 0
    }
}
