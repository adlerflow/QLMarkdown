//
//  Settings.swift
//  TextDown
//
//  Created by adlerflow on 25/12/20.
//

import Foundation
import AppKit

extension Settings {
    func getAvailableStyles(resetCache reset: Bool = false) -> [URL] {
        guard let stylesFolder = Settings.getStylesFolder() else {
            return []
        }

        // Create themes directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: stylesFolder, withIntermediateDirectories: true)
        } catch {
            print("Failed to create themes directory: \(error.localizedDescription)")
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
