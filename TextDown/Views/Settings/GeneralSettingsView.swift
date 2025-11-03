//
//  GeneralSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Show \"About TextDown\" footer", isOn: $settingsViewModel.settings.editor.about)
                    .help("Display About TextDown credit at bottom of rendered preview")
            }

            Section("CSS Theme") {
                Text("Note: TextDown uses native SwiftUI rendering (not CSS)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("CSS theming is not applicable in Pure SwiftUI mode. Colors are controlled by the system appearance (light/dark mode).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Behavior") {
                Toggle("Open inline links in preview", isOn: $settingsViewModel.settings.editor.openInlineLink)
                    .help("Open markdown links inline instead of external browser")

                Toggle("Debug mode", isOn: $settingsViewModel.settings.editor.debug)
                    .help("Enable debug logging in Console.app")
            }

        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
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

    return GeneralSettingsView()
        .environmentObject(viewModel)
        .frame(width: 600, height: 500)
}
