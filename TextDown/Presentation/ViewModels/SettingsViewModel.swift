import SwiftUI
import Combine

/// ViewModel for all settings views (General, Extensions, Syntax, Advanced)
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var settings: AppSettings

    // MARK: - Dependencies

    private let loadSettingsUseCase: LoadSettingsUseCase
    private let saveSettingsUseCase: SaveSettingsUseCase
    private let validateSettingsUseCase: ValidateSettingsUseCase

    // MARK: - Auto-save

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        loadSettingsUseCase: LoadSettingsUseCase,
        saveSettingsUseCase: SaveSettingsUseCase,
        validateSettingsUseCase: ValidateSettingsUseCase
    ) {
        self.loadSettingsUseCase = loadSettingsUseCase
        self.saveSettingsUseCase = saveSettingsUseCase
        self.validateSettingsUseCase = validateSettingsUseCase

        // Load initial settings (synchronously for initialization)
        self.settings = .default

        // Setup auto-save
        setupAutoSave()

        // Load settings asynchronously
        Task {
            await loadSettings()
        }
    }

    // MARK: - Settings Management

    func loadSettings() async {
        settings = await loadSettingsUseCase.execute()
    }

    func saveSettings() async {
        do {
            try await saveSettingsUseCase.execute(settings)
        } catch {
            print("❌ Failed to save settings: \(error)")
        }
    }

    func resetToDefaults() async {
        do {
            try await saveSettingsUseCase.resetToDefaults()
            settings = .default
        } catch {
            print("❌ Failed to reset settings: \(error)")
        }
    }

    func validateSettings() async -> [ValidationIssue] {
        await validateSettingsUseCase.validate(settings)
    }

    // MARK: - Convenience Accessors

    var editor: EditorSettings {
        get { settings.editor }
        set {
            settings = AppSettings(
                editor: newValue,
                markdown: settings.markdown,
                syntaxTheme: settings.syntaxTheme,
                css: settings.css
            )
        }
    }

    var markdown: MarkdownSettings {
        get { settings.markdown }
        set {
            settings = AppSettings(
                editor: settings.editor,
                markdown: newValue,
                syntaxTheme: settings.syntaxTheme,
                css: settings.css
            )
        }
    }

    var syntaxTheme: SyntaxTheme {
        get { settings.syntaxTheme }
        set {
            settings = AppSettings(
                editor: settings.editor,
                markdown: settings.markdown,
                syntaxTheme: newValue,
                css: settings.css
            )
        }
    }

    var css: CSSSettings {
        get { settings.css }
        set {
            settings = AppSettings(
                editor: settings.editor,
                markdown: settings.markdown,
                syntaxTheme: settings.syntaxTheme,
                css: newValue
            )
        }
    }

    // MARK: - Auto-Save

    private func setupAutoSave() {
        // Auto-save when settings change (debounced 1 second)
        $settings
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    await self.saveSettings()
                }
            }
            .store(in: &cancellables)
    }
}
