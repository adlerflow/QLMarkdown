//
//  HeadingIDGenerator.swift
//  TextDown
//
//  Generates unique anchor IDs for headings
//  Used in HTML post-processing to add id="..." attributes
//
//  Created by adlerflow on 2025-11-02
//

import Foundation

/// Generates unique, URL-safe anchor IDs for HTML headings
///
/// Example: "Hello World!" → "hello-world"
///          "Hello World!" (duplicate) → "hello-world-1"
struct HeadingIDGenerator {
    private var usedIDs: Set<String> = []

    /// Generate a unique ID from heading text
    /// - Parameter text: Raw heading text (may contain formatting)
    /// - Returns: Unique, URL-safe ID string
    mutating func generateID(from text: String) -> String {
        let sanitized = sanitizeForID(text)

        // Handle empty result
        guard !sanitized.isEmpty else {
            return makeUnique("heading")
        }

        return makeUnique(sanitized)
    }

    /// Make an ID unique by appending -N if needed
    private mutating func makeUnique(_ id: String) -> String {
        var candidate = id
        var counter = 1

        while usedIDs.contains(candidate) {
            candidate = "\(id)-\(counter)"
            counter += 1
        }

        usedIDs.insert(candidate)
        return candidate
    }

    /// Sanitize text for use as HTML ID attribute
    /// Rules:
    /// - Lowercase
    /// - Unicode letters/numbers preserved
    /// - Spaces → hyphens
    /// - Other chars removed
    /// - Leading/trailing hyphens trimmed
    /// - Multiple consecutive hyphens → single hyphen
    private func sanitizeForID(_ text: String) -> String {
        var result = text.lowercased()

        // Keep only: Unicode letters, Unicode numbers, spaces, hyphens
        result = result.replacingOccurrences(of: #"[^\p{L}\p{N} -]+"#, with: "", options: .regularExpression)

        // Replace spaces with hyphens
        result = result.replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)

        // Remove leading/trailing hyphens
        result = result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        // Collapse multiple consecutive hyphens
        result = result.replacingOccurrences(of: #"-{2,}"#, with: "-", options: .regularExpression)

        return result
    }

    /// Reset the used IDs set (for processing a new document)
    mutating func reset() {
        usedIDs.removeAll()
    }
}
