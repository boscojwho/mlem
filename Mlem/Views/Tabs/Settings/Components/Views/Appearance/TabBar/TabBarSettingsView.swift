//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import SwiftUI

struct TabBarSettingsView: View {
    
    @EnvironmentObject private var tabBarTraits: TabBarTraits
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedAccountTracker: SavedAccountTracker
    
    @State var textFieldEntry: String = ""
        
    var body: some View {
        Form {
            Section {
                SelectableSettingsItem(settingIconSystemName: "person.text.rectangle",
                                       settingName: "Profile Tab Label",
                                       currentValue: $tabBarTraits.profileTabLabel,
                                       options: ProfileTabLabel.allCases)
                
                if tabBarTraits.profileTabLabel == .nickname {
                    Label {
                        TextField(text: $textFieldEntry, prompt: Text(appState.currentNickname)) {
                            Text("Nickname")
                        }
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            print(textFieldEntry)
                            let newAccount = SavedAccount(from: appState.currentActiveAccount, storedNickname: textFieldEntry)
                            appState.changeDisplayedNickname(to: textFieldEntry)
                            savedAccountTracker.replaceAccount(account: newAccount)
                        }
                    } icon: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .foregroundColor(.pink)
                    }
                }
            }
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: "tag",
                                       settingName: "Show Tab Labels",
                                       isTicked: $tabBarTraits.showTabNames)
                
                SwitchableSettingsItem(settingPictureSystemName: "envelope.badge",
                                       settingName: "Show Unread Count",
                                       isTicked: $tabBarTraits.showInboxUnreadBadge)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Tab Bar")
        .navigationBarColor()
        .animation(.easeIn, value: tabBarTraits.profileTabLabel)
        .onChange(of: appState.currentActiveAccount.nickname) { nickname in
            print("new nickname: \(nickname)")
            textFieldEntry = nickname // appState.currentActiveAccount.nickname
        }
    }
}
