//
//  AppConfiguration+Themes.swift
//  TextDown
//
//  Created by adlerflow on 25/12/20.
//

import Foundation
import OSLog

extension AppConfiguration {
    func getAvailableStyles(resetCache reset: Bool = false) -> [URL] {
        guard let stylesFolder = AppConfiguration.getStylesFolder() else {
            return []
        }

        // Create themes directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: stylesFolder, withIntermediateDirectories: true)
        } catch {
            os_log(.error, log: .settings, "Failed to create themes directory: %{public}@",
                   error.localizedDescription)
            return []
        }

        // Enumerate .css files in the themes directory
        guard let enumerator = FileManager.default.enumerator(
            at: stylesFolder,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return []
        }

        var styles: [URL] = []

        for case let fileURL as URL in enumerator {
            // Check if it's a .css file
            if fileURL.pathExtension.lowercased() == "css" {
                styles.append(fileURL)
            }
        }

        // Sort by filename for consistent ordering
        return styles.sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }
}
