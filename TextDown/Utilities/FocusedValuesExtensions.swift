//
//  FocusedValuesExtensions.swift
//  TextDown
//
//  Shared utility extensions for SwiftUI FocusedValues
//

import SwiftUI

// MARK: - FocusedValues Extensions

extension FocusedValues {
    /// Binding to editor text for command coordination
    var editorText: Binding<String>? {
        get { self[EditorTextKey.self] }
        set { self[EditorTextKey.self] = newValue }
    }
}

private struct EditorTextKey: FocusedValueKey {
    typealias Value = Binding<String>
}
