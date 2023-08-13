//
//  ColorSetTraits.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-13.
//

import SwiftUI

final class ColorSetTraits: ObservableObject {
        
    static let preferred: ColorSetTraits = .init()
    init() { /* no-op */ }
    
    static let allColorSets: [ColorSet] = [
        SystemDarkColorSet(),
        SystemLightColorSet(),
        SystemTrueDarkColorSet()
    ]
    
    enum StorageKey: String, CaseIterable {
        case useColorSetWithName
    }
    
    @AppStorage(StorageKey.useColorSetWithName.rawValue) var useColorSetWithName: ColorSetName = .mlemDefault
    
    func currentColorSet(for colorScheme: ColorScheme, appearanceTraits: AppearanceTraits) -> ColorSet {
        useColorSetWithName.colorSet(for: colorScheme, appearanceTraits: appearanceTraits)
    }
}
