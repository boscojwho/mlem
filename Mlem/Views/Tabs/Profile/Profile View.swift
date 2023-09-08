//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import SwiftUI

// Profile tab view
struct ProfileView: View {
    // appstorage
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    let userID: Int
    
    // environment
    @EnvironmentObject var appState: AppState
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @State private var customNavigationPath: [MlemRoutes] = []
    @State private var navigationPath = NavigationPath()
    @StateObject private var dismissAction: NavigateDismissAction = .init()
    @State private var scrollToTopAppeared: Bool = true
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $customNavigationPath) {
                UserView(userID: userID)
                    .handleLemmyViews()
                    .environment(\.tabScrollViewProxy, proxy)
                    .environment(\.navigationPath, $navigationPath)
            }
            .tabBarNavigationEnabled(
                .profile,
                scrollToTopAppeared: $scrollToTopAppeared,
                popToSidebar: {
                    // not applicable.
                },
                scrollToTop: {
                    // todo
                },
                goBack: {
                    dismissAction.dismiss?()
                }
            )
        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.profile.hashValue {
                print("switched to Profile tab")
            }
        }
//        .onChange(of: selectedNavigationTabHashValue) { newValue in
//            if newValue == TabSelection.profile.hashValue {
//                print("re-selected \(TabSelection.profile) tab")
//            }
//        }
        .environmentObject(dismissAction)
        .environment(\.customNavigationPath, $customNavigationPath)
#if DEBUG
        .overlay(alignment: .trailing) {
            GroupBox {
                Text("NavigationPath.count: \(customNavigationPath.count)")
            }
        }
#endif
    }
}
