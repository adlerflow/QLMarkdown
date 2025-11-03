import SwiftUI

/// Pure SwiftUI About Dialog
struct AboutView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 16) {
            // App Icon (from Asset Catalog)
            Image("AppIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(16)
                .shadow(radius: 4)

            Text("TextDown")
                .font(.system(.title, design: .rounded, weight: .bold))

            Text("Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Copyright © 2025 adlerflow")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("Built with:")
                    .font(.caption.bold())

                Group {
                    Text("• swift-markdown 0.5.0")
                    Text("• SwiftUI (Pure)")
                    Text("• No AppKit Dependencies ✨")
                    Text("• Native Markdown Rendering")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // GitHub Link Button
            Button {
                if let url = URL(string: "https://github.com/adlerflow/TextDown") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                    Text("GitHub Repository")
                }
                .font(.caption)
            }
            .buttonStyle(.link)
        }
        .padding(32)
        .frame(width: 360, height: 400)
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

// MARK: - Preview

#Preview {
    AboutView()
}
