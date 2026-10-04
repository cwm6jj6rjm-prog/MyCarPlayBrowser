import SwiftUI
import WebKit
import Foundation
import UIKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection = "home"
    @State private var browserURL: URL?
    @State private var searchText = ""

    private var services: [Service] {
        Services.all
    }

    private var filteredServices: [Service] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return services }
        return services.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView(
                services: filteredServices,
                searchText: $searchText,
                open: open,
                isFavorite: isFavorite,
                toggleFavorite: toggleFavorite
            )
            .tabItem {
                Label(t("home", settings.language), systemImage: "house.fill")
            }
            .tag("home")

            ListPage(
                title: t("favorites", settings.language),
                items: settings.favorites,
                open: open
            )
            .tabItem {
                Label(t("favorites", settings.language), systemImage: "star.fill")
            }
            .tag("favorites")

            ListPage(
                title: t("history", settings.language),
                items: settings.history,
                open: open
            )
            .tabItem {
                Label(t("history", settings.language), systemImage: "clock.fill")
            }
            .tag("history")

            BrowserStartView(open: open)
                .tabItem {
                    Label(t("browser", settings.language), systemImage: "safari.fill")
                }
                .tag("browser")

            SettingsView()
                .tabItem {
                    Label(t("settings", settings.language), systemImage: "gearshape.fill")
                }
                .tag("settings")
        }
        .tint(Color(red: 0.08, green: 0.48, blue: 1.0))
        .sheet(
            isPresented: Binding(
                get: { browserURL != nil },
                set: { if !$0 { browserURL = nil } }
            )
        ) {
            if let url = browserURL {
                BrowserView(url: url)
            }
        }
        .preferredColorScheme(settings.theme == .dark ? .dark : .light)
    }

    private func open(_ string: String) {
        var value = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        if !value.lowercased().hasPrefix("http://") &&
            !value.lowercased().hasPrefix("https://") {
            value = "https://" + value
        }

        guard let url = URL(string: value) else { return }

        let item = HistoryItem(
            title: url.host ?? value,
