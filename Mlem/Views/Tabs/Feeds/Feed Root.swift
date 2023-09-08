//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

final class NavigateDismissAction: ObservableObject {
    var dismiss: DismissAction?
    var context: String?
}

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot

    @StateObject private var dismissAction: NavigateDismissAction = .init()
    @State private var customNavigationPath: [MlemRoutes] = []
    @State var navigationPath = NavigationPath()
    @State var rootDetails: CommunityLinkWithContext?

#if DEBUG
    @State private var isPresentingNavigationDebugSheet: Bool = false
#endif
    
    let showLoading: Bool
    
    var body: some View {
        NavigationSplitView {
            CommunityListView(selectedCommunity: $rootDetails)
                .id(appState.currentActiveAccount.id)
        } detail: {
            // Could this condtional navigation stack be causing issues with navigation path state?
//            if let rootDetails {
                NavigationStack(path: $customNavigationPath) {
                    if let rootDetails {
                        ScrollViewReader { proxy in
                            FeedView(
                                community: rootDetails.community,
                                feedType: rootDetails.feedType,
                                sortType: defaultPostSorting,
                                showLoading: showLoading,
                                rootDetails: $rootDetails
                            )
                            .environmentObject(appState)
                            .environment(\.tabScrollViewProxy, proxy)
                            .handleLemmyViews()
                            .id(rootDetails.id + appState.currentActiveAccount.id)
                        }
                    } else {
                        Text("Please select a community")
                    }
                }
//            } else {
//                Text("Please select a community")
//            }
        }
        .handleLemmyLinkResolution(
            navigationPath: $navigationPath
        )
        .environment(\.navigationPath, $navigationPath)
        .environment(\.customNavigationPath, $customNavigationPath)
        .environmentObject(dismissAction)
        .environmentObject(appState)
        .environmentObject(accountsTracker)
        .onAppear {
            if rootDetails == nil || shortcutItemToProcess != nil {
                let feedType = FeedType(rawValue:
                    shortcutItemToProcess?.type ??
                    "nothing to see here"
                ) ?? defaultFeed
                rootDetails = CommunityLinkWithContext(community: nil, feedType: feedType)
                shortcutItemToProcess = nil
            }
        }
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if rootDetails == nil {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
                
                _ = HandleLemmyLinkResolution(appState: _appState,
                                          navigationPath: $navigationPath
                )
                .didReceiveURL(url)
            }
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .active {
                if let shortcutItem = FeedType(rawValue:
                                                shortcutItemToProcess?.type ??
                                               "nothing to see here"
                   ) {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: shortcutItem)

                    shortcutItemToProcess = nil
                }
            }
        }
#if DEBUG
        .overlay(alignment: .trailing) {
            GroupBox {
                Text("NavigationPath.count: \(customNavigationPath.count)")
            }
            //            .onTapGesture {
            //                isPresentingNavigationDebugSheet = true
            //            }
        }
        //        .sheet(isPresented: $isPresentingNavigationDebugSheet) {
        //            List {
        //                Text(dismissAction.context ?? "No debug context")
        //            }
        //        }
#endif
//        .onChange(of: selectedTagHashValue) { newValue in
//            if newValue == TabSelection.feeds.hashValue {
//                print("switched to Feed tab")
//            }
//        }
//        .onChange(of: selectedNavigationTabHashValue) { newValue in
//            if newValue == TabSelection.feeds.hashValue {
//                print("re-selected \(TabSelection.feeds) tab")
//            }
//        }
        // swiftlint:disable line_length
#warning("Watch out where sheets are presented: If a sheet is presented but is owned by a view that isn't the top view in a navigation stack, it may cause issues with user interaction because the system may think the view that presented that sheet is now the top view (onAppear will get called on that view).")
        // swiftlint:enable line_length
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot(showLoading: false)
    }
}
