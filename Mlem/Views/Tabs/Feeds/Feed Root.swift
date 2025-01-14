//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import Dependencies
import SwiftUI

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @StateObject private var feedTabNavigation: AnyNavigationPath<AppRoute> = .init()

    @State var rootDetails: CommunityLinkWithContext?

    var body: some View {
        NavigationSplitView {
            CommunityListView(selectedCommunity: $rootDetails)
        } detail: {
            if let rootDetails {
                NavigationStack(path: $feedTabNavigation.path) {
                    FeedView(
                        community: rootDetails.community,
                        feedType: rootDetails.feedType
                    )
                    .environmentObject(appState)
                    .handleLemmyViews()
                }
                .id(rootDetails.id)
            } else {
                Text("Please select a community")
            }
        }
        .handleLemmyLinkResolution(
            navigationPath: .constant(feedTabNavigation)
        )
        .environmentObject(feedTabNavigation)
        .environmentObject(appState)
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
                
                _ = HandleLemmyLinkResolution(navigationPath: .constant(feedTabNavigation))
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
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot()
    }
}
