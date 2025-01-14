//
//  CommunityListRowViews.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import Dependencies
import SwiftUI

struct FavoriteStarButtonStyle: ButtonStyle {
    let isFavorited: Bool

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: isFavorited ? Icons.favoriteFill : Icons.favorite)
            .foregroundColor(.blue)
            .opacity(isFavorited ? 1.0 : 0.2)
            .accessibilityRepresentation { configuration.label }
    }
}

struct CommuntiyFeedRowView: View {
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void
    let navigationContext: NavigationContext
    
    var body: some View {
        NavigationLink(value: pathValue) {
            HStack {
                // NavigationLink with invisible array
                communityNameLabel

                Spacer()
                Button("Favorite Community") {
                    hapticManager.play(haptic: .success, priority: .high)

                    toggleFavorite()

                }.buttonStyle(FavoriteStarButtonStyle(isFavorited: isFavorited()))
                    .accessibilityHidden(true)
            }
        }.swipeActions {
            if subscribed {
                Button("Unsubscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: false)
                    }
                }.tint(.red) // Destructive role seems to remove from list so just make it red
            } else {
                Button("Subscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: true)
                    }
                }.tint(.blue)
            }
        }
        .accessibilityAction(named: "Toggle favorite") {
            toggleFavorite()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(communityLabel)
    }

    private var pathValue: AnyHashable {
        if navigationContext == .sidebar {
            return CommunityLinkWithContext(community: CommunityModel(from: community), feedType: .subscribed)
        } else {
            // Do not use enum route path in sidebar: It doesn't work, and I have no idea why =/ [2023.09]
            return AppRoute.communityLinkWithContext(.init(community: CommunityModel(from: community), feedType: .subscribed))
        }
    }
    
    private var communityNameText: Text {
        Text(community.name)
    }

    @ViewBuilder
    private var communityNameLabel: some View {
        if let website = community.actorId.host(percentEncoded: false) {
            communityNameText +
                Text("@\(website)")
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.5))
        } else {
            communityNameText
        }
    }

    private var communityLabel: String {
        var label = community.name

        if let website = community.actorId.host(percentEncoded: false) {
            label += "@\(website)"
        }

        if isFavorited() {
            label += ", is a favorite"
        }

        return label
    }

    private func toggleFavorite() {
        if isFavorited() {
            favoriteCommunitiesTracker.unfavorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Unfavorited \(community.name)")
            Task {
                await notifier.add(.success("Unfavorited \(community.name)"))
            }
        } else {
            favoriteCommunitiesTracker.favorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Favorited \(community.name)")
            Task {
                await notifier.add(.success("Favorited \(community.name)"))
            }
        }
    }

    private func isFavorited() -> Bool {
        favoriteCommunitiesTracker.isFavorited(community)
    }

    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        communitySubscriptionChanged(community, shouldSubscribe)
    }
}

struct HomepageFeedRowView: View {
    let feedType: FeedType
    let iconName: String
    let iconColor: Color
    let description: String
    let navigationContext: NavigationContext

    var body: some View {
        NavigationLink(value: pathValue) {
            HStack {
                Image(systemName: iconName).resizable()
                    .frame(width: 36, height: 36).foregroundColor(iconColor)
                VStack(alignment: .leading) {
                    Text("\(feedType.label) Communities")
                    Text(description).font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 1)
            .accessibilityElement(children: .combine)
        }
    }
    
    private var pathValue: AnyHashable {
        if navigationContext == .sidebar {
            return CommunityLinkWithContext(community: nil, feedType: feedType)
        } else {
            // Do not use enum route path in sidebar: It doesn't work, and I have no idea why =/ [2023.09]
            return AppRoute.communityLinkWithContext(.init(community: nil, feedType: feedType))
        }
    }
}
