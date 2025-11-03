import Foundation

/// Use case for saving markdown documents to disk
/// Thread-safe actor that handles document persistence with backups
actor SaveDocumentUseCase {
    // MARK: - Dependencies

    private let documentRepository: DocumentRepository

    // MARK: - Configuration

    /// Whether to create backups before overwriting files
    private let createBackups: Bool

    // MARK: - Initialization

    init(documentRepository: DocumentRepository, createBackups: Bool = true) {
        self.documentRepository = documentRepository
        self.createBackups = createBackups
    }

    // MARK: - Business Logic

    /// Saves document content to a file with optional backup
    /// - Parameters:
    ///   - content: Markdown content to save
    ///   - url: File URL to write to
    ///   - encoding: Text encoding (default UTF-8)
    /// - Throws: DocumentError if save fails
    func execute(content: String, to url: URL, encoding: String.Encoding = .utf8) async throws {
        // Create backup if file exists and backups enabled
        if createBackups {
            let fileExists = await documentRepository.fileExists(at: url)
            if fileExists {
                do {
                    let backupURL = try await documentRepository.createBackup(for: url)
                    print("✅ Created backup: \(backupURL.lastPathComponent)")
                } catch {
                    print("⚠️ Failed to create backup: \(error)")
                    // Continue with save even if backup fails
                }
            }
        }

        // Write content
        try await documentRepository.write(content, to: url, encoding: encoding)

        print("✅ Saved document: \(url.lastPathComponent)")
    }

    /// Validates that a URL is writable before attempting save
    /// - Parameter url: File URL to check
    /// - Returns: True if URL is writable
    func canWrite(to url: URL) async -> Bool {
        // Check if directory exists and is writable
        let directory = url.deletingLastPathComponent()
        let fileManager = FileManager.default

        return fileManager.isWritableFile(atPath: directory.path)
    }
}
