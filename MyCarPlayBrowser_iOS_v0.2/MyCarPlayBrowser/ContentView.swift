import SwiftUI
import WebKit
import Foundation
import UIKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection: String = "home"
    @State private var searchText: String = ""
    @State private var browserURL: URL?
    @State private var showAddCard: Bool = false

    private var visibleServices: [Service] {
        if settings.cards.isEmpty {
            return Array(Services.all.prefix(9))
        }

        var result: [Service] = []
        for id in settings.cards {
            if let service = Services.all.first(where: { $0.id == id }) {
                result.append(service)
            }
        }
        return result
    }

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.045, blue: 0.060)
                .ignoresSafeArea()

            if selection == "home" {
                HomeView(
                    services: visibleServices,
                    searchText: $searchText,
                    onOpen: openService,
                    onAdd: { showAddCard = true },
                    onSelect: { selection = $0 }
                )
            } else if selection == "favorites" {
                SimplePage(title: "Kedvencek", icon: "star.fill")
            } else if selection == "history" {
                HistoryView(items: settings.history, onOpen: openURL)
            } else if selection == "bookmarks" {
                SimplePage(title: "Könyvjelzők", icon: "bookmark.fill")
            } else if selection == "settings" {
                SettingsView()
            } else {
                SimplePage(title: "Névjegy", icon: "info.circle")
            }

            if let url = browserURL {
                BrowserView(url: url) {
                    browserURL = nil
                }
            }
        }
        .sheet(isPresented: $showAddCard) {
            AddCardView(existing: settings.cards) { service in
                addService(service)
            }
        }
    }

    private func openService(_ service: Service) {
        openURL(service.url)
    }

    private func openURL(_ value: String) {
        var text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.lowercased().hasPrefix("http://") &&
            !text.lowercased().hasPrefix("https://") {
            text = "https://" + text
        }

        guard let url = URL(string: text) else { return }
        let item = HistoryItem(title: url.host ?? text, url: text)
        settings.history.removeAll { $0.url == text }
        settings.history.insert(item, at: 0)
        if settings.history.count > 100 {
            settings.history = Array(settings.history.prefix(100))
        }
        browserURL = url
    }

    private func addService(_ service: Service) {
        if settings.cards.isEmpty {
            settings.cards = Services.all.prefix(9).map { $0.id }
        }

        if !settings.cards.contains(service.id) {
            settings.cards.append(service.id)
        }
    }
}

struct HomeView: View {
    let services: [Service]
    @Binding var searchText: String
    let onOpen: (Service) -> Void
    let onAdd: () -> Void
    let onSelect: (String) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filtered: [Service] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return services
        }
        return services.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                SideMenu(selection: onSelect)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HeroView()

                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 7, height: 7)
                                Text("Online")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(Date(), style: .time)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        HStack {
                            Text("Gyorselérés")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)

                            Spacer()

                            Button(action: onAdd) {
                                Label("Kártya hozzáadása", systemImage: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .buttonStyle(.bordered)
                            .tint(.white)
                        }

                        HStack(spacing: 9) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)

                            TextField("Keresés", text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(11)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text("Húzd a kártyákat a rendezéshez")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filtered) { service in
                                ServiceCard(service: service) {
                                    onOpen(service)
                                }
                            }
                        }

                        Text("A kártyák beállításai az alkalmazásban automatikusan mentésre kerülnek.")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct SideMenu: View {
    let selection: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                    Text("M")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.75))
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 0) {
                    Text("MyCarPlay")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                    Text("BÖNGÉSZŐ")
                        .font(.system(size: 7, weight: .medium))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 15)

            MenuButton(title: "Kezdőlap", icon: "house.fill") {
                selection("home")
            }

            MenuButton(title: "Kedvencek", icon: "star.fill") {
                selection("favorites")
            }

            MenuButton(title: "Előzmények", icon: "clock.fill") {
                selection("history")
            }

            MenuButton(title: "Könyvjelzők", icon: "bookmark.fill") {
                selection("bookmarks")
            }

            Divider()
                .overlay(Color.white.opacity(0.08))
                .padding(.vertical, 10)

            MenuButton(title: "Beállítások", icon: "gearshape.fill") {
                selection("settings")
            }

            MenuButton(title: "Névjegy", icon: "info.circle.fill") {
                selection("about")
            }

            Spacer()
        }
        .padding(.horizontal, 13)
        .padding(.top, 20)
        .frame(width: 170)
        .background(Color(red: 0.055, green: 0.065, blue: 0.082))
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

