//
//  AppearanceTraits.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-12.
//

import SwiftUI

/// Appearance (`ColorScheme` or `UIUserInterfaceStyle`, depending on framework).
final class AppearanceTraits: ObservableObject {
    
    static let preferred: AppearanceTraits = .init()
    private init() { /* no-op */ }

    enum StorageKey: String, CaseIterable {
        // - TODO: Replace with `SwiftUI.ColorScheme`.
        case lightOrDarkMode
        case useTrueDark
    }
     
    // - TODO: Replace with `SwiftUI.ColorScheme`.
    @AppStorage(StorageKey.lightOrDarkMode.rawValue) var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    /// If `false`, `.dark` appeareance is rendered with more contrasting colors.
    /// - NOTE: True Dark appearance is a color variant of `ColorScheme.dark`.
    @AppStorage(StorageKey.useTrueDark.rawValue) var useTrueDark: Bool = true
}
