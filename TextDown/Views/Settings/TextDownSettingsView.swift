//
//  TextDownSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

/// Pure SwiftUI Settings Window with direct AppState bindings
struct TextDownSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            ExtensionsSettingsView()
                .tabItem {
                    Label("Extensions", systemImage: "puzzlepiece.extension")
                }

            SyntaxSettingsView()
                .tabItem {
                    Label("Syntax", systemImage: "chevron.left.forwardslash.chevron.right")
                }

            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2")
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
    TextDownSettingsView()
        .environmentObject(AppState())
        .frame(width: 650, height: 550)
}