struct HeroView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("A TE BÖNGÉSZŐ • A TE SZOLGÁLTATÁSAID")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                Text("Minden, amit nézel.\nEgyetlen helyen.")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Nyisd meg kedvenc streaming szolgáltatásaidat és weboldalaidat közvetlenül a MyCarPlayBrowserben.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))

                Text("M")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.black.opacity(0.72))
            }
            .frame(width: 90, height: 90)
        }
        .padding(20)
        .frame(minHeight: 155)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.075, green: 0.09, blue: 0.13),
                    Color(red: 0.12, green: 0.15, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 17))
        .overlay(
            RoundedRectangle(cornerRadius: 17)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }
}

struct ServiceCard: View {
    let service: Service
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBackground)
                    Text(service.icon)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(serviceDescription)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 82)
            .background(Color(red: 0.075, green: 0.09, blue: 0.115))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var serviceDescription: String {
        switch service.id {
        case "youtube": return "Videók és élő adások"
        case "netflix": return "Filmek és sorozatok"
        case "disney": return "Filmek és saját tartalmak"
        case "apple": return "Apple saját tartalmak"
        case "prime": return "Filmek és sorozatok"
        case "google": return "Webes keresés"
        case "browser": return "Böngészés az interneten"
        case "spotify": return "Zene és podcastok"
        case "tiktok": return "Rövid videók"
        default: return "Webszolgáltatás"
        }
    }

    private var iconBackground: Color {
        switch service.id {
        case "youtube", "netflix":
            return Color.red.opacity(0.13)
        case "spotify":
            return Color.green.opacity(0.13)
        case "disney":
            return Color.blue.opacity(0.13)
        default:
            return Color.white.opacity(0.07)
        }
    }
}

struct AddCardView: View {
    let existing: [String]
    let onAdd: (Service) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search: String = ""

    private var available: [Service] {
        Services.all.filter { service in
            if existing.contains(service.id) {
                return false
            }
            if search.isEmpty {
                return true
            }
            return service.name.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List(available) { service in
                Button {
                    onAdd(service)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(service.icon)
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 9))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(service.name)
                                .font(.system(size: 15, weight: .bold))
                            Text(service.url)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 21))
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Kártya hozzáadása")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Szolgáltatás keresése")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kész") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct HistoryView: View {
    let items: [HistoryItem]
    let onOpen: (String) -> Void

    var body: some View {
        NavigationStack {
            List(items) { item in
                Button {
                    onOpen(item.url)
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                        Text(item.url)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Előzmények")
        }
    }
}

struct SimplePage: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundStyle(.white.opacity(0.8))

            Text(title)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Megjelenés") {
                    Picker("Téma", selection: $settings.theme) {
                        Text("Sötét").tag(AppTheme.dark)
                        Text("Világos").tag(AppTheme.light)
                    }

                    Picker("Nyelv", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.title).tag(language)
                        }
                    }
                }

                Section("Indítás") {
                    Picker("Indulási oldal", selection: $settings.startup) {
                        Text("Kezdőlap").tag("home")
                        ForEach(Services.all) { service in
                            Text(service.name).tag(service.id)
                        }
                    }

                    Toggle("Autó mód", isOn: $settings.carMode)
                    Toggle("Automatikus autó mód", isOn: $settings.autoCarMode)
                }

                Section("Böngésző") {
                    Button("Böngészési adatok törlése", role: .destructive) {
                        Task {
                            await WKWebsiteDataStore.default().removeData(
                                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                modifiedSince: .distantPast
                            )
                        }
                    }
                }

                Section("Névjegy") {
                    LabeledContent("Alkalmazás", value: "MyCarPlayBrowser")
                    LabeledContent("Verzió", value: "0.3")
                }
            }
            .navigationTitle("Beállítások")
        }
    }
}

struct BrowserView: View {
    let url: URL
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            WebViewContainer(url: url)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .navigationTitle(url.host ?? "Browser")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
