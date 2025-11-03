import SwiftUI

@main
struct TextDownApp: App {
    // MARK: - Composition Root
    // This is where dependency injection happens - repositories → use cases → ViewModels

    // MARK: - Repositories (Data Layer)

    private let markdownParserRepository: MarkdownParserRepository
    private let settingsRepository: SettingsRepository
    private let documentRepository: DocumentRepository

    // MARK: - Use Cases (Domain Layer)

    private let parseMarkdownUseCase: ParseMarkdownUseCase
    private let loadSettingsUseCase: LoadSettingsUseCase
    private let saveSettingsUseCase: SaveSettingsUseCase
    private let validateSettingsUseCase: ValidateSettingsUseCase
    private let saveDocumentUseCase: SaveDocumentUseCase

    // MARK: - ViewModels (Presentation Layer)

    @StateObject private var settingsViewModel: SettingsViewModel

    // MARK: - Initialization

    init() {
        // Create repositories
        let parserRepo = MarkdownParserRepositoryImpl()
        let settingsRepo = SettingsRepositoryImpl()
        let documentRepo = DocumentRepositoryImpl()

        self.markdownParserRepository = parserRepo
        self.settingsRepository = settingsRepo
        self.documentRepository = documentRepo

        // Create use cases (inject repositories)
        let parseUseCase = ParseMarkdownUseCase(parserRepository: parserRepo)
        let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
        let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
        let validateUseCase = ValidateSettingsUseCase()
        let saveDocUseCase = SaveDocumentUseCase(documentRepository: documentRepo)

        self.parseMarkdownUseCase = parseUseCase
        self.loadSettingsUseCase = loadUseCase
        self.saveSettingsUseCase = saveUseCase
        self.validateSettingsUseCase = validateUseCase
        self.saveDocumentUseCase = saveDocUseCase

        // Create ViewModels (inject use cases)
        let settingsVM = SettingsViewModel(
            loadSettingsUseCase: loadUseCase,
            saveSettingsUseCase: saveUseCase,
            validateSettingsUseCase: validateUseCase
        )

        self._settingsViewModel = StateObject(wrappedValue: settingsVM)
    }

    var body: some Scene {
        // Haupt-Dokumenten-Szene
        DocumentGroup(newDocument: MarkdownFileDocument()) { file in
            MarkdownEditorView(
                document: file.$document,
                parseMarkdownUseCase: parseMarkdownUseCase,
                settingsViewModel: settingsViewModel
            )
            .environmentObject(settingsViewModel)
        }
        .commands {
            TextDownCommands()
        }

        // Einstellungen (bereits SwiftUI)
        SwiftUI.Settings {
            TextDownSettingsView()
                .environmentObject(settingsViewModel)
        }

        // About-Fenster
        Window("About TextDown", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
