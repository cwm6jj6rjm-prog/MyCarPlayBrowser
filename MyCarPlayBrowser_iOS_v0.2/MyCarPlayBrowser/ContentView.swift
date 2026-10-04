import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection = "home"
    @State private var browserURL: URL?
    @State private var searchText = ""
    @State private var showSettings = false

    private var services: [Service] { Services.all }
    private var filteredServices: [Service] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return services }
        return services.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeView(services: filteredServices, searchText: $searchText, open: open, isFavorite: isFavorite, toggleFavorite: toggleFavorite)
                .tabItem { Label(t("home", settings.language), systemImage: "house.fill") }
                .tag("home")

            ListPage(title: t("favorites", settings.language), items: settings.favorites, open: open)
                .tabItem { Label(t("favorites", settings.language), systemImage: "star.fill") }
                .tag("favorites")

            ListPage(title: t("history", settings.language), items: settings.history, open: open)
                .tabItem { Label(t("history", settings.language), systemImage: "clock.fill") }
                .tag("history")

            BrowserStartView(open: open)
                .tabItem { Label(t("browser", settings.language), systemImage: "safari.fill") }
                .tag("browser")

            SettingsView()
                .tabItem { Label(t("settings", settings.language), systemImage: "gearshape.fill") }
                .tag("settings")
        }
        .tint(Color(red: 0.08, green: 0.48, blue: 1.0))
        .sheet(isPresented: Binding(get: { browserURL != nil }, set: { if !$0 { browserURL = nil } })) {
            if let url = browserURL { BrowserView(url: url) }
        }
        .preferredColorScheme(settings.theme == .dark ? .dark : .light)
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        let item = HistoryItem(title: url.host ?? string, url: string)
        settings.history.removeAll { $0.url == string }
        settings.history.insert(item, at: 0)
        settings.history = Array(settings.history.prefix(100))
        browserURL = url
    }

    private func isFavorite(_ service: Service) -> Bool {
        settings.favorites.contains { $0.url == service.url }
    }

    private func toggleFavorite(_ service: Service) {
        if isFavorite(service) {
            settings.favorites.removeAll { $0.url == service.url }
        } else {
            settings.favorites.insert(HistoryItem(title: service.name, url: service.url), at: 0)
        }
    }
}

struct HomeView: View {
    @ObservedObject private var settings = AppSettings.shared
    let services: [Service]
    @Binding var searchText: String
    let open: (String) -> Void
    let isFavorite: (Service) -> Bool
    let toggleFavorite: (Service) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    search
                    sectionHeader
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        ForEach(services) { service in
                            ServiceCard(service: service, favorite: isFavorite(service), open: { open(service.url) }, toggleFavorite: { toggleFavorite(service) })
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe.europe.africa.fill")
                        Text("MyCarPlayBrowser").font(.headline)
                    }
                }
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(red: 0.03, green: 0.12, blue: 0.28), Color(red: 0.02, green: 0.35, blue: 0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.white.opacity(0.10)).frame(width: 190).offset(x: 190, y: -35)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("ONLINE", systemImage: "circle.fill").font(.caption.bold()).foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    Text(Date(), style: .time).font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.8))
                }
                Spacer(minLength: 12)
                Text("MyCarPlayBrowser").font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("Your web. Your services. One place.").font(.subheadline).foregroundStyle(.white.opacity(0.78))
            }
            .padding(20)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 16, y: 8)
    }

    private var search: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search services…", text: $searchText)
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) } }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private var sectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(t("quick", settings.language)).font(.title2.bold())
                Text("Everything you use most").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(services.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
        }
    }
}

