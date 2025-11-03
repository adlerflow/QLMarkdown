//
//  AdvancedSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("cmark Parser Options") {
                Toggle("Footnotes", isOn: $settingsViewModel.settings.markdown.enableFootnotes)
                    .help("Enable footnote syntax: [^1] and [^1]: footnote text")

                Toggle("Hard line breaks", isOn: $settingsViewModel.settings.markdown.enableHardBreaks)
                    .help("Treat single line breaks (\\n) as <br> tags")

                Toggle("Disable soft line breaks", isOn: $settingsViewModel.settings.markdown.disableSoftBreaks)
                    .help("Don't convert soft line breaks to spaces")

                Toggle("Allow unsafe HTML", isOn: $settingsViewModel.settings.markdown.allowUnsafeHTML)
                    .help("⚠️ Allow raw HTML in markdown (security risk!)")

                Toggle("Smart quotes", isOn: $settingsViewModel.settings.markdown.enableSmartQuotes)
                    .help("Convert straight quotes to \"curly quotes\"")

                Toggle("Validate UTF-8 strictly", isOn: $settingsViewModel.settings.markdown.validateUTF8)
                    .help("Enforce strict UTF-8 validation (may reject some files)")
            }

            Section("Reset") {
                Button("Reset All Settings to Factory Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)

                Text("This will reset all settings to their default values. Changes are auto-saved after 1 second.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }

    private func resetToDefaults() {
        Task {
            await settingsViewModel.resetToDefaults()
        }
    }
}

#Preview {
    let settingsRepo = SettingsRepositoryImpl()
    let loadUseCase = LoadSettingsUseCase(settingsRepository: settingsRepo)
    let saveUseCase = SaveSettingsUseCase(settingsRepository: settingsRepo)
    let validateUseCase = ValidateSettingsUseCase()

    let viewModel = SettingsViewModel(
        loadSettingsUseCase: loadUseCase,
        saveSettingsUseCase: saveUseCase,
        validateSettingsUseCase: validateUseCase
    )

    return AdvancedSettingsView()
        .environmentObject(viewModel)
        .frame(width: 600, height: 500)
}
