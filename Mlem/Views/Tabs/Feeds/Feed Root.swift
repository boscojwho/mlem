//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot

    @State var navigationPath = NavigationPath()
    @State private var customNavigationPath: [MlemRoutes] = []
    @State private var goBackFlag: Int = 0

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
            if let rootDetails {
                ScrollViewReader { proxy in
                    NavigationStack(path: $customNavigationPath) {
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
                    }
                }
                .id(rootDetails.id + appState.currentActiveAccount.id)
            } else {
                Text("Please select a community") 
            }
        }
        .handleLemmyLinkResolution(
            navigationPath: $navigationPath
        )
        .environment(\.navigationPath, $navigationPath)
        .environment(\.customNavigationPath, $customNavigationPath)
        .environment(\.navigationGoBack, $goBackFlag)
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
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.feeds.hashValue {
                print("switched to Feed tab")
            }
        }
        .onChange(of: goBackFlag, perform: { value in
            print("navigate go back flag == \(value)")
//            if value >= 1 {
//                goBackFlag = 0
//                if let path = customNavigationPath.popLast() {
//                    print(String(describing: path).prefix(50))
//                }
//            }
            if value >= 1 {
                goBackFlag = 0
            } else if value == 0 {
                if let path = customNavigationPath.popLast() {
                    print(String(describing: path).prefix(50))
                    print("* * *")
                }
            } else {
                print("undefined behaviour")
            }
        })
//        .onChange(of: selectedNavigationTabHashValue) { newValue in
//            if newValue == TabSelection.feeds.hashValue {
//                print("re-selected \(TabSelection.feeds) tab")
//            }
//        }
#if DEBUG
        .overlay(alignment: .trailing) {
            GroupBox {
                Text("NavigationPath.count: \(customNavigationPath.count)")
            }
            .onTapGesture {
                isPresentingNavigationDebugSheet = true
            }
        }
        .sheet(isPresented: $isPresentingNavigationDebugSheet) {
            List {
                ForEach(customNavigationPath, id: \.self.hashValue) { route in
                    Text(route.description + " \(route.hashValue)")
                }
            }
        }
#endif
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot(showLoading: false)
    }
}
