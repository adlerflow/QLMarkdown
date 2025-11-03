import SwiftUI
import Combine

/// ViewModel for the main editor view
/// Coordinates document editing, preview, and refresh behavior
@MainActor
class EditorViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Force refresh trigger for manual preview updates
    @Published var refreshTrigger: UUID = UUID()

    // MARK: - Dependencies

    private let settingsViewModel: SettingsViewModel
    private let documentViewModel: DocumentViewModel

    // MARK: - Debouncing

    private var parseTask: Task<Void, Never>?
    private let parseDebounceInterval: TimeInterval = 0.5

    // MARK: - Initialization

    init(
        settingsViewModel: SettingsViewModel,
        documentViewModel: DocumentViewModel
    ) {
        self.settingsViewModel = settingsViewModel
        self.documentViewModel = documentViewModel
    }

    // MARK: - Editor Actions

    /// Triggers manual preview refresh
    func refreshPreview() {
        refreshTrigger = UUID()

        Task {
            await documentViewModel.parseContent()
        }
    }

    /// Handles content changes with debounced parsing (always enabled)
    func handleContentChange() {
        // Cancel previous parse task
        parseTask?.cancel()

        // Schedule new parse with debounce
        parseTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(parseDebounceInterval * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await documentViewModel.parseContent()
            refreshTrigger = UUID()
        }
    }
}
