//
//  PreviewViewController.swift
//  QLExtension
//
//  Created by adlerflow on 16/12/20.
//

import Cocoa
import Quartz
@preconcurrency import WebKit
import OSLog
import external_launcher

class MyWKWebView: WKWebView {
    override var canBecomeKeyView: Bool {
        return false
    }

    override func becomeFirstResponder() -> Bool {
        // Quick Look window do not allow first responder child.
        return false
    }
}

class PreviewViewController: NSViewController, QLPreviewingController {
    var webView: MyWKWebView?

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }
    
    var launcherService: ExternalLauncherProtocol?
    
    override func viewDidDisappear() {
        // This code will not be called on macOS 12 Monterey with QLIsDataBasedPreview set.
        
        self.launcherService = nil
    }
    
    override func loadView() {
        // This code will not be called on macOS 12 Monterey with QLIsDataBasedPreview set.

        super.loadView()
        Settings.shared.startMonitorChange()

        if #available(macOS 11, *) {
            let connection = NSXPCConnection(serviceName: "org.advison.textdown.external-launcher")
            connection.remoteObjectInterface = NSXPCInterface(with: ExternalLauncherProtocol.self)
            connection.resume()

            self.launcherService = connection.synchronousRemoteObjectProxyWithErrorHandler { error in
                print("Received error:", error)
            } as? ExternalLauncherProtocol
        }

        let settings = Settings.shared
        self.preferredContentSize = settings.qlWindowSize

        let previewRect = self.view.bounds

        // Create configuration
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = settings.unsafeHTMLOption && settings.inlineImageExtension
        configuration.allowsAirPlayForMediaPlayback = false

        self.webView = MyWKWebView(frame: previewRect, configuration: configuration)
        self.webView!.autoresizingMask = [.height, .width]
        self.webView!.wantsLayer = true
        self.webView!.navigationDelegate = self

        self.view.addSubview(self.webView!)
    }
    
    internal func getBundleContents(forResource: String, ofType: String) -> String?
    {
        if let p = Bundle.main.path(forResource: forResource, ofType: ofType), let data = FileManager.default.contents(atPath: p), let s = String(data: data, encoding: .utf8) {
            return s
        } else {
            return nil
        }
    }

    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.

        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
     */


    @available(macOSApplicationExtension 12.0, *)
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        Settings.shared.startMonitorChange()
        // This code will be called on macOS 12 Monterey with QLIsDataBasedPreview set.
        
        // print("providePreview for \(request.fileURL)")
        
        let html = try renderMD(url: request.fileURL)
        
        let reply = QLPreviewReply(dataOfContentType: .html, contentSize: Settings.shared.qlWindowSize) { (replyToUpdate : QLPreviewReply) in
            
            //replyToUpdate.title = request.fileURL.lastPathComponent
            
            //setting the stringEncoding for text and html data is optional and defaults to String.Encoding.utf8
            replyToUpdate.stringEncoding = .utf8
            
            return html.data(using: .utf8)!
        }

        // XPC removed
        // XPCWrapper.invalidateSharedConnection()
        return reply
    }
    
    func renderMD(url: URL) throws -> String {
        os_log(
            "Generating preview for file %{public}s",
            log: OSLog.quickLookExtension,
            type: .info,
            url.path
        )
        
        
        let settings = Settings.shared
        settings.renderStats += 1
        
        let no_nag = UserDefaults.standard.bool(forKey: "textdown-no-nag-screen")
        if !no_nag && settings.renderStats > 0 && settings.renderStats % 100 == 0, let msg = self.getBundleContents(forResource: "stats", ofType: "html") {
            let icon: String
            if let url = Bundle.main.url(forResource: "icon", withExtension: "png"), let data = try? Data(contentsOf: url) {
                icon = data.base64EncodedString()
            } else {
                icon = ""
            }
            
            return msg.replacingOccurrences(of: "%n_files%", with: "\(settings.renderStats)").replacingOccurrences(of: "%icon_path%", with: "data:image/png;base64,\(icon)")
        }
        
        let markdown_url: URL
        if let typeIdentifier = (try? url.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier, typeIdentifier == "org.textbundle.package" {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("text.md").path) {
                markdown_url = url.appendingPathComponent("text.md")
            } else {
                markdown_url = url.appendingPathComponent("text.markdown")
            }
        } else {
            markdown_url = url
        }
        
        let appearance: Appearance = Settings.isLightAppearance ? .light : .dark
        let text = try settings.render(file: markdown_url, forAppearance: appearance, baseDir: markdown_url.deletingLastPathComponent().path)
        
        let html = settings.getCompleteHTML(title: url.lastPathComponent, body: text, footer: "", basedir: url.deletingLastPathComponent(), forAppearance: appearance)
            
        return html
    }
}

extension PreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Show the Quick Look preview only after the complete rendering (preventing a flickering glitch).
        // Wait to show the webview to prevent a resize glitch.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webView?.isHidden = false
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.webView?.isHidden = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if !Settings.shared.openInlineLink, navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url, url.scheme != "file" {
            if #available(macOS 11, *) {
                // On Big Sur NSWorkspace.shared.open fail with this error on Console:
                // Launch Services generated an error at +[_LSRemoteOpenCall(PrivateCSUIAInterface) invokeWithXPCConnection:object:]:455, converting to OSStatus -54: Error Domain=NSOSStatusErrorDomain Code=-54 "The sandbox profile of this process is missing "(allow lsopen)", so it cannot invoke Launch Services' open API." UserInfo={NSDebugDescription=The sandbox profile of this process is missing "(allow lsopen)", so it cannot invoke Launch Services' open API., _LSLine=455, _LSFunction=+[_LSRemoteOpenCall(PrivateCSUIAInterface) invokeWithXPCConnection:object:]}
                // Using a XPC service is a valid workaround.
                launcherService?.open(url, withReply: { r in
                    // print("open result: \(r)")
                })
                decisionHandler(.cancel)
                return
            } else {
                let r = NSWorkspace.shared.open(url)
                if r {
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
}

