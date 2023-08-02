//
//  UltraCompactPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-04.
//

import Foundation
import SwiftUI

struct UltraCompactPost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("thumbnailsOnRight") var thumbnailsOnRight: Bool = false
    @AppStorage("showDownvotesSeparately") var showDownvotesSeparately: Bool = false

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // arguments
    let postView: APIPostView
    let showCommunity: Bool // true to show community name, false to show username
    let menuFunctions: [MenuFunction]
    
    // computed
    let voteColor: Color
    let voteIconName: String

    init(postView: APIPostView, showCommunity: Bool, menuFunctions: [MenuFunction]) {
        self.postView = postView
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
        
        switch postView.myVote {
        case .upvote:
            voteIconName = "arrow.up"
            voteColor = .upvoteColor
        case .downvote:
            voteIconName = "arrow.down"
            voteColor = .downvoteColor
        default:
            voteIconName = "arrow.up"
            voteColor = .secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
            if shouldShowPostThumbnails && !thumbnailsOnRight {
                ThumbnailImageView(postView: postView)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    Group {
                        if showCommunity {
                            CommunityLinkView(community: postView.community, serverInstanceLocation: .trailing, overrideShowAvatar: false)
                        } else {
                            UserProfileLink(user: postView.creator,
                                            serverInstanceLocation: .trailing,
                                            postContext: postView.post)
                        }
                    }
                    
                    Spacer()
                    
                    EllipsisMenu(size: 12, menuFunctions: menuFunctions)
                        .padding(.trailing, 6)
                }
                .padding(.bottom, -2)
                
                Text(postView.post.name)
                    .font(.subheadline)
    
                compactInfo
            }
            
            if shouldShowPostThumbnails && thumbnailsOnRight {
                ThumbnailImageView(postView: postView)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.postAndCommentSpacing)
    }
    
    @ViewBuilder
    private var compactInfo: some View {
        HStack(spacing: 8) {
            if postView.post.featuredCommunity {
                if postView.post.featuredLocal {
                    StickiedTag(tagType: .local, compact: true)
                } else if postView.post.featuredCommunity {
                    StickiedTag(tagType: .community, compact: true)
                }
            }
            
            if postView.post.nsfw || postView.community.nsfw {
                NSFWTag(compact: true)
            }
            
            InfoStack(votes: DetailedVotes(score: postView.counts.score,
                                           upvotes: postView.counts.upvotes,
                                           downvotes: postView.counts.downvotes,
                                           myVote: postView.myVote ?? .resetVote,
                                           showDownvotes: showDownvotesSeparately),
                      published: postView.published,
                      commentCount: postView.counts.comments,
                      saved: postView.saved)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