struct ServiceCard: View {
    let service: Service
    let favorite: Bool
    let open: () -> Void
    let toggleFavorite: () -> Void

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13).fill(iconColor.opacity(0.16))
                        Image(systemName: serviceSymbol).font(.title2.weight(.semibold)).foregroundStyle(iconColor)
                    }.frame(width: 48, height: 48)
                    Spacer()
                    Button(action: toggleFavorite) { Image(systemName: favorite ? "star.fill" : "star").font(.subheadline.weight(.semibold)).foregroundStyle(favorite ? .yellow : .secondary) }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 2)
                Text(service.name).font(.headline).foregroundStyle(.primary)
                Text(service.url.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "www.", with: ""))
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 145, alignment: .leading)
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.primary.opacity(0.05)))
            .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var serviceSymbol: String {
        switch service.id {
        case "youtube": return "play.rectangle.fill"
        case "netflix": return "tv.fill"
        case "disney": return "sparkles.tv.fill"
        case "apple": return "apple.logo"
        case "prime": return "play.tv.fill"
        case "google": return "magnifyingglass"
        case "browser": return "safari.fill"
        case "spotify": return "music.note"
        case "facebook": return "person.2.fill"
        case "tiktok": return "music.note.tv.fill"
        case "gmail": return "envelope.fill"
        case "instagram": return "camera.fill"
        default: return "globe"
        }
    }

    private var iconColor: Color {
        switch service.id {
        case "youtube": return .red
        case "netflix": return .red
        case "spotify": return .green
        case "google": return .blue
        case "facebook": return .blue
        case "instagram": return .purple
        default: return Color(red: 0.08, green: 0.48, blue: 1.0)
        }
    }
}

struct BrowserStartView: View {
    @State private var address = ""
    let open: (String) -> Void
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "safari.fill").font(.system(size: 54)).foregroundStyle(.blue)
                Text("Browser").font(.largeTitle.bold())
                Text("Enter a web address to open it inside MyCarPlayBrowser.").multilineTextAlignment(.center).foregroundStyle(.secondary)
                TextField("https://example.com", text: $address).textInputAutocapitalization(.never).keyboardType(.URL).autocorrectionDisabled().padding().background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 16))
                Button("Open") {
                    var value = address.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !value.lowercased().hasPrefix("http://") && !value.lowercased().hasPrefix("https://") { value = "https://" + value }
                    open(value)
                }.buttonStyle(.borderedProminent).disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }.padding(24).navigationTitle("Browser")
        }
    }
}

struct ListPage: View {
    let title: String
    let items: [HistoryItem]
    let open: (String) -> Void
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty { ContentUnavailableView(title, systemImage: title == "Favorites" ? "star" : "clock", description: Text("Nothing here yet.")) }
                else { List(items) { item in Button { open(item.url) } label: { VStack(alignment: .leading, spacing: 4) { Text(item.title).font(.headline); Text(item.url).font(.caption).foregroundStyle(.secondary).lineLimit(1) } } } }
            }.navigationTitle(title)
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    var body: some View {
        NavigationStack {
            Form {
                Section(t("appearance", settings.language)) {
                    Picker(t("appearance", settings.language), selection: $settings.theme) { Text("Dark").tag(AppTheme.dark); Text("Light").tag(AppTheme.light) }.pickerStyle(.segmented)
                }
                Section(t("language", settings.language)) {
                    Picker(t("language", settings.language), selection: $settings.language) { ForEach(AppLanguage.allCases) { Text($0.title).tag($0) } }
                }
                Section(t("startup", settings.language)) {
                    Picker(t("startup", settings.language), selection: $settings.startup) { Text(t("home", settings.language)).tag("home"); ForEach(Services.all) { Text($0.name).tag($0.id) } }
                }
                Section(t("carMode", settings.language)) {
                    Toggle(t("carMode", settings.language), isOn: $settings.carMode)
                    Toggle("Automatic Car Mode", isOn: $settings.autoCarMode)
                }
                Section("Browser") {
                    Button("Clear browser data", role: .destructive) { WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) }
                }
                Section("About") {
                    LabeledContent("App", value: "MyCarPlayBrowser")
                    LabeledContent("Version", value: "0.3")
                    Text("Modern iPhone browser with CarPlay integration.").foregroundStyle(.secondary)
                }
            }.navigationTitle(t("settings", settings.language))
        }
    }
}

struct BrowserView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var webView = WKWebView()
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WebViewContainer(webView: webView, url: url)
                HStack(spacing: 22) {
                    Button { webView.goBack() } label: { Image(systemName: "chevron.left") }.disabled(!webView.canGoBack)
                    Button { webView.goForward() } label: { Image(systemName: "chevron.right") }.disabled(!webView.canGoForward)
                    Button { webView.reload() } label: { Image(systemName: "arrow.clockwise") }
                    Spacer()
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }.padding(.horizontal, 18).padding(.vertical, 12).background(.bar)
            }.navigationTitle(url.host ?? "Browser").navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    let url: URL
    func makeUIView(context: Context) -> WKWebView { webView.allowsBackForwardNavigationGestures = true; webView.load(URLRequest(url: url)); return webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
