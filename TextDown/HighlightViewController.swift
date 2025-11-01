//
//  HighlightViewController.swift
//  TextDown
//
//  Created by adlerflow on 14/04/23.
//

import AppKit

class HighlightViewController: NSViewController {
    weak var settingsViewController: DocumentViewController? = nil
    
    @IBOutlet weak var sourceWrapField: NSTextField!
    @IBOutlet weak var sourceWrapStepper: NSStepper!
    @IBOutlet weak var sourceTabsPopup: NSPopUpButton!
    
    
    @objc dynamic var syntaxLineNumbers: Bool {
        get {
            return self.settingsViewController?.syntaxLineNumbers ?? false
        }
        set {
            guard newValue != self.settingsViewController?.syntaxLineNumbers else { return }
            self.willChangeValue(forKey: "syntaxLineNumbers")
            self.settingsViewController?.syntaxLineNumbers = newValue
            self.didChangeValue(forKey: "syntaxLineNumbers")
        }
    }
    
    @objc dynamic var syntaxWrapEnabled: Bool {
        get {
            return self.settingsViewController?.syntaxWrapEnabled ?? false
        }
        set {
            guard newValue != self.settingsViewController?.syntaxWrapEnabled else { return }
            self.willChangeValue(forKey: "syntaxWrapEnabled")
            self.settingsViewController?.syntaxWrapEnabled = newValue
            self.didChangeValue(forKey: "syntaxWrapEnabled")
        }
    }
    
    @objc dynamic var syntaxWrapCharacters: Int {
        get {
            return self.settingsViewController?.syntaxWrapCharacters ?? 80
        }
        set {
            guard newValue != self.settingsViewController?.syntaxWrapCharacters else { return }
            self.willChangeValue(forKey: "syntaxWrapCharacters")
            self.settingsViewController?.syntaxWrapCharacters = newValue
            self.didChangeValue(forKey: "syntaxWrapCharacters")
        }
    }
    
    @objc dynamic var syntaxTabsOption: Int {
        get {
            return self.settingsViewController?.syntaxTabsOption ?? 80
        }
        set {
            guard newValue != self.settingsViewController?.syntaxTabsOption else { return }
            self.willChangeValue(forKey: "syntaxTabsOption")
            self.settingsViewController?.syntaxTabsOption = newValue
            self.didChangeValue(forKey: "syntaxTabsOption")
        }
    }

    // guessEngine property and onGuessChange action removed - was for server-side language detection
    // searchTheme function removed - was for Lua theme selection (Theme.swift deleted)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let settings = self.settingsViewController?.updateSettings() {
            self.initFromSettings(settings)
        }
    }

    internal func initFromSettings(_ settings: Settings) {
        self.settingsViewController?.pauseAutoRefresh += 1
        self.settingsViewController?.pauseAutoSave += 1
        
        self.syntaxLineNumbers = settings.syntaxLineNumbersOption
        self.syntaxWrapEnabled = settings.syntaxWordWrapOption > 0
        
        self.syntaxWrapCharacters = settings.syntaxWordWrapOption > 0 ? settings.syntaxWordWrapOption : 80
        if let i = self.sourceTabsPopup.itemArray.firstIndex(where: { $0.tag == settings.syntaxTabsOption}) {
            self.sourceTabsPopup.selectItem(at: i)
        }
        
                
        self.settingsViewController?.pauseAutoRefresh -= 1
        self.settingsViewController?.pauseAutoSave -= 1
    }
}
