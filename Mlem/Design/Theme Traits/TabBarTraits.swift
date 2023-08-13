//
//  TabBarTraits.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-13.
//

import SwiftUI

final class TabBarTraits: ObservableObject {
    
    static let preferred: TabBarTraits = .init()
    private init() { /* no-op */ }
    
    enum StorageKey: String, CaseIterable {
        case profileTabLabel
        case showTabNames
        case showInboxUnreadBadge
    }
    
    @AppStorage(StorageKey.profileTabLabel.rawValue) var profileTabLabel: ProfileTabLabel = .username
    @AppStorage(StorageKey.showTabNames.rawValue) var showTabNames: Bool = true
    @AppStorage(StorageKey.showInboxUnreadBadge.rawValue) var showInboxUnreadBadge: Bool = true
}
