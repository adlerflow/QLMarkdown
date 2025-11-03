//
//  GeneralSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Show \"About TextDown\" footer", isOn: $appState.about)
                    .help("Display About TextDown credit at bottom of rendered preview")
            }

            Section("CSS Theme") {
                // TODO: Implement CSS theme picker
                // Need to get available styles and display them
                Toggle("Override default CSS (instead of extend)", isOn: $appState.customCSSOverride)
                    .help("Replace default CSS completely instead of extending it")
            }

            Section("Behavior") {
                Toggle("Open inline links in preview", isOn: $appState.openInlineLink)
                    .help("Open markdown links inline instead of external browser")

                Toggle("Debug mode", isOn: $appState.debug)
                    .help("Enable debug logging in Console.app")
            }

        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(AppState())
        .frame(width: 600, height: 500)
}
