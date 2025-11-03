//
//  TextDownSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

/// Pure SwiftUI Settings Window with Clean Architecture
struct TextDownSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case extensions = "Extensions"
        case syntax = "Syntax"
        case advanced = "Advanced"

        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .extensions: return "puzzlepiece.extension"
            case .syntax: return "chevron.left.forwardslash.chevron.right"
            case .advanced: return "gearshape.2"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 8) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Label(tab.rawValue, systemImage: tab.icon)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(selectedTab == tab ? .accentColor : .primary)
                }
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Content
            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .extensions:
                    ExtensionsSettingsView()
                case .syntax:
                    SyntaxSettingsView()
                case .advanced:
                    AdvancedSettingsView()
                }
            }
        }
        .frame(width: 650, height: 550)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
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

    return TextDownSettingsView()
        .environmentObject(viewModel)
        .frame(width: 650, height: 550)
}
