//
//  AboutViewController.swift
//  TextDown
//
//  Created by adlerflow on 31/12/20.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var versionField: NSTextField!
    @IBOutlet weak var copyrightField: NSTextField!
    @IBOutlet weak var infoTextView: NSTextView!
    
    override func viewDidLoad() {
        imageView.image = NSApplication.shared.applicationIconImage
        if let info = Bundle.main.infoDictionary {
            let version = info["CFBundleShortVersionString"] as? String ?? ""
            let build = info["CFBundleVersion"] as? String ?? ""
                
            titleField.stringValue = info["CFBundleExecutable"] as? String ?? "TextDown"
            versionField.stringValue = "Version \(version) (\(build))"
            copyrightField.stringValue = info["NSHumanReadableCopyright"] as? String ?? ""
        } else {
            versionField.stringValue = ""
            copyrightField.stringValue = ""
        }
        
        let fg_color = NSColor.textColor.css() ?? "#000000"
        let bg_color = NSColor.textBackgroundColor.css() ?? "#ffffff"
        var s = "<div style='font-family: -apple-system; text-align: center; color: \(fg_color); background-color: \(bg_color)'>"
        
        s += "<b>Developer</b><br /><a href='https://github.com'></a><br /><a href='https://github.com'>https://github.com</a><br /><br />"
        
        s += "<b>Libraries</b><br />"
        s += cmarkVersionHTML() + "\n"
        // highlight.js (client-side, loaded via CDN - version shown in browser console)<br />

        s += "PCRE2 (<a href=\"https://github.com/PhilipHazel/pcre2\">https://github.com/PhilipHazel/pcre2</a>)<br />\n"
        s += "JPCRE2 (<a href=\"https://github.com/jpcre2/jpcre2\">https://github.com/jpcre2/jpcre2</a>)<br />\n"
        s += "Yams (<a href=\"https://github.com/jpsim/Yams.git\">https://github.com/jpsim/Yams.git</a>)<br />\n"
        s += "SwiftSoup (<a href=\"https://github.com/scinfu/SwiftSoup\">https://github.com/scinfu/SwiftSoup</a>)<br />\n"
        s += "<br />\n———<br />\n<br />\n"
        s += "</div>"
       
        if let data = s.data(using: .utf8), let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            infoTextView.textStorage?.setAttributedString(attributedString)
        }
    }
}

class AboutWindowController: NSWindowController {
    @IBAction func cancel(_ sender: Any?) {
        self.close()
    }
}

extension AboutViewController {
    /// Returns HTML describing the cmark-gfm version, or a fallback if the symbols are unavailable.
    fileprivate func cmarkVersionHTML() -> String {
        // If you link cmark-gfm and expose these C functions to Swift, you can switch to direct calls again.
        // Until then, provide a graceful fallback so the app compiles and the About page still renders.
        #if canImport(cmark)
        // If a Swift module named 'cmark' exists and re-exports the symbols, try to use it.
        // Note: Adjust names if your module exposes different API.
        if let versionCString = cmark_version_string?() {
            let versionString = String(cString: versionCString)
            let versionNumber = (cmark_version?() ?? 0)
            return "cmark-gfm version \(versionString) (\(versionNumber)) (<a href=\"https://github.com/github/cmark-gfm\">https://github.com/github/cmark-gfm</a>)<br />"
        }
        #endif
        // Fallback when the symbols aren't available in this build configuration.
        return "cmark-gfm (version unknown) (<a href=\"https://github.com/github/cmark-gfm\">https://github.com/github/cmark-gfm</a>)<br />"
    }
}
