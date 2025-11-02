//
//  InlineImageRewriter.swift
//  TextDown
//
//  swift-markdown Rewriter for inline images
//  Converts ![alt](local.png) → ![alt](data:image/png;base64,...)
//
//  Created by adlerflow on 2025-11-02
//

import Foundation
import Markdown
import UniformTypeIdentifiers
import OSLog

/// Rewriter that encodes local images as Base64 data URLs
///
/// Example: `![Logo](logo.png)` → `![Logo](data:image/png;base64,iVBORw0...)`
///
/// Features:
/// - MIME type detection via UTType + magic bytes fallback
/// - File size limit (10 MB default)
/// - Only processes local paths (skips http:// URLs and data: URLs)
struct InlineImageRewriter: MarkupRewriter {
    let baseDirectory: URL
    let maxFileSize: Int64
    let enabled: Bool

    init(baseDirectory: URL, maxFileSize: Int64 = 10_000_000, enabled: Bool = true) {
        self.baseDirectory = baseDirectory
        self.maxFileSize = maxFileSize
        self.enabled = enabled
    }

    mutating func visitImage(_ image: Image) -> Markup? {
        guard enabled else { return image }
        guard let source = image.source else { return image }

        // Skip remote URLs and data URLs
        if source.hasPrefix("http://") || source.hasPrefix("https://") || source.hasPrefix("data:") {
            return image
        }

        // Resolve relative path
        let imageURL = baseDirectory.appendingPathComponent(source)

        // Encode to data URL
        guard let dataURL = encodeImageAsDataURL(at: imageURL) else {
            os_log("Failed to encode image: %{public}@", log: OSLog.rendering, type: .error, source)
            return image // Return original on failure
        }

        // Create new image with data URL
        var newImage = image
        newImage.source = dataURL
        return newImage
    }

    /// Encode image file as data URL
    private func encodeImageAsDataURL(at url: URL) -> String? {
        // Check file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        // Check file size
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64,
              fileSize <= maxFileSize else {
            // Get file size for logging even if check failed
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? -1
            os_log("Image too large: %{public}@ (%lld bytes)", log: OSLog.rendering, type: .error, url.lastPathComponent, size)
            return nil
        }

        // Read file data
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        // Detect MIME type
        let mimeType = detectMIMEType(data: data, url: url)

        // Encode as Base64
        let base64 = data.base64EncodedString()

        return "data:\(mimeType);base64,\(base64)"
    }

    /// Detect MIME type using UTType + magic bytes fallback
    private func detectMIMEType(data: Data, url: URL) -> String {
        // Try UTType first (uses file extension)
        if let utType = UTType(filenameExtension: url.pathExtension),
           let mimeType = utType.preferredMIMEType {
            return mimeType
        }

        // Fallback: Magic byte detection
        if let mimeType = detectMIMETypeFromMagicBytes(data) {
            return mimeType
        }

        // Default fallback
        return "application/octet-stream"
    }

    /// Detect MIME type from file header magic bytes
    private func detectMIMETypeFromMagicBytes(_ data: Data) -> String? {
        guard data.count >= 12 else { return nil }

        let bytes = data.prefix(12)

        // JPEG
        if bytes.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "image/jpeg"
        }

        // PNG
        if bytes.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
            return "image/png"
        }

        // GIF
        if bytes.starts(with: [0x47, 0x49, 0x46, 0x38]) { // "GIF8"
            return "image/gif"
        }

        // WebP
        if bytes.count >= 12,
           bytes[0...3] == Data([0x52, 0x49, 0x46, 0x46]), // "RIFF"
           bytes[8...11] == Data([0x57, 0x45, 0x42, 0x50]) { // "WEBP"
            return "image/webp"
        }

        // BMP
        if bytes.starts(with: [0x42, 0x4D]) { // "BM"
            return "image/bmp"
        }

        // ICO
        if bytes.starts(with: [0x00, 0x00, 0x01, 0x00]) {
            return "image/x-icon"
        }

        // TIFF (little-endian)
        if bytes.starts(with: [0x49, 0x49, 0x2A, 0x00]) {
            return "image/tiff"
        }

        // TIFF (big-endian)
        if bytes.starts(with: [0x4D, 0x4D, 0x00, 0x2A]) {
            return "image/tiff"
        }

        return nil
    }
}
