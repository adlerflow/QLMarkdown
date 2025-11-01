//
//  DocumentViewController.swift
//  TextDown
//
//  Created by adlerflow on 09/12/20.
//

import Cocoa
@preconcurrency import WebKit
import OSLog
import UniformTypeIdentifiers

class DocumentViewController: NSViewController {

    // MARK: - Document

    /// The markdown document being edited
    var document: MarkdownDocument? {
        return representedObject as? MarkdownDocument
    }

    /// Load content from a markdown document
    /// - Parameter document: The document to load
    func loadDocument(_ document: MarkdownDocument) {
        textView.string = document.markdownContent
        updatePreview()
    }

    // MARK: - Properties

    @objc dynamic var elapsedTimeLabel: String = ""
    
    @objc dynamic var headsExtension: Bool = Settings.factorySettings.headsExtension {
        didSet {
            guard oldValue != headsExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var tableExtension: Bool = Settings.factorySettings.tableExtension {
        didSet {
            guard oldValue != tableExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var autoLinkExtension: Bool = Settings.factorySettings.autoLinkExtension {
        didSet {
            guard oldValue != autoLinkExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var tagFilterExtension: Bool = Settings.factorySettings.tagFilterExtension {
        didSet {
            guard oldValue != tagFilterExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var taskListExtension: Bool = Settings.factorySettings.taskListExtension {
        didSet {
            guard oldValue != taskListExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var yamlExtension: Bool = Settings.factorySettings.yamlExtension {
        didSet {
            guard oldValue != yamlExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var yamlExtensionAll: Bool = Settings.factorySettings.yamlExtensionAll {
        didSet {
            guard oldValue != yamlExtensionAll else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var strikethroughExtension: Bool = Settings.factorySettings.strikethroughExtension {
        didSet {
            guard oldValue != strikethroughExtension else { return }
            isDirty = true
        }
    }
    dynamic var strikethroughDoubleTildeOption: Bool = Settings.factorySettings.strikethroughDoubleTildeOption {
        didSet {
            guard oldValue != strikethroughDoubleTildeOption else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var mentionExtension: Bool = Settings.factorySettings.mentionExtension {
        didSet {
            guard oldValue != mentionExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var syntaxHighlightExtension: Bool = Settings.factorySettings.syntaxHighlightExtension {
        didSet {
            guard oldValue != syntaxHighlightExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var syntaxLineNumbers: Bool = Settings.factorySettings.syntaxLineNumbersOption {
        didSet {
            guard oldValue != syntaxLineNumbers else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var syntaxWrapEnabled: Bool = Settings.factorySettings.syntaxWordWrapOption > 0 {
        didSet {
            guard oldValue != syntaxWrapEnabled else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var syntaxWrapCharacters: Int = Settings.factorySettings.syntaxWordWrapOption > 0 ? Settings.factorySettings.syntaxWordWrapOption : 80 {
        didSet {
            guard oldValue != syntaxWrapCharacters else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var syntaxTabsOption: Int = Settings.factorySettings.syntaxTabsOption {
        didSet {
            guard oldValue != syntaxTabsOption else { return }
            isDirty = true
        }
    }

    @objc dynamic var mathExtension: Bool = Settings.factorySettings.mathExtension {
        didSet {
            guard oldValue != mathExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var highlightExtension: Bool = Settings.factorySettings.highlightExtension {
        didSet {
            guard oldValue != highlightExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var subSuperScriptExtension: Bool = Settings.factorySettings.subExtension {
        didSet {
            guard oldValue != subSuperScriptExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var emojiExtension: Bool = Settings.factorySettings.emojiExtension {
        didSet {
            guard oldValue != emojiExtension else { return }
            isDirty = true
        }
    }
    @objc dynamic var emojiImageOption: Bool = Settings.factorySettings.emojiImageOption {
        didSet {
            guard oldValue != emojiImageOption else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var inlineImageExtension: Bool = Settings.factorySettings.inlineImageExtension {
        didSet {
            guard oldValue != inlineImageExtension else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var hardBreakOption: Bool = Settings.factorySettings.hardBreakOption {
        didSet {
            guard oldValue != hardBreakOption else { return }
            isDirty = true
        }
    }
    @objc dynamic var noSoftBreakOption: Bool = Settings.factorySettings.noSoftBreakOption {
        didSet {
            guard oldValue != noSoftBreakOption else { return }
            isDirty = true
        }
    }
    @objc dynamic var unsafeHTMLOption: Bool = Settings.factorySettings.unsafeHTMLOption {
        didSet {
            guard oldValue != unsafeHTMLOption else { return }
            isDirty = true
        }
    }
    @objc dynamic var validateUTFOption: Bool = Settings.factorySettings.validateUTFOption {
        didSet {
            guard oldValue != validateUTFOption else { return }
            isDirty = true
        }
    }
    @objc dynamic var smartQuotesOption: Bool = Settings.factorySettings.smartQuotesOption {
        didSet {
            guard oldValue != smartQuotesOption else { return }
            isDirty = true
        }
    }
    @objc dynamic var footnotesOption: Bool = Settings.factorySettings.footnotesOption {
        didSet {
            guard oldValue != footnotesOption else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var debugMode: Bool = Settings.factorySettings.debug {
        didSet {
            guard oldValue != debugMode else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var renderAsCode: Bool = Settings.factorySettings.renderAsCode {
        didSet {
            guard oldValue != renderAsCode else { return }
            isDirty = true
        }
    }
    
    @objc dynamic var qlWindowSizeCustomized: Bool = false {
        didSet {
            guard oldValue != qlWindowSizeCustomized else { return }
            isDirty = true
        }
    }
    @objc dynamic var qlWindowWidth: Int = Settings.factorySettings.qlWindowWidth ?? 1000 {
        didSet {
            guard oldValue != qlWindowWidth else { return }
            isDirty = true
        }
    }
    @objc dynamic var qlWindowHeight: Int = Settings.factorySettings.qlWindowHeight ?? 800 {
        didSet {
            guard oldValue != qlWindowHeight else { return }
            isDirty = true
        }
    }

    @objc dynamic var customCSSOverride: Bool = Settings.factorySettings.customCSSOverride {
        didSet {
            guard oldValue != customCSSOverride else { return }
            isDirty = true
        }
    }
    @objc dynamic var customCSSFile: URL? = Settings.factorySettings.customCSS {
        didSet {
            guard oldValue != customCSSFile else { return }
            isDirty = true
        }
    }
    
    internal var pauseAutoSave = 0 {
        didSet {
            if pauseAutoSave == 0 && isDirty && isLoaded && isAutoSaving {
                saveAction(self)
            }
        }
    }
    @objc dynamic var isAutoSaving: Bool {
        get {
            return UserDefaults.standard.value(forKey: "auto-save") as? Bool ?? true
        }
        set {
            guard newValue != isAutoSaving else { return }
            
            self.willChangeValue(forKey: "isAutoSaving")
            UserDefaults.standard.setValue(newValue, forKey: "auto-save")
            self.didChangeValue(forKey: "isAutoSaving")
            
            if newValue && isDirty && pauseAutoSave == 0 {
                saveAction(self)
            }
        }
    }
    
    @objc dynamic var isAboutVisible: Bool = Settings.factorySettings.about {
        didSet {
            guard oldValue != isAboutVisible else { return }
            isDirty = true
        }
    }
    
    var firstView = true

    var autoRefresh: Bool {
        get {
            return UserDefaults.standard.value(forKey: "auto-refresh") as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "auto-refresh")
            if newValue {
                doRefresh(self)
            }
        }
    }
    
    internal var pauseAutoRefresh = 0 {
        didSet {
            guard pauseAutoRefresh == 0 else {
                return
            }
            if isDirty && isLoaded {
                if autoRefresh {
                    self.refresh(self)
                }
                if isAutoSaving {
                    self.saveAction(self)
                }
            }
        }
    }
    internal var isDirty = false {
        didSet {
            self.view.window?.isDocumentEdited = isDirty
            if isDirty && autoRefresh && isLoaded && pauseAutoRefresh == 0 {
                self.refresh(self)
            }
            if isDirty && isAutoSaving && isLoaded && pauseAutoRefresh == 0 {
                self.saveAction(self)
            }
        }
    }
    internal var isLoaded = false

    // MARK: - Editor Core Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textView: NSTextView!

    var allow_reload: Bool = true
    fileprivate var markdown_source: DispatchSourceFileSystemObject?
    internal var prev_scroll: Int = -1
    
    deinit {
        self.markdown_source?.cancel()
    }
    
    @IBAction func doDirty(_ sender: Any) {
        isDirty = true
    }

    @IBAction func openReadme(_ sender: Any) {
        if let file = Bundle.main.url(forResource: "README", withExtension: "md") {
            NSDocumentController.shared.openDocument(
                withContentsOf: file,
                display: true
            ) { _, _, error in
                if let error = error {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }
    
    @IBAction func openDocument(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "md")!]
        panel.message = "Select a Markdown file to open"

        let result = panel.runModal()

        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let src = panel.url else {
            return
        }

        NSDocumentController.shared.openDocument(
            withContentsOf: src,
            display: true
        ) { _, _, error in
            if let error = error {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    @IBAction func exportMarkdown(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.allowedContentTypes = [UTType(filenameExtension: "md")!, UTType(filenameExtension: "rmd")!, UTType(filenameExtension: "qmd")!]
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = self.document?.fileURL?.lastPathComponent ?? "markdown.md"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        
        let result = savePanel.runModal()
        
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let dst = savePanel.url else {
            return
        }
        _ = self.exportCurrentMarkdown(to: dst)
    }
    
    func exportCurrentMarkdown(to dst: URL) -> Bool {
        guard let content = document?.markdownContent else {
            return false
        }

        do {
            try content.write(to: dst, atomically: true, encoding: .utf8)
            return true
        } catch {
            let alert = NSAlert(error: error)
            alert.messageText = "Unable to export the Markdown source!"
            alert.runModal()
            return false
        }
    }
    
    @IBAction func reloadMarkdown(_ sender: Any) {
        guard let file = self.document?.fileURL else {
            return
        }
        let prev_scroll = self.prev_scroll

        // Revert document to saved version
        do {
            try document?.revert(toContentsOf: file, ofType: "public.markdown")
            // Reload content into text view
            textView.string = document?.markdownContent ?? ""
            self.prev_scroll = prev_scroll
            updatePreview()
            if prev_scroll > 0 {
                self.webView.evaluateJavaScript("document.documentElement.scrollTop = \(prev_scroll);")
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.messageText = "Unable to reload the file"
            alert.runModal()
        }
    }
    
    func startMonitorFile() {
        self.markdown_source?.cancel()
        self.markdown_source = nil
        self.allow_reload = true
        
        guard let file = document?.fileURL else {
            return
        }
        
        let fileDescriptor = open(FileManager.default.fileSystemRepresentation(withPath: file.path), O_EVTONLY)
        guard fileDescriptor >= 0 else {
            return
        }
        
        self.markdown_source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .all, queue: DispatchQueue.main)
        self.markdown_source!.setEventHandler { [weak self] in
            guard let me = self else {
                return
            }
            if me.document?.isDocumentEdited == true {
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = "The source markdown has been changed outside the app, do you want to reload it?"
                alert.informativeText = "Changes made to the file will be lost. "
                alert.addButton(withTitle: "Reload")
                alert.addButton(withTitle: "Cancel").keyEquivalent = "\u{1b}"
                if alert.runModal() == .alertFirstButtonReturn {
                    me.reloadMarkdown(me)
                } else {
                    me.allow_reload = false
                    me.markdown_source?.cancel()
                }
            } else {
                self?.reloadMarkdown(me)
            }
        }
        self.markdown_source!.setCancelHandler {
            close(fileDescriptor)
        }
        self.markdown_source!.resume()
    }
    
    @IBAction func exportPreview(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.allowedContentTypes = [.html]
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = "markdown.html"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))

        let result = savePanel.runModal()

        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue, let dst = savePanel.url else {
            return
        }

        let body: String
        let settings = self.updateSettings()
        let appearance: Appearance = Settings.isLightAppearance ? .light : .dark
        do {
            body = try settings.render(text: self.textView.string, filename: document?.fileURL?.lastPathComponent ?? "", forAppearance: appearance, baseDir: document?.fileURL?.deletingLastPathComponent().path ?? "")
        } catch {
            body = "Error"
        }

        let html = settings.getCompleteHTML(title: document?.fileURL?.lastPathComponent ?? "markdown", body: body, basedir: Bundle.main.resourceURL ?? Bundle.main.bundleURL.deletingLastPathComponent(), forAppearance: appearance)
        do {
            try html.write(to: dst, atomically: true, encoding: .utf8)
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Unable to export the HTML preview!"
            alert.addButton(withTitle: "Close").keyEquivalent = "\u{1b}"
            alert.runModal()
        }
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        saveAction(sender)
    }
    
    @IBAction func revertDocumentToSaved(_ sender: Any) {
        let settings = Settings.shared
        settings.initFromDefaults()
        self.initFromSettings(settings)
    }
    
    @IBAction func resetToFactory(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Are you sure to reset all settings to factory default?"
        alert.addButton(withTitle: "Yes").keyEquivalent = "\r"
        alert.addButton(withTitle: "No").keyEquivalent = "\u{1b}"
        let r = alert.runModal()
        if r == .alertFirstButtonReturn {
            let settings = Settings.shared
            settings.resetToFactory()
            settings.saveToSharedFile()
            self.initFromSettings(settings)
        }
    }
    
    @IBAction func checkForUpdates(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.checkForUpdates(sender)
    }

    @IBAction func saveAction(_ sender: Any) {
        let settings = self.updateSettings()
        
        let r = settings.saveToSharedFile()
        if r.0 {
            isDirty = false
        } else {
            print("Error saving settings: \(r.1 ?? "")")
            os_log(
                "Error saving settings: %{public}@",
                log: OSLog.quickLookExtension,
                type: .error,
                r.1 ?? ""
            )
            
            let panel = NSAlert()
            panel.messageText = "Error saving the settings!"
            panel.informativeText = r.1 ?? ""
            panel.alertStyle = .warning
            panel.addButton(withTitle: "Close").keyEquivalent = "\u{1b}"
            panel.runModal()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.doRefresh(sender)
    }

    /// Update the preview without a sender (for programmatic calls)
    @objc func updatePreview() {
        self.doRefresh(self)
    }

    @IBAction func doRefresh(_ sender: Any)  {
        let body: String
        let settings = self.updateSettings()
        let appearance: Appearance = Settings.isLightAppearance ? .light : .dark

        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            body = try settings.render(text: self.textView.string, filename: self.document?.fileURL?.lastPathComponent ?? "", forAppearance: appearance, baseDir: document?.fileURL?.deletingLastPathComponent().path ?? "")
        } catch {
            body = "Error"
        }
        
        let header = """
<script type="text/javascript">
// Reference: http://www.html5rocks.com/en/tutorials/speed/animations/

let last_known_scroll_position = 0;
let ticking = false;
let handler = 0;

function doSomething(scroll_pos) {
    // Do something with the scroll position
    handler = 0;

    window.webkit.messageHandlers.scrollHandler.postMessage({scroll: document.documentElement.scrollTop});

}

document.addEventListener('scroll', function(e) {
  last_known_scroll_position = window.scrollY;

  if (!ticking) {
    if (handler) {
        window.cancelAnimationFrame(handler);
    }
    handler = window.requestAnimationFrame(function() {
      doSomething(last_known_scroll_position);
      ticking = false;
    });

    ticking = true;
  }
});
</script>
"""
        
        let html = settings.getCompleteHTML(title: ".md", body: body, header: header, footer: "", basedir: self.document?.fileURL?.deletingLastPathComponent() ?? Bundle.main.resourceURL ?? Bundle.main.bundleURL.deletingLastPathComponent(), forAppearance: appearance)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        // Use loadHTMLString with document directory as baseURL
        // This allows inline images from the document directory to load
        webView.loadHTMLString(html, baseURL: document?.fileURL?.deletingLastPathComponent())

        elapsedTimeLabel = String(format: "Rendered in %.3f seconds", timeElapsed)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "HighlightSegue" {
            if let vc = segue.destinationController as? HighlightViewController {
                vc.settingsViewController = self
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // highlight initialization removed - using client-side highlight.js instead

        self.textView.isAutomaticQuoteSubstitutionEnabled = false // Settings this option on interfacebuilder is ignored.
        self.textView.isAutomaticTextReplacementEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false
        self.textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        self.textView.delegate = self // Enable auto-refresh on text change

        self.webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "scrollHandler")

        let settings = Settings.shared

        self.initFromSettings(settings)

        DispatchQueue.main.async {
            self.textView.setSelectedRange(NSRange(location: 0, length: 0))
        }

        isLoaded = true

        doRefresh(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        guard firstView else {
            return
        }
        firstView = true;
        
        guard !UserDefaults.standard.bool(forKey: "textdown-suppress-editor-warning") else {
            return
        }
        
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.showsSuppressionButton = true
        alert.messageText = "TextDown Preferences"
        alert.informativeText = "This application is not intended to be a Markdown editor, but the interface for customising the Quick Look preview."
        alert.suppressionButton?.title = "Do not show this warning again"
        
        alert.addButton(withTitle: "OK").keyEquivalent = "\r"
        alert.runModal()
        
        if let suppressionButton = alert.suppressionButton, suppressionButton.state == .on {
            UserDefaults.standard.set(true, forKey: "textdown-suppress-editor-warning")
        }
    }
    
    
    @IBAction func doAutoRefresh(_ sender: NSMenuItem) {
        autoRefresh = !autoRefresh
        sender.state = autoRefresh ? .on : .off
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    internal func getBundleContents(forResource: String, ofType: String) -> String?
    {
        if let p = Bundle.main.path(forResource: forResource, ofType: ofType), let data = FileManager.default.contents(atPath: p), let s = String(data: data, encoding: .utf8) {
            return s
        } else {
            return nil
        }
    }
    
    internal func initFromSettings(_ settings: Settings) {
        pauseAutoRefresh += 1
        pauseAutoSave += 1

        self.debugMode = settings.debug
        self.isAboutVisible = settings.about
        self.renderAsCode = settings.renderAsCode

        self.qlWindowSizeCustomized = settings.qlWindowWidth ?? 0 > 0 && settings.qlWindowHeight ?? 0 > 0
        self.qlWindowWidth = settings.qlWindowWidth ?? 1000
        self.qlWindowHeight = settings.qlWindowHeight ?? 800

        self.tableExtension = settings.tableExtension
        self.autoLinkExtension = settings.autoLinkExtension
        self.tagFilterExtension = settings.tagFilterExtension
        self.taskListExtension = settings.taskListExtension

        self.yamlExtension = settings.yamlExtension
        self.yamlExtensionAll = settings.yamlExtensionAll

        self.strikethroughExtension = settings.strikethroughExtension
        self.strikethroughDoubleTildeOption = settings.strikethroughDoubleTildeOption

        self.mathExtension = settings.mathExtension
        self.mentionExtension = settings.mentionExtension
        self.syntaxHighlightExtension = settings.syntaxHighlightExtension

        self.emojiExtension = settings.emojiExtension
        self.emojiImageOption = settings.emojiImageOption

        self.headsExtension = settings.headsExtension
        self.highlightExtension = settings.highlightExtension
        self.inlineImageExtension = settings.inlineImageExtension
        self.subSuperScriptExtension = settings.supExtension

        self.hardBreakOption = settings.hardBreakOption
        self.noSoftBreakOption = settings.noSoftBreakOption
        self.unsafeHTMLOption = settings.unsafeHTMLOption
        self.validateUTFOption = settings.validateUTFOption
        self.smartQuotesOption = settings.smartQuotesOption
        self.footnotesOption = settings.footnotesOption

        self.customCSSFile = settings.customCSS
        self.customCSSOverride = settings.customCSSOverride

        self.syntaxLineNumbers = settings.syntaxLineNumbersOption
        self.syntaxWrapEnabled = settings.syntaxWordWrapOption > 0
        self.syntaxWrapCharacters = settings.syntaxWordWrapOption > 0 ? settings.syntaxWordWrapOption : 80
        self.syntaxTabsOption = settings.syntaxTabsOption


        self.isAboutVisible = settings.about

        isDirty = false
        pauseAutoRefresh -= 1
        pauseAutoSave -= 1

        doRefresh(self)
    }
    
    internal func updateSettings() -> Settings {
        let settings = Settings.shared
        
        settings.debug = self.debugMode
        settings.renderAsCode = self.renderAsCode
        settings.qlWindowWidth = self.qlWindowSizeCustomized ? self.qlWindowWidth : nil
        settings.qlWindowHeight = self.qlWindowSizeCustomized ? self.qlWindowHeight : nil
        
        settings.tableExtension = self.tableExtension
        settings.autoLinkExtension = self.autoLinkExtension
        settings.tagFilterExtension = self.tagFilterExtension
        settings.taskListExtension = self.taskListExtension
        settings.yamlExtension = self.yamlExtension
        settings.yamlExtensionAll = self.yamlExtensionAll
        
        settings.mathExtension = self.mathExtension
        settings.mentionExtension = self.mentionExtension
        
        settings.emojiExtension = self.emojiExtension
        settings.emojiImageOption = self.emojiImageOption
        
        settings.headsExtension = self.headsExtension
        settings.highlightExtension = self.highlightExtension
        settings.inlineImageExtension = self.inlineImageExtension
        settings.subExtension = self.subSuperScriptExtension
        settings.supExtension = self.subSuperScriptExtension
        
        settings.strikethroughExtension = self.strikethroughExtension
        settings.strikethroughDoubleTildeOption = self.strikethroughDoubleTildeOption
        
        settings.syntaxHighlightExtension = self.syntaxHighlightExtension
        settings.syntaxLineNumbersOption = self.syntaxLineNumbers
        settings.syntaxWordWrapOption = self.syntaxWrapEnabled ? self.syntaxWrapCharacters : 0
        
        settings.syntaxTabsOption = self.syntaxTabsOption

        
        settings.hardBreakOption = self.hardBreakOption
        settings.noSoftBreakOption = self.noSoftBreakOption
        settings.unsafeHTMLOption = self.unsafeHTMLOption
        settings.validateUTFOption = self.validateUTFOption
        settings.smartQuotesOption = self.smartQuotesOption
        settings.footnotesOption = self.footnotesOption
        
        settings.customCSSOverride = self.customCSSOverride
        settings.customCSS = self.customCSSFile
        settings.openInlineLink = Settings.shared.openInlineLink
        settings.about = self.isAboutVisible
        return settings
    }
}

// MARK: - NSMenuItemValidation
extension DocumentViewController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        if menuItem.identifier?.rawValue == "auto refresh" {
            menuItem.state = autoRefresh ? .on : .off
        } else if menuItem.action == #selector(self.saveDocument(_:)) || menuItem.action == #selector(self.saveAction(_:)) {
            return self.isDirty
        } else if menuItem.action == #selector(self.revertDocumentToSaved(_:)) {
            return self.isDirty
        }
        return true
    }
}

// MARK: - WKNavigationDelegate
extension DocumentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if prev_scroll > 0 {
            webView.evaluateJavaScript("document.documentElement.scrollTop = \(prev_scroll);", completionHandler: {_,_ in
                // self.webView.isHidden = false
            })
        } else {
            // self.webView.isHidden = false
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
        // self.webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !Settings.shared.openInlineLink, navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url, url.scheme != "file" {
            let r = NSWorkspace.shared.open(url)
            // print(r, url.absoluteString)
            if r {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler
extension DocumentViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "scrollHandler", let dict = message.body as? [String : AnyObject], let p = dict["scroll"] as? Int {
            self.prev_scroll = p
        }
    }
}

extension DocumentViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if let item = menu.item(withTag: -6) {
            item.title = self.customCSSFile == nil ? "Download default CSS theme" : "Reveal CSS in Finder"
        }
        
        // print("menuNeedsUpdate")
    }
}

// MARK: - DropableTextView
class DropableTextView: NSTextView {
    @IBOutlet weak var container: DocumentViewController?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }
    
    func checkFileDrop(_ sender: NSDraggingInfo) -> Bool {
        guard let board = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String else {
            return false
        }
        let suffix = URL(fileURLWithPath: path).pathExtension.lowercased()
        if suffix == "md" || suffix == "markdown" || suffix == "rmd" || suffix == "qmd" {
            return true
        } else {
            return false
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return checkFileDrop(sender) ? .copy : NSDragOperation()
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return checkFileDrop(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let board = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String else {
            return false
        }

        let url = URL(fileURLWithPath: path)
        NSDocumentController.shared.openDocument(
            withContentsOf: url,
            display: true
        ) { _, _, _ in }
        return true
    }
}

// MARK: - NSTextViewDelegate
extension DocumentViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        guard let sender = notification.object as? NSTextView, sender == textView else {
            return
        }

        // Update document content and mark as modified
        document?.updateContent(textView.string)

        // Update preview if auto-refresh enabled
        if UserDefaults.standard.bool(forKey: "auto-refresh") {
            NSObject.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(updatePreview),
                object: nil
            )
            perform(#selector(updatePreview), with: nil, afterDelay: 0.5)
        }
    }
}
