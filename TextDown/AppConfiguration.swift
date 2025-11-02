//
//  AppConfiguration.swift
//  TextDown
//
//  Created by adlerflow on 13/12/20.
//

import Foundation
import OSLog
import Observation

enum Appearance: Int {
    case undefined
    case light
    case dark
}

enum BackgroundColor: Int {
    case fromMarkdown = 0
    case fromScheme = 1
    case custom = 2
}

extension NSNotification.Name {
    public static let TextDownSettingsUpdated: NSNotification.Name = NSNotification.Name("org.advison.textdown-settings-changed")
}

@Observable
class AppConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case autoLinkExtension
        case checkboxExtension
        case emojiExtension
        case emojiImageOption
        case headsExtension
        case highlightExtension
        case inlineImageExtension
        case mathExtension
        case mentionExtension
        case subExtension
        case supExtension
        case strikethroughExtension
        case strikethroughDoubleTildeOption
        case syntaxHighlightExtension
        case syntaxWordWrapOption
        case syntaxLineNumbersOption
        case syntaxTabsOption
        case syntaxThemeLightOption
        case syntaxThemeDarkOption

        case tableExtension
        case tagFilterExtension
        case taskListExtension
        case yamlExtension
        case yamlExtensionAll
        
        case footnotesOption
        case hardBreakOption
        case noSoftBreakOption
        case unsafeHTMLOption
        case smartQuotesOption
        case validateUTFOption
        
        case customCSS
        case customCSSCode
        case customCSSCodeFetched
        case customCSSOverride
        case openInlineLink
        
        case renderAsCode
        
        case useLegacyPreview
        
        case qlWindowWidth
        case qlWindowHeight
        
        case about
        case debug
    }

    static let shared = {
        return AppConfiguration.settingsFromSharedFile() ?? AppConfiguration()
    }()
    static let factorySettings = AppConfiguration(noInitFromDefault: true)
    static var appBundleUrl: URL?
    
    static var isLightAppearance: Bool {
        get {
            return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light" == "Light"
        }
    }
    
    var autoLinkExtension: Bool = true
    var checkboxExtension: Bool = false
    var emojiExtension: Bool = true
    var emojiImageOption: Bool = false
    var headsExtension: Bool = true
    var highlightExtension: Bool = false
    var inlineImageExtension: Bool = true
    var mathExtension: Bool = true
    var mentionExtension: Bool = false

    var strikethroughExtension: Bool = true
    var strikethroughDoubleTildeOption: Bool = false

    var subExtension: Bool = false
    var supExtension: Bool = false

    var syntaxHighlightExtension: Bool = true
    var syntaxWordWrapOption: Int = 0
    var syntaxLineNumbersOption: Bool = false
    var syntaxTabsOption: Int = 4
    var syntaxThemeLightOption: String = "github"
    var syntaxThemeDarkOption: String = "github-dark"
    // syntaxFontFamily, syntaxFontSize, guessEngine removed - were for server-side highlighting

    var tableExtension: Bool = true
    var tagFilterExtension: Bool = true
    var taskListExtension: Bool = true
    var yamlExtension: Bool = true
    var yamlExtensionAll: Bool = false

    var footnotesOption: Bool = true
    var hardBreakOption: Bool = false
    var noSoftBreakOption: Bool = false
    var unsafeHTMLOption: Bool = false
    var smartQuotesOption: Bool = true
    var validateUTFOption: Bool = false

    var customCSS: URL?
    var customCSSFetched: Bool = false
    var customCSSCode: String?
    var customCSSOverride: Bool = false

    var openInlineLink: Bool = false

    var renderAsCode: Bool = false
    
    var renderStats: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ql-markdown-render-count");
        }
        set {
            // print("Rendered \(newValue) files.")
            UserDefaults.standard.setValue(newValue, forKey: "ql-markdown-render-count")
            UserDefaults.standard.synchronize();
        }
    }
    
    var useLegacyPreview: Bool = false
    
    /// Quick Look window width.
    var qlWindowWidth: Int? = nil
    /// Quick Look window height.
    var qlWindowHeight: Int? = nil
    /// Quick Look window size.
    var qlWindowSize: CGSize {
        if let w = qlWindowWidth, w > 0, let h = qlWindowHeight, h > 0 {
            return CGSize(width: CGFloat(w), height: CGFloat(h))
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    var debug: Bool = false
    var about: Bool = false
    
    var app_version: String {
        var title: String = "<a href='https://github.com/'>";
        if let info = Bundle.main.infoDictionary {
            title += (info["CFBundleExecutable"] as? String ?? "TextDown") + "</a>"
            if let version = info["CFBundleShortVersionString"] as? String,
                let build = info["CFBundleVersion"] as? String {
                title += ", version \(version) (\(build))"
            }
            if let copy = info["NSHumanReadableCopyright"] as? String {
                title += ".<br />\n\(copy.trimmingCharacters(in: CharacterSet(charactersIn: ". ")) + " with <span style='font-style: normal'>❤️</span>")"
            }
        } else {
            title += "TextDown</a>"
        }
        return title
    }
    
    var app_version2: String {
        var title: String = "<!--\n\nFile generated with TextDown - ";
        if let info = Bundle.main.infoDictionary {
            title += (info["CFBundleExecutable"] as? String ?? "TextDown")
            if let version = info["CFBundleShortVersionString"] as? String,
                let build = info["CFBundleVersion"] as? String {
                title += ", version \(version) (\(build))"
            }
            if let copy = info["NSHumanReadableCopyright"] as? String {
                title += ".\n\(copy.trimmingCharacters(in: CharacterSet(charactersIn: ". ")) + " with ❤️")"
            }
        }
        title += "\n\n-->\n"
        return title
    }
    
    var resourceBundle: Bundle {
        return Self.getResourceBundle()
    }
    
    private init(noInitFromDefault: Bool = false) {
        if !noInitFromDefault {
            self.initFromDefaults()
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.autoLinkExtension = try container.decode(Bool.self, forKey:.autoLinkExtension)
        self.checkboxExtension = try container.decode(Bool.self, forKey:.checkboxExtension)
        self.emojiExtension = try container.decode(Bool.self, forKey:.emojiExtension)
        self.emojiImageOption = try container.decode(Bool.self, forKey:.emojiImageOption)
        self.headsExtension = try container.decode(Bool.self, forKey:.headsExtension)
        self.highlightExtension = try container.decode(Bool.self, forKey: .highlightExtension)
        self.inlineImageExtension = try container.decode(Bool.self, forKey:.inlineImageExtension)
        
        self.mathExtension = try container.decode(Bool.self, forKey: .mathExtension)
        self.mentionExtension = try container.decode(Bool.self, forKey:.mentionExtension)
        self.strikethroughExtension = try container.decode(Bool.self, forKey:.strikethroughExtension)
        self.strikethroughDoubleTildeOption = try container.decode(Bool.self, forKey:.strikethroughDoubleTildeOption)
        self.subExtension = try container.decode(Bool.self, forKey:.subExtension)
        self.supExtension = try container.decode(Bool.self, forKey:.supExtension)
        self.syntaxHighlightExtension = try container.decode(Bool.self, forKey: .syntaxHighlightExtension)
        self.syntaxWordWrapOption = try container.decode(Int.self, forKey: .syntaxWordWrapOption)
        self.syntaxLineNumbersOption = try container.decode(Bool.self, forKey: .syntaxLineNumbersOption)
        self.syntaxTabsOption = try container.decode(Int.self, forKey: .syntaxTabsOption)
        self.syntaxThemeLightOption = try container.decode(String.self, forKey: .syntaxThemeLightOption)
        self.syntaxThemeDarkOption = try container.decode(String.self, forKey: .syntaxThemeDarkOption)

        self.tableExtension = try container.decode(Bool.self, forKey: .tableExtension)
        self.tagFilterExtension = try container.decode(Bool.self, forKey: .tagFilterExtension)
        self.taskListExtension = try container.decode(Bool.self, forKey: .taskListExtension)
        self.yamlExtension = try container.decode(Bool.self, forKey: .yamlExtension)
        self.yamlExtensionAll = try container.decode(Bool.self, forKey: .yamlExtensionAll)
    
        self.footnotesOption = try container.decode(Bool.self, forKey: .footnotesOption)
        self.hardBreakOption = try container.decode(Bool.self, forKey: .hardBreakOption)
        self.noSoftBreakOption = try container.decode(Bool.self, forKey: .noSoftBreakOption)
        self.unsafeHTMLOption = try container.decode(Bool.self, forKey: .unsafeHTMLOption)
        self.smartQuotesOption = try container.decode(Bool.self, forKey: .smartQuotesOption)
        self.validateUTFOption = try container.decode(Bool.self, forKey: .validateUTFOption)
    
        self.customCSS = try container.decode(URL?.self, forKey: .customCSS)
        self.customCSSFetched = try container.decode(Bool.self, forKey: .customCSSCodeFetched)
        self.customCSSCode = try container.decode(String?.self, forKey: .customCSSCode)
        self.customCSSOverride = try container.decode(Bool.self, forKey: .customCSSOverride)
        self.openInlineLink = try container.decode(Bool.self, forKey: .openInlineLink)
    
        self.renderAsCode = try container.decode(Bool.self, forKey: .renderAsCode)
    
        self.useLegacyPreview = try container.decode(Bool.self, forKey: .useLegacyPreview)
    
        self.qlWindowWidth = try container.decode(Int?.self, forKey: .qlWindowWidth)
        self.qlWindowHeight = try container.decode(Int?.self, forKey: .qlWindowHeight)
    
        self.debug = try container.decode(Bool.self, forKey: .debug)
        self.about = try container.decode(Bool.self, forKey: .about)
    }
    
    init() {
        
    }
    
    init(defaults defaultsDomain: [String: Any]) {
        self.update(from: defaultsDomain)
    }

    deinit {
        stopMonitorChange()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.autoLinkExtension, forKey: .autoLinkExtension)
        try container.encode(self.checkboxExtension, forKey: .checkboxExtension)
        try container.encode(self.emojiExtension, forKey: .emojiExtension)
        try container.encode(self.emojiImageOption, forKey: .emojiImageOption)
        try container.encode(self.headsExtension, forKey: .headsExtension)
        try container.encode(self.highlightExtension, forKey: .highlightExtension)
        try container.encode(self.inlineImageExtension, forKey: .inlineImageExtension)
        try container.encode(self.mathExtension, forKey: .mathExtension)
        try container.encode(self.mentionExtension, forKey: .mentionExtension)
        try container.encode(self.strikethroughExtension, forKey: .strikethroughExtension)
        try container.encode(self.strikethroughDoubleTildeOption, forKey: .strikethroughDoubleTildeOption)
        try container.encode(self.syntaxHighlightExtension, forKey: .syntaxHighlightExtension)
        try container.encode(self.syntaxWordWrapOption, forKey: .syntaxWordWrapOption)
        try container.encode(self.syntaxLineNumbersOption, forKey: .syntaxLineNumbersOption)
        try container.encode(self.syntaxTabsOption, forKey: .syntaxTabsOption)
        try container.encode(self.syntaxThemeLightOption, forKey: .syntaxThemeLightOption)
        try container.encode(self.syntaxThemeDarkOption, forKey: .syntaxThemeDarkOption)
        try container.encode(self.subExtension, forKey: .subExtension)
        try container.encode(self.supExtension, forKey: .supExtension)

        try container.encode(self.tableExtension, forKey: .tableExtension)
        try container.encode(self.tagFilterExtension, forKey: .tagFilterExtension)
        try container.encode(self.taskListExtension, forKey: .taskListExtension)
        try container.encode(self.yamlExtension, forKey: .yamlExtension)
        try container.encode(self.yamlExtensionAll, forKey: .yamlExtensionAll)
    
        try container.encode(self.footnotesOption, forKey: .footnotesOption)
        try container.encode(self.hardBreakOption, forKey: .hardBreakOption)
        try container.encode(self.noSoftBreakOption, forKey: .noSoftBreakOption)
        try container.encode(self.unsafeHTMLOption, forKey: .unsafeHTMLOption)
        try container.encode(self.smartQuotesOption, forKey: .smartQuotesOption)
        try container.encode(self.validateUTFOption, forKey: .validateUTFOption)
    
        try container.encode(self.customCSS, forKey: .customCSS)
        try container.encode(self.customCSSCode, forKey: .customCSSCode)
        try container.encode(self.customCSSFetched, forKey: .customCSSCodeFetched)
        try container.encode(self.customCSSOverride, forKey: .customCSSOverride)
        try container.encode(self.openInlineLink, forKey: .openInlineLink)
        try container.encode(self.renderAsCode, forKey: .renderAsCode)
        
        try container.encode(self.useLegacyPreview, forKey: .useLegacyPreview)
        try container.encode(self.qlWindowWidth, forKey: .qlWindowWidth)
        try container.encode(self.qlWindowHeight, forKey: .qlWindowHeight)
        try container.encode(self.about, forKey: .about)
        try container.encode(self.debug, forKey: .debug)
    }
    
    var isMonitoring = false
    func startMonitorChange() {
        guard !isMonitoring else {
            return
        }
        isMonitoring = true
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.handleSettingsChanged(_:)), name: .TextDownSettingsUpdated, object: nil)
    }
    
    func stopMonitorChange() {
        if isMonitoring {
            DistributedNotificationCenter.default().removeObserver(self)
        }
    }
    
    @objc func handleSettingsChanged(_ notification: NSNotification) {
        // print("settings changed")
        self.initFromDefaults()
    }
    
    func initFromDefaults() {
        let s = AppConfiguration.settingsFromSharedFile() ?? AppConfiguration()
        update(from: s)
    }

    func update(from s: AppConfiguration) {
        self.autoLinkExtension = s.autoLinkExtension
        self.checkboxExtension = s.checkboxExtension
        
        self.emojiExtension = s.emojiExtension
        self.emojiImageOption = s.emojiImageOption
        
        self.headsExtension = s.headsExtension
        self.highlightExtension = s.highlightExtension
        self.inlineImageExtension = s.inlineImageExtension
        
        self.mathExtension = s.mathExtension
        self.mentionExtension = s.mentionExtension
        
        self.strikethroughExtension = s.strikethroughExtension
        self.strikethroughDoubleTildeOption = s.strikethroughDoubleTildeOption
        
        self.syntaxHighlightExtension = s.syntaxHighlightExtension
        self.syntaxWordWrapOption = s.syntaxWordWrapOption
        self.syntaxLineNumbersOption = s.syntaxLineNumbersOption
        self.syntaxTabsOption = s.syntaxTabsOption
        self.syntaxThemeLightOption = s.syntaxThemeLightOption
        self.syntaxThemeDarkOption = s.syntaxThemeDarkOption
        self.subExtension = s.subExtension
        self.supExtension = s.supExtension

        self.tableExtension = s.tableExtension
        self.tagFilterExtension = s.tagFilterExtension
        self.taskListExtension = s.taskListExtension
        self.yamlExtension = s.yamlExtension
        self.yamlExtensionAll = s.yamlExtensionAll
    
        self.footnotesOption = s.footnotesOption
        self.hardBreakOption = s.hardBreakOption
        self.noSoftBreakOption = s.noSoftBreakOption
        self.unsafeHTMLOption = s.unsafeHTMLOption
        self.smartQuotesOption = s.smartQuotesOption
        self.validateUTFOption = s.validateUTFOption
        
        self.customCSS = s.customCSS
        self.customCSSCode = s.customCSSCode
        self.customCSSOverride = s.customCSSOverride

        self.openInlineLink = s.openInlineLink

        self.about = s.about
        self.debug = s.debug
        
        self.renderAsCode = s.renderAsCode
        
        self.qlWindowWidth = s.qlWindowWidth
        self.qlWindowHeight = s.qlWindowHeight
        
        self.useLegacyPreview = false
    }
    
    func update(from defaultsDomain: [String: Any]) {
        if let ext = defaultsDomain["table"] as? Bool {
            tableExtension = ext
        }
        if let ext = defaultsDomain["autolink"] as? Bool {
            autoLinkExtension = ext
        }
        if let ext = defaultsDomain["tagfilter"] as? Bool {
            tagFilterExtension = ext
        }
        if let ext = defaultsDomain["tasklist"] as? Bool {
            taskListExtension = ext
        }
        if let ext = defaultsDomain["yaml"] as? Bool {
            yamlExtension = ext
        } else if let ext = defaultsDomain["rmd"] as? Bool {
            yamlExtension = ext
        }
        if let ext = defaultsDomain["yaml_all"] as? Bool {
            yamlExtensionAll = ext
        } else if let ext = defaultsDomain["rmd_all"] as? Bool {
            yamlExtensionAll = ext
        }
        
        if let ext = defaultsDomain["strikethrough"] as? Bool {
            strikethroughExtension = ext
        }
        if let ext = defaultsDomain["strikethrough_doubletilde"] as? Bool {
            strikethroughDoubleTildeOption = ext
        }
        
        
        if let ext = defaultsDomain["math"] as? Bool {
            mathExtension = ext
        }
        if let ext = defaultsDomain["mention"] as? Bool {
            mentionExtension = ext
        }
        if let ext = defaultsDomain["checkbox"] as? Bool {
            checkboxExtension = ext
        }
        if let ext = defaultsDomain["heads"] as? Bool {
            headsExtension = ext
        }
        
        if let ext = defaultsDomain["highlight"] as? Bool {
            highlightExtension = ext
        }
        
        if let ext = defaultsDomain["syntax"] as? Bool {
            syntaxHighlightExtension = ext
        }
        
        if let characters = defaultsDomain["syntax_word_wrap"] as? Int {
            syntaxWordWrapOption = characters
        }
        if let state = defaultsDomain["syntax_line_numbers"] as? Bool {
            syntaxLineNumbersOption = state
        }
        if let n = defaultsDomain["syntax_tabs"] as? Int {
            syntaxTabsOption = n
        }
        if let theme = defaultsDomain["syntax_theme_light"] as? String {
            syntaxThemeLightOption = theme
        }
        if let theme = defaultsDomain["syntax_theme_dark"] as? String {
            syntaxThemeDarkOption = theme
        }

        if let ext = defaultsDomain["sub"] as? Bool {
            subExtension = ext
        }
        if let ext = defaultsDomain["sup"] as? Bool {
            supExtension = ext
        }
        
        if let ext = defaultsDomain["emoji"] as? Bool {
            emojiExtension = ext
        }
        
        if let ext = defaultsDomain["inlineimage"] as? Bool {
            inlineImageExtension = ext
        }
        
        if let opt = defaultsDomain["emoji_image"] as? Bool {
            emojiImageOption = opt
        }
        
        if let opt = defaultsDomain["hardbreak"] as? Bool {
            hardBreakOption = opt
        }
        if let opt = defaultsDomain["nosoftbreak"] as? Bool {
            noSoftBreakOption = opt
        }
        if let opt = defaultsDomain["unsafeHTML"] as? Bool {
            unsafeHTMLOption = opt
        }
        if let opt = defaultsDomain["validateUTF"] as? Bool {
            validateUTFOption = opt
        }
        if let opt = defaultsDomain["smartquote"] as? Bool {
            smartQuotesOption = opt
        }
        if let opt = defaultsDomain["footnote"] as? Bool {
            footnotesOption = opt
        }
        
        if let opt = defaultsDomain["customCSS"] as? String, !opt.isEmpty {
            if !opt.hasPrefix("/"), let path = AppConfiguration.getStylesFolder() {
                customCSS = path.appendingPathComponent(opt)
            } else {
                customCSS = URL(fileURLWithPath: opt)
            }
        }
        if let opt = defaultsDomain["customCSS-override"] as? Bool {
            customCSSOverride = opt
        }

        if let opt = defaultsDomain["about"] as? Bool {
            about = opt
        }
        
        if let opt = defaultsDomain["debug"] as? Bool {
            debug = opt
        }
        
        if let opt = defaultsDomain["inline-link"] as? Bool {
            openInlineLink = opt
        }
        if let opt = defaultsDomain["render-as-code"] as? Bool {
            renderAsCode = opt
        }
        if let opt = defaultsDomain["ql-window-width"] as? Int, opt > 0 {
            qlWindowWidth = opt
        } else {
            qlWindowWidth = nil
        }
        if let opt = defaultsDomain["ql-window-height"] as? Int, opt > 0 {
            qlWindowHeight = opt
        } else {
            qlWindowHeight = nil
        }
        
        if let opt = defaultsDomain["legacy-preview"] as? Bool {
            useLegacyPreview = opt
        }

        sanitizeEmojiOption()
    }
    
    func resetToFactory() {
        let s = AppConfiguration()
        update(from: s)
    }

    static func settingsFromSharedFile() -> AppConfiguration? {
        guard let settingsURL = Self.settingsFileURL else {
            os_log(.error, log: .settings, "Unable to locate settings file URL")
            return nil
        }

        // Create directory if doesn't exist
        if let directory = Self.applicationSupportUrl {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: settingsURL.path) else {
            os_log(.info, log: .settings, "Settings file does not exist, using defaults")
            return nil
        }

        do {
            let data = try Data(contentsOf: settingsURL)
            let settings = try JSONDecoder().decode(AppConfiguration.self, from: data)
            os_log(.info, log: .settings, "Settings loaded from %{public}@", settingsURL.path)
            return settings
        } catch {
            os_log(.error, log: .settings, "Failed to load settings: %{public}@", error.localizedDescription)
            return nil
        }
    }

    @discardableResult
    func saveToSharedFile() -> (Bool, String?) {
        guard let settingsURL = Self.settingsFileURL else {
            let msg = "Unable to locate settings folder"
            os_log(.error, log: .settings, "%{public}@", msg)
            return (false, msg)
        }

        // Create directory if doesn't exist
        if let directory = Self.applicationSupportUrl {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                let msg = "Failed to create settings directory: \(error.localizedDescription)"
                os_log(.error, log: .settings, "%{public}@", msg)
                return (false, msg)
            }
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(self)
            try data.write(to: settingsURL, options: .atomic)

            os_log(.info, log: .settings, "Settings saved to %{public}@", settingsURL.path)

            // Notify other app instances (multi-window sync)
            DistributedNotificationCenter.default().postNotificationName(
                .TextDownSettingsUpdated,
                object: nil,
                userInfo: nil,
                deliverImmediately: true
            )

            return (true, nil)
        } catch {
            let msg = "Failed to save settings: \(error.localizedDescription)"
            os_log(.error, log: .settings, "%{public}@", msg)
            return (false, msg)
        }
    }
    
    private func sanitizeEmojiOption() {
        if emojiExtension && emojiImageOption {
            unsafeHTMLOption = true
        }
    }
    
    /// Get the Bundle with the resources.
    /// For the host app return the main Bundle. For the appex return the bundle of the hosting app.
    static func getResourceBundle() -> Bundle {
        if let url = AppConfiguration.appBundleUrl, let appBundle = Bundle(url: url) {
            return appBundle
        } else if Bundle.main.bundlePath.hasSuffix(".appex") {
            // this is an app extension
            let url = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()

            if let appBundle = Bundle(url: url) {
                return appBundle
            } else if let appBundle = Bundle(identifier: "org.advison.TextDown") {
                return appBundle
            }
        }
        return Bundle.main
    }
    
    // getHighlightSupportPath() removed - highlight resources no longer used

    func getBundleContents(forResource: String, ofType: String) -> String? {
        if let p = self.resourceBundle.path(forResource: forResource, ofType: ofType), let data = FileManager.default.contents(atPath: p), let s = String(data: data, encoding: .utf8) {
            return s
        } else {
            return nil
        }
    }
}
