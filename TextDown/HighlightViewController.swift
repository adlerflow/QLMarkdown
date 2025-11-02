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
            return Settings.shared.syntaxLineNumbersOption
        }
        set {
            guard newValue != Settings.shared.syntaxLineNumbersOption else { return }
            self.willChangeValue(forKey: "syntaxLineNumbers")
            Settings.shared.syntaxLineNumbersOption = newValue
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxLineNumbers")
        }
    }

    @objc dynamic var syntaxWrapEnabled: Bool {
        get {
            return Settings.shared.syntaxWordWrapOption > 0
        }
        set {
            guard newValue != (Settings.shared.syntaxWordWrapOption > 0) else { return }
            self.willChangeValue(forKey: "syntaxWrapEnabled")
            Settings.shared.syntaxWordWrapOption = newValue ? (syntaxWrapCharacters > 0 ? syntaxWrapCharacters : 80) : 0
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxWrapEnabled")
        }
    }

    @objc dynamic var syntaxWrapCharacters: Int {
        get {
            return Settings.shared.syntaxWordWrapOption > 0 ? Settings.shared.syntaxWordWrapOption : 80
        }
        set {
            guard newValue != (Settings.shared.syntaxWordWrapOption > 0 ? Settings.shared.syntaxWordWrapOption : 80) else { return }
            self.willChangeValue(forKey: "syntaxWrapCharacters")
            if syntaxWrapEnabled {
                Settings.shared.syntaxWordWrapOption = newValue
            }
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxWrapCharacters")
        }
    }

    @objc dynamic var syntaxTabsOption: Int {
        get {
            return Settings.shared.syntaxTabsOption
        }
        set {
            guard newValue != Settings.shared.syntaxTabsOption else { return }
            self.willChangeValue(forKey: "syntaxTabsOption")
            Settings.shared.syntaxTabsOption = newValue
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxTabsOption")
        }
    }

    // guessEngine property and onGuessChange action removed - was for server-side language detection
    // searchTheme function removed - was for Lua theme selection (Theme.swift deleted)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let i = self.sourceTabsPopup.itemArray.firstIndex(where: { $0.tag == Settings.shared.syntaxTabsOption}) {
            self.sourceTabsPopup.selectItem(at: i)
        }
    }
}
