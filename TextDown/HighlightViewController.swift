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
            return AppConfiguration.shared.syntaxLineNumbersOption
        }
        set {
            guard newValue != AppConfiguration.shared.syntaxLineNumbersOption else { return }
            self.willChangeValue(forKey: "syntaxLineNumbers")
            AppConfiguration.shared.syntaxLineNumbersOption = newValue
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxLineNumbers")
        }
    }

    @objc dynamic var syntaxWrapEnabled: Bool {
        get {
            return AppConfiguration.shared.syntaxWordWrapOption > 0
        }
        set {
            guard newValue != (AppConfiguration.shared.syntaxWordWrapOption > 0) else { return }
            self.willChangeValue(forKey: "syntaxWrapEnabled")
            AppConfiguration.shared.syntaxWordWrapOption = newValue ? (syntaxWrapCharacters > 0 ? syntaxWrapCharacters : 80) : 0
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxWrapEnabled")
        }
    }

    @objc dynamic var syntaxWrapCharacters: Int {
        get {
            return AppConfiguration.shared.syntaxWordWrapOption > 0 ? AppConfiguration.shared.syntaxWordWrapOption : 80
        }
        set {
            guard newValue != (AppConfiguration.shared.syntaxWordWrapOption > 0 ? AppConfiguration.shared.syntaxWordWrapOption : 80) else { return }
            self.willChangeValue(forKey: "syntaxWrapCharacters")
            if syntaxWrapEnabled {
                AppConfiguration.shared.syntaxWordWrapOption = newValue
            }
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxWrapCharacters")
        }
    }

    @objc dynamic var syntaxTabsOption: Int {
        get {
            return AppConfiguration.shared.syntaxTabsOption
        }
        set {
            guard newValue != AppConfiguration.shared.syntaxTabsOption else { return }
            self.willChangeValue(forKey: "syntaxTabsOption")
            AppConfiguration.shared.syntaxTabsOption = newValue
            self.settingsViewController?.isDirty = true
            self.didChangeValue(forKey: "syntaxTabsOption")
        }
    }

    // guessEngine property and onGuessChange action removed - was for server-side language detection
    // searchTheme function removed - was for Lua theme selection (Theme.swift deleted)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let i = self.sourceTabsPopup.itemArray.firstIndex(where: { $0.tag == AppConfiguration.shared.syntaxTabsOption}) {
            self.sourceTabsPopup.selectItem(at: i)
        }
    }
}
