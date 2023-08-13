//
//  ColorSet.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-13.
//

import Foundation
import SwiftUI

extension ColorScheme {
    
}

/// Every `ColorSet` must support all color schemes.
enum ColorSetVariantName: String {
    case light = "Light"
    case dark = "Dark"
    case trueDark = "True Dark"
}

enum ColorSetName: String {
    case mlemDefault = "Mlem (Default)"
//    For example:
//    case nyanCat = "Nyan Cat"
    
    func colorSet(for scheme: ColorScheme, appearanceTraits: AppearanceTraits) -> ColorSet {
        switch self {
        case .mlemDefault:
            return SystemColorSet().variant(for: scheme, appearanceTraits: appearanceTraits)
        }
    }
}

protocol ColorSetVariants {
    func variant(for scheme: ColorScheme, appearanceTraits: AppearanceTraits) -> ColorSet
}

struct SystemColorSet: ColorSetVariants {
    
    func variant(for scheme: ColorScheme, appearanceTraits: AppearanceTraits) -> ColorSet {
        switch scheme {
        case .light:
            return SystemLightColorSet()
        case .dark:
            return appearanceTraits.useTrueDark ? SystemTrueDarkColorSet() : SystemDarkColorSet()
        @unknown default:
            #if DEBUG
            fatalError("Unhandled color scheme.")
            #else
            return SystemLightColorSet()
            #endif
        }
    }
}

/// Defines a set of colors for use with its specified `ColorScheme`.
protocol ColorSet {
    
    // MARK: -
    /// User-facing name for this color scheme.
    var displayName: ColorSetVariantName { get }
    /// Color set is for use with this color scheme.
    var colorScheme: ColorScheme { get }
    
    // MARK: -
    var accentColor: Color { get }
    
    // MARK: -
    var systemBackground: Color { get }
    var secondarySystemBackground: Color { get }
    var tertiarySystemBackground: Color { get }
    
    // MARK: -
    var upvoteColor: Color { get }
    var downvoteColor: Color { get}
    var saveColor: Color { get }
}

struct SystemLightColorSet: ColorSet {
    
    var displayName: ColorSetVariantName = .light
    var colorScheme: ColorScheme = .light
    
    var accentColor: Color = .accentColor
    
    var systemBackground: Color = .systemBackground
    var secondarySystemBackground: Color = .secondarySystemBackground
    var tertiarySystemBackground: Color = .tertiarySystemBackground
    
    var upvoteColor: Color = .blue
    var downvoteColor: Color = .red
    var saveColor: Color = .green
}

struct SystemDarkColorSet: ColorSet {
    
    var displayName: ColorSetVariantName = .dark
    var colorScheme: ColorScheme = .dark
    
    var accentColor: Color = .accentColor
    
    var systemBackground: Color = .secondarySystemBackground
    var secondarySystemBackground: Color = .tertiarySystemBackground
    var tertiarySystemBackground: Color = .tertiarySystemBackground
    
    var upvoteColor: Color = .blue
    var downvoteColor: Color = .red
    var saveColor: Color = .green
}

/// Our interpretation of a "system" true dark color set.
struct SystemTrueDarkColorSet: ColorSet {
    
    var displayName: ColorSetVariantName = .trueDark
    var colorScheme: ColorScheme = .dark
    
    var accentColor: Color = .accentColor
    
    var systemBackground: Color = .systemBackground
    var secondarySystemBackground: Color = .secondarySystemBackground
    var tertiarySystemBackground: Color = .tertiarySystemBackground
    
    var upvoteColor: Color = .blue
    var downvoteColor: Color = .red
    var saveColor: Color = .green
}

// MARK: - more color sets...

// For Example:
// struct NyanCatColorSet: ColorSet { ... }
// struct ClassicAppleColorSet: ColorSet { ... }
