//
//  SyntaxSettingsView.swift
//  TextDown
//
//  Created by adlerflow on 31/10/25.
//

import SwiftUI

struct SyntaxSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Syntax Highlighting") {
                Toggle("Enable syntax highlighting", isOn: $viewModel.syntaxHighlightExtension)
                    .help("Apply color syntax highlighting to fenced code blocks")

                if viewModel.syntaxHighlightExtension {
                    Toggle("Show line numbers", isOn: $viewModel.syntaxLineNumbersOption)
                        .padding(.leading, 20)
                        .help("Display line numbers in code blocks")

                    HStack {
                        Text("Tab width:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Tab width", value: $viewModel.syntaxTabsOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("spaces")
                    }
                    .padding(.leading, 20)
                    .help("Number of spaces per tab character")

                    HStack {
                        Text("Word wrap:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("Word wrap", value: $viewModel.syntaxWordWrapOption, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("characters (0 = disabled)")
                    }
                    .padding(.leading, 20)
                    .help("Wrap lines at specified column (0 to disable)")
                }
            }

            // Language Detection section removed - was for server-side syntax highlighting

            Section("Themes") {
                Picker("Light theme:", selection: $viewModel.syntaxThemeLightOption) {
                    Text("GitHub").tag("github")
                    Text("Base16 GitHub").tag("base16-github")
                    Text("Atom One Light").tag("atom-one-light")
                    Text("Stack Overflow Light").tag("stackoverflow-light")
                    Text("Xcode").tag("xcode")
                    Text("Visual Studio").tag("vs")
                }
                .pickerStyle(.menu)
                .help("Theme used in light mode")

                Picker("Dark theme:", selection: $viewModel.syntaxThemeDarkOption) {
                    Text("GitHub Dark").tag("github-dark")
                    Text("Atom One Dark").tag("atom-one-dark")
                    Text("Monokai").tag("monokai")
                    Text("Monokai Sublime").tag("monokai-sublime")
                    Text("Nord").tag("nord")
                    Text("Visual Studio 2015").tag("vs2015")
                }
                .pickerStyle(.menu)
                .help("Theme used in dark mode")

                Text("Themes automatically switch based on macOS appearance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    SyntaxSettingsView(viewModel: SettingsViewModel(from: Settings.shared))
        .frame(width: 600, height: 500)
}
