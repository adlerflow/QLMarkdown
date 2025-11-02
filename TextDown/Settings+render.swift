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
        os_log("render() called - swift-markdown STUB (old cmark-gfm implementation commented out below)", log: OSLog.rendering, type: .info)
        
        // TODO: Implement full swift-markdown rendering pipeline
        // For now, return minimal placeholder
        
        return """
        <!doctype html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Migration in Progress</title>
        </head>
        <body>
            <h1>⚠️ swift-markdown Migration WIP</h1>
            <pre>\(text.replacingOccurrences(of: "<", with: "&lt;"))</pre>
        </body>
        </html>
        """
    }

    /// Helper function: Wraps HTML body in complete document structure
    /// STUB - returns basic HTML document during migration
    func getCompleteHTML(title: String, body: String, header: String = "", footer: String = "", basedir: URL, forAppearance appearance: Appearance) -> String {
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
 OLD CMARK-GFM IMPLEMENTATION - COMMENTED OUT DURING SWIFT-MARKDOWN MIGRATION
 ===============================================================================
 
 This is the original 765-line render() function using cmark-gfm (C library).
 Kept as reference during migration. Will be deleted once new implementation
 is complete and tested.
 
 Branch: feature/swift-markdown-migration
 Date: 2025-11-02
 ===============================================================================
*/

/*
//
//  Settings+render.swift
//  TextDown
//
//  Created by adlerflow on 06/05/25.
//

import Foundation
import OSLog
import SwiftSoup
import Yams

extension Settings {
    func render(text: String, filename: String, forAppearance appearance: Appearance, baseDir: String) throws -> String {
        // renderAsCode feature removed - was server-side syntax highlighting via libhighlight
        // Code blocks now use client-side highlight.js

        cmark_gfm_core_extensions_ensure_registered()
        cmark_gfm_extra_extensions_ensure_registered()
        
        var options = CMARK_OPT_DEFAULT
        if self.unsafeHTMLOption {
            options |= CMARK_OPT_UNSAFE
        }
        
        if self.hardBreakOption {
            options |= CMARK_OPT_HARDBREAKS
        }
        if self.noSoftBreakOption {
            options |= CMARK_OPT_NOBREAKS
        }
        if self.validateUTFOption {
            options |= CMARK_OPT_VALIDATE_UTF8
        }
        if self.smartQuotesOption {
            options |= CMARK_OPT_SMART
        }
        if self.footnotesOption {
            options |= CMARK_OPT_FOOTNOTES
        }
        
        if self.strikethroughExtension && self.strikethroughDoubleTildeOption {
            options |= CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE
        }
        
        os_log("cmark_gfm options: %{public}d.", log: OSLog.rendering, type: .debug, options)
        
        guard let parser = cmark_parser_new(options) else {
            os_log("Unable to create new cmark_parser!", log: OSLog.rendering, type: .error, options)
            throw CMARK_Error.parser_create
        }
        defer {
            cmark_parser_free(parser)
        }
        
        /*
        var extensions: UnsafeMutablePointer<cmark_llist>? = nil
        defer {
            cmark_llist_free(cmark_get_default_mem_allocator(), extensions)
        }
        */
        
        if self.tableExtension {
            if let ext = cmark_find_syntax_extension("table") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown markdown `table` extension.", log: OSLog.rendering, type: .debug)
                // extensions = cmark_llist_append(cmark_get_default_mem_allocator(), nil, &ext)
            } else {
                os_log("Could not enable markdown `table` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.autoLinkExtension {
            if let ext = cmark_find_syntax_extension("autolink") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `autolink` extension.", log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `autolink` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.tagFilterExtension {
            if let ext = cmark_find_syntax_extension("tagfilter") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `tagfilter` extension.", log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `tagfilter` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.taskListExtension {
            if let ext = cmark_find_syntax_extension("tasklist") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `tasklist` extension.",  log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `tasklist` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        var md_text = text
        
        var header = ""
        
        if self.yamlExtension && (self.yamlExtensionAll || filename.lowercased().hasSuffix("rmd") || filename.lowercased().hasSuffix("qmd")) && md_text.hasPrefix("---") {
            /*
             (?s): Turn on "dot matches newline" for the remainder of the regular expression. For “single line mode” makes the dot match all characters, including line breaks.
             (?<=---\n): Positive lookbehind. Matches at a position if the pattern inside the lookbehind can be matched ending at that position. Find expression .* where expression `---\n` precedes.
             (?>\n(?:---|\.\.\.):
             (?:---|\.\.\.): not capturing group
             */
            let pattern = "(?s)((?<=---\n).*?(?>\n(?:---|\\.\\.\\.)\n))"
            if let range = md_text.range(of: pattern, options: .regularExpression) {
                let yaml = String(md_text[range.lowerBound ..< md_text.index(range.upperBound, offsetBy: -4)])
                var isHTML = false
                header = self.renderYamlHeader(yaml, isHTML: &isHTML)
                if isHTML {
                    md_text = String(md_text[range.upperBound ..< md_text.endIndex])
                } else {
                    md_text = header + md_text[range.upperBound ..< md_text.endIndex]
                    header = ""
                }
            }
        }
        
        if self.strikethroughExtension {
            if let ext = cmark_find_syntax_extension("strikethrough") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `strikethrough` extension.", log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `strikethrough` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.mentionExtension {
            if let ext = cmark_find_syntax_extension("mention") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `mention` extension.", log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `mention` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.headsExtension {
            if let ext = cmark_find_syntax_extension("heads") {
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `heads` extension.", log: OSLog.rendering, type: .debug)
            } else {
                os_log("Could not enable markdown `heads` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.highlightExtension {
            if let ext = cmark_find_syntax_extension("highlight") {
                cmark_parser_attach_syntax_extension(parser, ext)
                
                os_log(
                    "Enabled markdown `highlight` extension.",
                    log: OSLog.rendering,
                    type: .debug)
            } else {
                os_log("Could not enable markdown `highlight` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        
        if self.subExtension {
            if let ext = cmark_find_syntax_extension("sub") {
                cmark_parser_attach_syntax_extension(parser, ext)
                
                os_log(
                    "Enabled markdown `sub` extension.",
                    log: OSLog.rendering,
                    type: .debug)
            } else {
                os_log("Could not enable markdown `sub` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.supExtension {
            if let ext = cmark_find_syntax_extension("sup") {
                cmark_parser_attach_syntax_extension(parser, ext)
                
                os_log(
                    "Enabled markdown `sup` extension.",
                    log: OSLog.rendering,
                    type: .debug)
            } else {
                os_log("Could not enable markdown `sup` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.inlineImageExtension {
            if let ext = cmark_find_syntax_extension("inlineimage") {
                cmark_parser_attach_syntax_extension(parser, ext)
                cmark_syntax_extension_inlineimage_set_wd(ext, baseDir.cString(using: .utf8))
                // MIME callback removed - inlineimage extension uses libmagic internally
                /*
                cmark_syntax_extension_inlineimage_set_remote_data_callback(ext, { (url, context) -> UnsafeMutablePointer<Int8>? in
                    guard let uu = url, let u = URL(string: String(cString: uu)) else {
                        return nil
                    }
                    do {
                        let data = try Data(contentsOf: u)
                    } catch {
                        os_log("Error fetch data from %{public}@: %{public}@", log: OSLog.rendering, type: .error, String(cString: uu), error.localizedDescription)
                        return nil
                    }
                    return nil
                }, nil)
                */
                
                os_log("Enabled markdown `local inline image` extension with working path set to `%{public}s`.", log: OSLog.rendering, type: .debug, baseDir)

                /*
                // unsafe HTML processor callback disabled - requires wrapper_highlight magic functions
                if self.unsafeHTMLOption {
                    cmark_syntax_extension_inlineimage_set_unsafe_html_processor_callback(ext, { (ext, fragment, workingDir, context, code) in
                        guard let fragment = fragment else {
                            return
                        }
                        
                        let baseDir: URL
                        if let s = workingDir {
                            let b = String(cString: s)
                            baseDir = URL(fileURLWithPath: b)
                        } else {
                            baseDir = URL(fileURLWithPath: "")
                        }
                        let html = String(cString: fragment)
                        var changed = false
                        do {
                            let doc = try SwiftSoup.parseBodyFragment(html, baseDir.path)
                            for img in try doc.select("img") {
                                let src = try img.attr("src")
                                
                                guard !src.isEmpty, !src.hasPrefix("http"), !src.hasPrefix("HTTP") else {
                                    // Do not handle external image.
                                    continue
                                }
                                guard !src.hasPrefix("data:") else {
                                    // Do not reprocess data: image.
                                    continue
                                }
                                
                                let file = baseDir.appendingPathComponent(src).path
                                guard FileManager.default.fileExists(atPath: file) else {
                                    os_log("Image %{private}@ not found!", log: OSLog.rendering, type: .error)
                                    continue // File not found.
                                }
                                guard let data = get_base64_image(
                                    file.cString(using: .utf8),
                                    nil, // No MIME callback - browser handles it automatically
                                    nil,
                                    /*{ (url, _ )->UnsafeMutablePointer<Int8>? in
                                        guard let s = url else {
                                            return nil
                                        }
                                        let u = URL(fileURLWithPath: String(cString: s))
                                        guard let data = try? Data(contentsOf: u) else {
                                            return nil
                                        }
                                        return nil
                                    }*/ nil,
                                    nil
                                ) else {
                                    continue
                                }
                                defer {
                                    data.deallocate()
                                }
                                let img_data = String(cString: data)
                                try img.attr("src", img_data)
                                changed = true
                            }
                            if changed, let html = try doc.body()?.html(), let s = strdup(html) {
                                code?.pointee = UnsafePointer(s)
                            }
                        } catch Exception.Error(_, let message) {
                            os_log("Error processing html: %{public}@!", log: OSLog.rendering, type: .error, message)
                        } catch {
                            os_log("Error parsing html: %{public}@!", log: OSLog.rendering, type: .error, error.localizedDescription)
                        }
                    }, nil)
                }
                */
            } else {
                os_log("Could not enable markdown `local inline image` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.emojiExtension {
            if let ext = cmark_find_syntax_extension("emoji") {
                cmark_syntax_extension_emoji_set_use_characters(ext, !self.emojiImageOption)
                cmark_parser_attach_syntax_extension(parser, ext)
                os_log("Enabled markdown `emoji` extension using %{public}s.", log: OSLog.rendering, type: .debug, self.emojiImageOption ? "images" : "glyphs")
            } else {
                os_log("Could not enable markdown `emoji` extension!", log: OSLog.rendering, type: .error)
            }
        }
        
        if self.mathExtension {
            if let ext = cmark_find_syntax_extension("math") {
                cmark_parser_attach_syntax_extension(parser, ext)
                
                os_log(
                    "Enabled markdown `math` extension.",
                    log: OSLog.rendering,
                    type: .debug)
            } else {
                os_log("Could not enable markdown `math` extension!", log: OSLog.rendering, type: .error)
            }
        }

        // syntaxhighlight extension removed - will use highlight.js (client-side)

        cmark_parser_feed(parser, md_text, strlen(md_text))
        guard let doc = cmark_parser_finish(parser) else {
            throw CMARK_Error.parser_parse
        }
        defer {
            cmark_node_free(doc)
        }
        
        let about = self.about ? "<div style='font-size: 72%; margin-top: 1.5em; padding-top: .5em; -webkit-user-select: none;'><hr style='height: 0; border: none; border-top: 1px solid rgba(0,0,0,.5); box-shadow: 0 1px 1px rgba(255, 255, 255, .5)'/>\(self.app_version)</div>\n\(self.app_version2)" : ""
        
        let html_debug = self.renderDebugInfo(forAppearance: appearance, baseDir: baseDir)
        // Render
        if let html2 = cmark_render_html(doc, options, cmark_parser_get_syntax_extensions(parser)) {
            defer {
                free(html2)
            }
            
            return html_debug + header + String(cString: html2) + about
        } else {
            return html_debug + "<p>RENDER FAILED!</p>"
        }
    }
    
    internal func renderDebugInfo(forAppearance appearance: Appearance, baseDir: String) -> String
    {
        guard debug else {
            return ""
        }
        var html_debug = ""
        html_debug += """
<style type="text/css">
table.debug td {
    vertical-align: top;
    font-size: .8rem;
}
</style>
"""
        html_debug += "<table class='debug'>\n<caption>Debug info</caption>"
        var html_options = ""
        if self.unsafeHTMLOption || (self.emojiExtension && self.emojiImageOption) {
            html_options += "CMARK_OPT_UNSAFE "
        }
        
        if self.hardBreakOption {
            html_options += "CMARK_OPT_HARDBREAKS "
        }
        if self.noSoftBreakOption {
            html_options += "CMARK_OPT_NOBREAKS "
        }
        if self.validateUTFOption {
            html_options += "CMARK_OPT_VALIDATE_UTF8 "
        }
        if self.smartQuotesOption {
            html_options += "CMARK_OPT_SMART "
        }
        if self.footnotesOption {
            html_options += "CMARK_OPT_FOOTNOTES "
        }
        
        if self.strikethroughExtension && self.strikethroughDoubleTildeOption {
            html_options += "CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE "
        }

        html_debug += "<tr><td>options</td><td>\(html_options)</td></tr>\n"
        
        html_debug += "<tr><td>autolink extension</td><td>"
        if self.autoLinkExtension {
            html_debug += "on " + (cmark_find_syntax_extension("autolink") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>emoji extension</td><td>"
        if self.emojiExtension {
            html_debug += "on" + (cmark_find_syntax_extension("emoji") == nil ? " (NOT AVAILABLE" : "")
            html_debug += " / \(self.emojiImageOption ? "using images" : "using emoji")"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>heads extension</td><td>" + (self.headsExtension ?  "on" : "off") + "</td></tr>\n"
        
        html_debug += "<tr><td>highlight extension</td><td>"
        if self.highlightExtension {
            html_debug += "on " + (cmark_find_syntax_extension("highlight") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>inlineimage extension</td><td>"
        if self.inlineImageExtension {
            html_debug += "on" + (cmark_find_syntax_extension("inlineimage") == nil ? " (NOT AVAILABLE" : "")
            html_debug += "<br />basedir: \(baseDir)"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>math extension</td><td>"
        if self.mathExtension {
            html_debug += "on " + (cmark_find_syntax_extension("math") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>mention extension</td><td>"
        if self.mentionExtension {
            html_debug += "on " + (cmark_find_syntax_extension("mention") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>strikethrough extension</td><td>"
        if self.strikethroughExtension {
            html_debug += "on " + (cmark_find_syntax_extension("strikethrough") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>syntax highlighting extension</td><td>"
        if self.syntaxHighlightExtension {
            html_debug += "on (highlight.js - client-side)"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>sub extension</td><td>"
        if self.subExtension {
            html_debug += "on " + (cmark_find_syntax_extension("sub") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        html_debug += "<tr><td>sup extension</td><td>"
        if self.supExtension {
            html_debug += "on " + (cmark_find_syntax_extension("sup") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>table extension</td><td>"
        if self.tableExtension {
            html_debug += "on " + (cmark_find_syntax_extension("table") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>tagfilter extension</td><td>"
        if self.tagFilterExtension {
            html_debug += "on " + (cmark_find_syntax_extension("tagfilter") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"

        html_debug += "<tr><td>tasklist extension</td><td>"
        if self.taskListExtension {
            html_debug += "on " + (cmark_find_syntax_extension("tasklist") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>YAML extension</td><td>"
        if self.yamlExtension {
            html_debug += "on "+(self.yamlExtensionAll ? "for all files" : "only for .rmd and .qmd files")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>link</td><td>" + (self.openInlineLink ? "open inline" : "open in standard browser") + "</td></tr>\n"
        
        html_debug += "</table>\n"

        return html_debug
    }

    // renderCode() function removed - was server-side syntax highlighting via libhighlight
    // Feature: "Render as Code" (render entire markdown file as syntax-highlighted code)
    // Replaced by: Client-side highlight.js for code blocks within markdown

    func render(file url: URL, forAppearance appearance: Appearance, baseDir: String?) throws -> String {
        guard let data = FileManager.default.contents(atPath: url.path) else {
            os_log("Unable to read the file %{private}@", log: OSLog.rendering, type: .error, url.path)
            return ""
        }

        return try self.render(data: data, forAppearance: appearance, filename: url.lastPathComponent, baseDir: baseDir ?? url.deletingLastPathComponent().path)
    }

    func render(data: Data, forAppearance appearance: Appearance, filename: String = "file.md", baseDir: String) throws -> String {
        guard let markdown_string = String(data: data, encoding: .utf8) else {
            os_log("Unable to read the data %{private}@", log: OSLog.rendering, type: .error, data.base64EncodedString())
            return ""
        }

        return try self.render(text: markdown_string, filename: filename, forAppearance: appearance, baseDir: baseDir)
    }

    func getCompleteHTML(title: String, body: String, header: String = "", footer: String = "", basedir: URL, forAppearance appearance: Appearance) -> String {
        
        let css_doc: String
        let css_doc_extended: String
        
        var s_header = header
        var s_footer = footer
        
        let formatCSS = { (code: String?) -> String in
            guard let css = code, !css.isEmpty else {
                return ""
            }
            return "<style type='text/css'>\(css)\n</style>\n"
        }
            
        if !self.renderAsCode {
            let css = (self.customCSSFetched ? self.customCSSCode : self.getCustomCSSCode()) ?? ""
            if !css.isEmpty {
                css_doc_extended = formatCSS(css)
                if !self.customCSSOverride {
                    css_doc = formatCSS(getBundleContents(forResource: "default", ofType: "css"))
                } else {
                    css_doc = ""
                }
            } else {
                css_doc_extended = ""
                css_doc = formatCSS(getBundleContents(forResource: "default", ofType: "css"))
            }
            // css_doc = "<style type=\"text/css\">\n\(css_doc)\n</style>\n"
        } else {
            css_doc_extended = ""
            css_doc = ""
        }
            
        // CSS extraction for renderAsCode removed - was server-side syntax highlighting
        let css_highlight = ""

        if self.mathExtension, let ext = cmark_find_syntax_extension("math"), cmark_syntax_extension_math_get_rendered_count(ext) > 0 || body.contains("$") {
            s_header += """
<script type="text/javascript">
MathJax = {
  options: {
    enableMenu: \(self.debug ? "true" : "false"),
  },
  tex: {
    // packages: ['base'],        // extensions to use
    inlineMath: [              // start/end delimiter pairs for in-line math
      ['$', '$']
      // , ['\\(', '\\)']
    ],
    displayMath: [             // start/end delimiter pairs for display math
      ['$$', '$$']
      //, ['\\[', '\\]']
    ],
    processEscapes: true,       // use \\$ to produce a literal dollar sign
    processEnvironments: false
  }
};
</script>
"""
            s_footer += """
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>
"""
        }

        // Integrate highlight.js for client-side syntax highlighting
        if self.syntaxHighlightExtension {
            // Choose theme based on appearance parameter (not static property)
            let hlTheme = appearance == .light ? self.syntaxThemeLightOption : self.syntaxThemeDarkOption

            // Get bundle paths for highlight.js resources
            if let jsPath = self.resourceBundle.path(forResource: "highlight.min", ofType: "js", inDirectory: "highlight.js/lib"),
               let cssPath = self.resourceBundle.path(forResource: hlTheme + ".min", ofType: "css", inDirectory: "highlight.js/styles") {

                // Read file contents to inline them (WKWebView cross-origin security requires this)
                do {
                    let jsContent = try String(contentsOfFile: jsPath, encoding: .utf8)
                    let cssContent = try String(contentsOfFile: cssPath, encoding: .utf8)

                    // Inline CSS in header
                    s_header += """
<style type="text/css">
/* highlight.js theme: \(hlTheme) */
\(cssContent)
</style>
"""

                    // Inline JS and initialization in footer
                    s_footer += """
<script type="text/javascript">
/* highlight.js v11.11.1 */
\(jsContent)
</script>
<script type="text/javascript">
// Configure highlight.js
hljs.configure({
    ignoreUnescapedHTML: true,
    languages: [] // Auto-detect all languages
});

// Highlight all code blocks when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('pre code').forEach(function(block) {
            hljs.highlightElement(block);
        });
    });
} else {
    document.querySelectorAll('pre code').forEach(function(block) {
        hljs.highlightElement(block);
    });
}
</script>
"""
                    os_log("Enabled client-side syntax highlighting with theme: %{public}s (inlined ~155KB)", log: OSLog.rendering, type: .debug, hlTheme)
                } catch {
                    os_log("Failed to read highlight.js files: %{public}@", log: OSLog.rendering, type: .error, error.localizedDescription)
                }
            } else {
                os_log("highlight.js resources not found in bundle", log: OSLog.rendering, type: .error)
            }
        }

        let style = css_doc + css_highlight + css_doc_extended
        let wrapper_open = "<article class='markdown-body'>"
        let wrapper_close = "</article>"
        let body_style = ""
        let html =
"""
<!doctype html>
<html>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'>
<title>\(title)</title>
\(style)
\(s_header)
</head>
<body\(body_style)>
\(wrapper_open)
\(body)
\(wrapper_close)
\(s_footer)
</body>
</html>
"""
        return html
    }
    
    internal func parseYaml(node: Yams.Node) throws -> Any {
        switch node {
        case .scalar(let scalar):
            return scalar.string
        case .mapping(let mapping):
            var r: [(key: AnyHashable, value: Any)] = []
            for n in mapping {
                guard let k = try parseYaml(node: n.key) as? AnyHashable else {
                    continue
                }
                let v = try parseYaml(node: n.value)
                r.append((key: k, value: v))
            }
            return r
        case .sequence(let sequence):
            var r: [Any] = []
            for n in sequence {
                r.append(try parseYaml(node: n))
            }
            return r
        }
    }
    
    internal func renderYamlHeader(_ text: String, isHTML: inout Bool) -> String {
        if self.tableExtension {
            do {
                if let node = try Yams.compose(yaml: text), let yaml = try self.parseYaml(node: node) as? [(key: AnyHashable, value: Any)] {
                    isHTML = true
                    return renderYaml(yaml)
                }
            } catch {
                // print(error)
            }
        }
        // Embed the header inside a yaml block.
        isHTML = false
        return "```yaml\n"+text+"```\n"
    }
    
    internal func renderYaml(_ yaml: [(key: AnyHashable, value: Any)]) -> String {
        guard yaml.count > 0 else {
            return ""
        }
        
        var s = "<table>"
        for element in yaml {
            let key: String = "<strong>\(element.key)</strong>"
            /*
            do {
                key = try self.render(text: "**\(element.key)**", filename: "", forAppearance: .light, baseDir: "")
            } catch {
                key = "<strong>\(element.key)</strong>"
            }*/
            s += "<tr><td align='right'>\(key)</td><td>"
            if let t = element.value as? [(key: AnyHashable, value: Any)] {
                s += renderYaml(t)
            } else if let t = element.value as? [Any] {
                s += "<ul>\n" + t.map({ v in
                    let s: String = "\(v)"
                    /*
                    if let t = v as? String {
                        do {
                            s = try self.render(text: t, filename: "", forAppearance: .light, baseDir: "")
                        } catch {
                            s = t
                        }
                    } else {
                        s = "\(v)"
                    }*/
                    return "<li>\(s)</li>"
                }).joined(separator: "\n")
            } else if let t = element.value as? String {
                s += t
                /*
                do {
                    s += try self.render(text: t, filename: "", forAppearance: .light, baseDir: "")
                } catch {
                    s += t.replacingOccurrences(of: "|", with: #"\|"#)
                }
                */
            } else {
                s += "\(element.value)"
            }
            s += "</td></tr>\n"
        }
        s += "</table>"
        return s
    }
    
}
*/
