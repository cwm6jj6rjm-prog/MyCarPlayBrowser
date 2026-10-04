import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection = "home"
    @State private var browserURL: URL?
    @State private var searchText = ""

    private var services: [Service] { Services.all }

    private var filteredServices: [Service] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return services
        }
        return services.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
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
        .preferredColorScheme(
            settings.theme == .dark ? .dark : .light
        )
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }

        let item = HistoryItem(
            title: url.host ?? string,
            url: string
        )

        settings.history.removeAll { $0.url == string }
        settings.history.insert(item, at: 0)
        settings.history = Array(settings.history.prefix(100))

        browserURL = url
    }
