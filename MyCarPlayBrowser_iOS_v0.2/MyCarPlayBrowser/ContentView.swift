import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection = "home"
    @State private var browserURL: URL?
    @State private var showClear = false

    var body: some View {
        NavigationStack {
            Group {
                switch selection {
                case "favorites":
                    ListPage(
                        title: t("favorites", settings.language),
                        items: settings.favorites,
                        open: open
                    )
                case "history":
                    ListPage(
                        title: t("history", settings.language),
                        items: settings.history,
                        open: open
                    )
                case "settings":
                    SettingsView(showClear: $showClear)
                case "about":
                    AboutView()
                default:
                    HomeView(open: open)
                }
            }
            .navigationTitle(selection == "home" ? "MyCarPlayBrowser" : "")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        menuButton("home", "house")
                        menuButton("favorites", "star")
                        menuButton("history", "clock")
                        menuButton("settings", "gear")
                        menuButton("about", "info.circle")
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { browserURL != nil },
                    set: { presented in
                        if !presented {
                            browserURL = nil
                        }
                    }
                )
            ) {
                if let url = browserURL {
                    BrowserView(url: url)
                }
            }
            .alert(
                t("clear", settings.language),
                isPresented: $showClear
            ) {
                Button(t("cancel", settings.language), role: .cancel) {}
                Button(t("delete", settings.language), role: .destructive) {
                    clearAllWebData()
                }
            } message: {
                Text("WebKit cache, cookies and local website data will be removed.")
            }
        }
        .task {
            if settings.autoCarMode {
                settings.carMode = true
            }
        }
    }

    @ViewBuilder
    private func menuButton(_ key: String, _ icon: String) -> some View {
        Button {
            selection = key
        } label: {
            Label(t(key, settings.language), systemImage: icon)
        }
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }

        let item = HistoryItem(
            title: url.host ?? string,
            url: string
        )
