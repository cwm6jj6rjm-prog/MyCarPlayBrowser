import SwiftUI
import WebKit
import Foundation
import UIKit

struct ContentView: View {
    private let settings = AppSettings.shared
    @State private var selection = "home"
    @State private var searchText = ""
    @State private var showAddCard = false
    @State private var showSettings = false
    @State private var browserURL: URL?

    private var currentServices: [Service] {
        let ids = settings.cards
        if ids.isEmpty {
            return Array(Services.all.prefix(9))
        }

        let ordered = ids.compactMap { id in Services.all.first(where: { $0.id == id }) }
        let missing = Services.all.filter { !ids.contains($0.id) }
        return ordered + missing
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: UIColor(red: 0.035, green: 0.045, blue: 0.060, alpha: 1))
                    .ignoresSafeArea()

                if selection == "home" {
                    HomePage(
                        services: currentServices,
                        searchText: $searchText,
                        onOpen: open,
                        onAdd: { showAddCard = true },
                        onSettings: { showSettings = true }
                    )
                } else if selection == "favorites" {
                    FavoritesPage(onOpen: open)
                } else if selection == "history" {
                    HistoryPage(onOpen: open)
                } else if selection == "bookmarks" {
                    FavoritesPage(onOpen: open)
                } else if selection == "settings" {
                    SettingsPage()
                } else {
                    AboutPage()
                }

                if let url = browserURL {
                    Color.black.ignoresSafeArea()
                    BrowserView(url: url) {
                        browserURL = nil
                    }
                }
            }
            .sheet(isPresented: $showAddCard) {
                AddCardSheet(existingIDs: settings.cards) { service in
                    addCard(service)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsPage()
                    .presentationDetents([.large])
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func open(_ service: Service) {
        guard let url = URL(string: service.url) else { return }
        settings.history.insert(HistoryItem(title: service.name, url: service.url), at: 0)
        if settings.history.count > 50 {
            settings.history.removeLast()
        }
        browserURL = url
    }

    private func addCard(_ service: Service) {
        if settings.cards.isEmpty {
            settings.cards = Array(Services.all.prefix(9).map(\.id))
        }
        if !settings.cards.contains(service.id) {
            settings.cards.append(service.id)
        }
    }
}

struct HomePage: View {
    let services: [Service]
    @Binding var searchText: String
    let onOpen: (Service) -> Void
    let onAdd: () -> Void
    let onSettings: () -> Void
