//
//  AdvancedSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("cmark Parser Options") {
                Toggle("Footnotes", isOn: $viewModel.footnotesOption)
                    .help("Enable footnote syntax: [^1] and [^1]: footnote text")

                Toggle("Hard line breaks", isOn: $viewModel.hardBreakOption)
                    .help("Treat single line breaks (\\n) as <br> tags")

                Toggle("Disable soft line breaks", isOn: $viewModel.noSoftBreakOption)
                    .help("Don't convert soft line breaks to spaces")

                Toggle("Allow unsafe HTML", isOn: $viewModel.unsafeHTMLOption)
                    .help("⚠️ Allow raw HTML in markdown (security risk!)")

                Toggle("Smart quotes", isOn: $viewModel.smartQuotesOption)
                    .help("Convert straight quotes to \"curly quotes\"")

                Toggle("Validate UTF-8 strictly", isOn: $viewModel.validateUTFOption)
                    .help("Enforce strict UTF-8 validation (may reject some files)")
            }

            Section("Rendering") {
                Toggle("Render as code", isOn: $viewModel.renderAsCode)
                    .help("Escape HTML and render markdown as plain code block")
            }

            Section("Reset") {
                Button("Reset All Settings to Factory Defaults") {
                    viewModel.resetToDefaults()
                }
                .buttonStyle(.bordered)

                Text("This will reset all settings to their default values. You must click Apply to save changes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    AdvancedSettingsView(viewModel: SettingsViewModel(from: Settings.shared))
        .frame(width: 600, height: 500)
}
