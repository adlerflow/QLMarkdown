//
//  GeneralSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Bindable var settings: Settings

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

            Section("QuickLook Window Size") {
                HStack {
                    Text("Width:")
                        .frame(width: 60, alignment: .trailing)
                    TextField("Width", value: $settings.qlWindowWidth, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)

                    Text("Height:")
                        .frame(width: 60, alignment: .trailing)
                    TextField("Height", value: $settings.qlWindowHeight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                }
                .help("Set QuickLook preview window dimensions (leave empty for default)")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try! encoder.encode(Settings.shared)
    let previewSettings = try! decoder.decode(Settings.self, from: data)

    return GeneralSettingsView(settings: previewSettings)
        .frame(width: 600, height: 500)
}
