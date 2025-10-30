//
//  Log.swift
//  TextDown
//
//  Created by adlerflow on 21/03/22.
//

import Foundation
import OSLog

extension OSLog {
    private static let subsystem = "org.advison.TextDown"

    static let quickLookExtension = OSLog(subsystem: subsystem, category: "Quick Look Extension")
    static let cli = OSLog(subsystem: subsystem, category: "Command Line Tool")
    static let shortcutExtension = OSLog(subsystem: subsystem, category: "Shotcut Extension")
    static let highlightWrapperExtension = OSLog(subsystem: subsystem, category: "Highlight Wrapper")
    static let rendering = OSLog(subsystem: subsystem, category: "Rendering")
}
