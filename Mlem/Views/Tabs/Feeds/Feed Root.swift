//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

final class NavDelegate: NSObject, UINavigationControllerDelegate, ObservableObject {
    
    private(set) var navigationController: UINavigationController?
    private(set) var poppedViewController: UIViewController?
    
    init(navigationController: UINavigationController? = nil, poppedViewController: UIViewController? = nil) {
        self.navigationController = navigationController
        self.poppedViewController = poppedViewController
    }
    
    func goForward() -> UIViewController? {
        let pop = poppedViewController
        poppedViewController = nil
        return pop
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        self.navigationController = navigationController
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.navigationController = navigationController
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
//        self.navigationController = navigationController
        
        if operation == .pop {
            poppedViewController = fromVC
        }
        
        return nil
    }
}

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot

    @State var navigationPath = NavigationPath()

    @State var rootDetails: CommunityLinkWithContext?
    
    let showLoading: Bool
    
    @EnvironmentObject var navDel: NavDelegate
    
    var body: some View {
        NavigationSplitView {
            CommunityListView(selectedCommunity: $rootDetails)
                .id(appState.currentActiveAccount.id)
        } detail: {
            if let rootDetails {
                NavigationStack(path: $navigationPath) {
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
                    }
                }
                .id(rootDetails.id + appState.currentActiveAccount.id)
                .introspect(.navigationStack, on: .iOS(.v16), scope: .ancestor) { view in
                    view.delegate = navDel
                }
            } else {
                Text("Please select a community") 
            }
        }
        .handleLemmyLinkResolution(
            navigationPath: $navigationPath
        )
        .environment(\.navigationPath, $navigationPath)
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
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.feeds.hashValue {
                print("re-selected \(TabSelection.feeds) tab")
//                if let goForward = navDel.goForward() {
//                    navDel.navigationController?.pushViewController(goForward, animated: true)
//                }
            }
        }
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot(showLoading: false)
    }
}
