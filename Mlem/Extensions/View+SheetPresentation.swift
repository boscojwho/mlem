//
//  View+SheetPresentation.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-04.
//

import SwiftUI

struct PresentationSheetContext {
    var selectedDetent: PresentationDetent
    var interactiveDismissDisabled: Bool
}

extension PresentationDetent {
    
    static let small: Self = .fraction(0.20)
    
    /// When sheet height is smallest allowed (e.g. see `Mail.app` when draft message is position below toolbar).
    /// **Design Considerations**:
    /// - User interaction should be disabled on subviews.
    /// - Consider either disabling tinting or hiding subviews.
    static let minimized: Self = .height(60)
}

extension View {
    
    /// - Supported versions: `iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *`. No-op on older versions.
    @ViewBuilder
    func _presentationBackgroundInteraction(enabledUpThrough detent: PresentationDetent) -> some View {
        if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
            self.presentationBackgroundInteraction(.enabled(upThrough: detent))
        } else {
            self
        }
    }
}
