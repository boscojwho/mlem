//
//  AppearanceTraits.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-12.
//

import SwiftUI

final class AppearanceTraits: ObservableObject {
    
    static let preferred: AppearanceTraits = .init()
    private init() { /* no-op */ }

    enum StorageKey: String, CaseIterable {
        case lightOrDarkMode
    }
     
    // - TODO: Replace with `SwiftUI.ColorScheme`.
    @AppStorage(StorageKey.lightOrDarkMode.rawValue) var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
}
