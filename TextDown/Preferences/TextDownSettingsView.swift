//
//  TextDownSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct TextDownSettingsView: View {
    @StateObject private var viewModel = SettingsViewModel(from: Settings.shared)
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            GeneralSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            ExtensionsSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Extensions", systemImage: "puzzlepiece.extension")
                }

            SyntaxSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Syntax", systemImage: "chevron.left.forwardslash.chevron.right")
                }

            AdvancedSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2")
                }
        }
        .frame(width: 650, height: 550)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancel()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }

            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Apply") {
                    viewModel.apply()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.hasUnsavedChanges)
            }
        }
    }
}

#Preview {
    TextDownSettingsView()
        .frame(width: 650, height: 550)
}
