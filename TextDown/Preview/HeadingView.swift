//
//  HeadingView.swift
//  TextDown
//
//  Renders markdown headings (# through ######)
//

import SwiftUI
import Markdown

/// Renders markdown headings with appropriate font sizes
struct HeadingView: View {
    let heading: Heading

    var body: some View {
        Text(heading.plainText)
            .font(fontForLevel(heading.level))
            .fontWeight(.bold)
            .id("heading-\(heading.plainText.hashValue)")  // For scroll sync
            .padding(.vertical, verticalPaddingForLevel(heading.level))
    }

    private func fontForLevel(_ level: Int) -> Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3: return .title2
        case 4: return .title3
        case 5: return .headline
        default: return .body.bold()
        }
    }

    private func verticalPaddingForLevel(_ level: Int) -> CGFloat {
        switch level {
        case 1: return 8
        case 2: return 6
        case 3, 4: return 4
        default: return 2
        }
    }
}
