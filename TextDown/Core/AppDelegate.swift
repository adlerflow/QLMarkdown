//
//  AppDelegate.swift
//  TextDown
//
//  Created by adlerflow on 09/12/20.
//

import Cocoa
import Sparkle
import SwiftUI
import OSLog

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    var userDriver: SPUStandardUserDriver?
    var updater: SPUUpdater?
    private var preferencesWindow: NSWindow?

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filename)

        NSDocumentController.shared.openDocument(
            withContentsOf: fileURL,
            display: true
        ) { _, _, error in
            if let error = error {
                os_log(.error, log: .default, "Failed to open document: %{public}@",
                       error.localizedDescription)
            }
        }

        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // NSDocumentController automatically handles prompting for unsaved changes
        return .terminateNow
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Register default values for UserDefaults
        UserDefaults.standard.register(defaults: [
            "auto-refresh": true  // Enable auto-refresh by default
        ])

        // Insert code here to initialize your application
        let hostBundle = Bundle.main
        let applicationBundle = hostBundle;

        self.userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        self.updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: applicationBundle, userDriver: self.userDriver!, delegate: nil)

        do {
            try self.updater!.start()
        } catch {
            os_log(.error, log: .default, "Failed to start updater with error: %{public}@",
                   error.localizedDescription)

            let alert = NSAlert()
            alert.messageText = "Updater Error"
            alert.informativeText = "The Updater failed to start. For detailed error information, check the Console.app log."
            alert.addButton(withTitle: "Close").keyEquivalent = "\u{1b}"
            alert.runModal()
        }
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        // Create a new untitled document on launch
        os_log(.debug, log: .default, "applicationShouldOpenUntitledFile called")
        return true
    }

    func application(_ sender: NSApplication, printFile filename: String) -> Bool {
        // Handle print request for single file
        let fileURL = URL(fileURLWithPath: filename)
        
        NSDocumentController.shared.openDocument(
            withContentsOf: fileURL,
            display: false
        ) { document, _, error in
            if let error = error {
                os_log(.error, log: .default, "Failed to open document for printing: %{public}@",
                       error.localizedDescription)
                return
            }

            document?.printDocument(nil)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func checkForUpdates(_ sender: Any) {
        self.updater?.checkForUpdates()
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.checkForUpdates(_:)) {
            return self.updater?.canCheckForUpdates ?? false
        }
        if menuItem.identifier?.rawValue.starts(with: "update_refresh") ?? false {
            menuItem.state = ((NSApplication.shared.delegate as? AppDelegate)?.updater?.updateCheckInterval == TimeInterval(menuItem.tag)) ? .on : .off
        } else if menuItem.identifier?.rawValue == "auto refresh" {
            if let a = UserDefaults.standard.value(forKey: "auto-refresh") as? Bool {
                menuItem.state = a ? .on : .off
            }
        }
        return true
    }

    @IBAction func onUpdateRate(_ sender: NSMenuItem) {
        updater?.updateCheckInterval = TimeInterval(sender.tag)
    }

    // MARK: - Preferences Window

    @IBAction func showPreferences(_ sender: Any) {
        // If window already exists, just bring it to front
        if let window = preferencesWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create SwiftUI view
        let settingsView = TextDownSettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        // Create window
        let window = NSWindow(contentViewController: hostingController)
        window.title = "TextDown Preferences"
        window.styleMask = [.titled, .closable, .resizable]
        window.level = .floating
        window.center()

        // Handle window close to release reference
        window.delegate = self

        preferencesWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == preferencesWindow {
            preferencesWindow = nil
        }
    }
}
