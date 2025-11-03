//
//  GeneralSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Bindable var settings: AppConfiguration

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Show \"About TextDown\" footer", isOn: $settings.about)
                    .help("Display About TextDown credit at bottom of rendered preview")
            }

            Section("CSS Theme") {
                // TODO: Implement CSS theme picker
                // Need to get available styles and display them
                Toggle("Override default CSS (instead of extend)", isOn: $settings.customCSSOverride)
                    .help("Replace default CSS completely instead of extending it")
            }

            Section("Behavior") {
                Toggle("Open inline links in preview", isOn: $settings.openInlineLink)
                    .help("Open markdown links within WKWebView instead of external browser")

                Toggle("Debug mode", isOn: $settings.debug)
                    .help("Enable debug logging in Console.app")
            }

        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try! encoder.encode(AppConfiguration.shared)
    let previewSettings = try! decoder.decode(AppConfiguration.self, from: data)

    GeneralSettingsView(settings: previewSettings)
        .frame(width: 600, height: 500)
}
