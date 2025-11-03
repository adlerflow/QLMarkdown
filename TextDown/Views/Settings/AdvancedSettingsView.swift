//
//  AdvancedSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("cmark Parser Options") {
                Toggle("Footnotes", isOn: $appState.enableFootnotes)
                    .help("Enable footnote syntax: [^1] and [^1]: footnote text")

                Toggle("Hard line breaks", isOn: $appState.enableHardBreaks)
                    .help("Treat single line breaks (\\n) as <br> tags")

                Toggle("Disable soft line breaks", isOn: $appState.disableSoftBreaks)
                    .help("Don't convert soft line breaks to spaces")

                Toggle("Allow unsafe HTML", isOn: $appState.allowUnsafeHTML)
                    .help("⚠️ Allow raw HTML in markdown (security risk!)")

                Toggle("Smart quotes", isOn: $appState.enableSmartQuotes)
                    .help("Convert straight quotes to \"curly quotes\"")

                Toggle("Validate UTF-8 strictly", isOn: $appState.validateUTF8)
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
        appState.resetToDefaults()
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(AppState())
        .frame(width: 600, height: 500)
}
