//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

enum SettingsNavigationRoute: Hashable, Codable {
    case accountsPage(onboarding: Bool)
    case general
    case accessibility
    case appearance
    case contentFilters
    case about
    case advanced
}

struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @State var navigationPath = NavigationPath()

    @Environment(\.openURL) private var openURL
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    NavigationLink(value: SettingsNavigationRoute.accountsPage(onboarding: false)) {
                        Label("Accounts", systemImage: "person.fill").labelStyle(SquircleLabelStyle(color: .teal))
                    }
                }
                Section {
                    NavigationLink(value: SettingsNavigationRoute.general) {
                        Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                    }
                    
                    NavigationLink(value: SettingsNavigationRoute.accessibility) {
                        // apparently the Apple a11y symbol isn't an SFSymbol
                        Label("Accessibility", systemImage: "hand.point.up.braille.fill").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                    
                    NavigationLink(value: SettingsNavigationRoute.appearance) {
                        Label("Appearance", systemImage: "paintbrush.fill").labelStyle(SquircleLabelStyle(color: .pink))
                    }

                    NavigationLink(value: SettingsNavigationRoute.contentFilters) {
                        Label("Content Filters", systemImage: "line.3.horizontal.decrease").labelStyle(SquircleLabelStyle(color: .orange))
                    }
                }
                
                Section {
                    NavigationLink(value: SettingsNavigationRoute.about) {
                        Label("About Mlem", systemImage: "info").labelStyle(SquircleLabelStyle(color: .blue))
                    }
                }
                
                Section {
                    NavigationLink(value: SettingsNavigationRoute.advanced) {
                        Label("Advanced", systemImage: "gearshape.2.fill").labelStyle(SquircleLabelStyle(color: .gray))
                    }
                }
            }
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarColor()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsNavigationRoute.self) { route in
                switch route {
                case .accountsPage(let onboarding):
                    AccountsPage(onboarding: onboarding)
                case .general:
                    GeneralSettingsView()
                case .accessibility:
                    AccessibilitySettingsView()
                case .appearance:
                    AppearanceSettingsView()
                case .contentFilters:
                    FiltersSettingsView()
                case .about:
                    AboutView(navigationPath: $navigationPath)
                case .advanced:
                    AdvancedSettingsView()
                }
            }
            .navigationDestination(for: AppearanceSettingsNavigationRoute.self) { route in
                switch route {
                case .theme:
                    ThemeSettingsView()
                case .appIcon:
                    IconSettingsView()
                case .posts:
                    PostSettingsView()
                case .comments:
                    CommentSettingsView()
                case .communities:
                    CommunitySettingsView()
                case .users:
                    UserSettingsView()
                case .tabBar:
                    TabBarSettingsView()
                }
            }
            .navigationDestination(for: CommentSettingsNavigationRoute.self) { route in
                switch route {
                case .layoutWidget:
                    LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.comment, onSave: { widgets in
                        layoutWidgetTracker.groups.comment = widgets
                        layoutWidgetTracker.saveLayoutWidgets()
                    })
                }
            }
            .navigationDestination(for: PostSettingsNavigationRoute.self) { route in
                switch route {
                case .customizeWidgets:
                    /// We really should be passing in the layout widget through the route enum value, but that would involve making layout widget tracker hashable and codable.
                    LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.post, onSave: { widgets in
                        layoutWidgetTracker.groups.post = widgets
                        layoutWidgetTracker.saveLayoutWidgets()
                    })
                }
            }
        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.settings.hashValue {
                print("switched to Settings tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.settings.hashValue {
                print("re-selected \(TabSelection.settings) tab")
                
            }
        }
    }
}
