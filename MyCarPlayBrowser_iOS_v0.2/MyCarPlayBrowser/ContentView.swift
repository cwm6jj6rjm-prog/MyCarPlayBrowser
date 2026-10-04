import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selection = "home"
    @State private var browserURL: URL?
    @State private var showAdd = false
    @State private var showClear = false
    @State private var showMenu = false

    var body: some View {
        NavigationStack {
            Group {
                switch selection {
                case "favorites": ListPage(title: t("favorites", settings.language), items: settings.favorites) { open($0.url) }
                case "history": ListPage(title: t("history", settings.language), items: settings.history) { open($0.url) }
                case "settings": SettingsView(showClear: $showClear)
                case "about": AboutView()
                default: HomeView(open: open, add: { showAdd = true })
                }
            }
            .navigationTitle(selection == "home" ? "MyCarPlayBrowser" : "")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Menu { Button { selection = "home" } label: { Label(t("home", settings.language), systemImage: "house") }; Button { selection = "favorites" } label: { Label(t("favorites", settings.language), systemImage: "star") }; Button { selection = "history" } label: { Label(t("history", settings.language), systemImage: "clock") }; Button { selection = "settings" } label: { Label(t("settings", settings.language), systemImage: "gear") }; Button { selection = "about" } label: { Label(t("about", settings.language), systemImage: "info.circle") } } label: { Image(systemName: "line.3.horizontal") } } }
            .sheet(isPresented: $showAdd) { AddCardView() }
            .sheet(item: $browserURL) { url in BrowserView(url: url) }
            .alert(t("clear", settings.language), isPresented: $showClear) { Button(t("cancel", settings.language), role: .cancel) {} ; Button(t("delete", settings.language), role: .destructive) { clearAllWebData() } } message: { Text("WebKit cache, cookies and local website data will be removed.") }
        }
        .task { if settings.autoCarMode { settings.carMode = true } }
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        let item = HistoryItem(title: url.host ?? string, url: string)
        settings.history.removeAll { $0.url == string }
        settings.history.insert(item, at: 0)
        settings.history = Array(settings.history.prefix(100))
        browserURL = url
    }

    private func clearAllWebData() {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: Date(timeIntervalSince1970: 0)) { }
        settings.history.removeAll()
    }
}

struct HomeView: View {
    @ObservedObject private var settings = AppSettings.shared
    let open: (String) -> Void
    let add: () -> Void
    @State private var now = Date()

    var services: [Service] { settings.cards.compactMap { id in Services.all.first(where: { $0.id == id }) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("YOUR BROWSER • YOUR SERVICES").font(.caption.bold()).opacity(0.6)
                        Text("Everything you watch.\nOne simple place.").font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Text("M\nDRIVE").font(.caption.bold()).multilineTextAlignment(.center).padding(14).background(.thinMaterial).clipShape(Circle())
                }
                HStack {
                    Label("Online", systemImage: "circle.fill").foregroundStyle(.green).font(.caption.bold())
                    Spacer()
                    VStack(alignment: .trailing) { Text(now, style: .time).font(.headline); Text(now, style: .date).font(.caption).opacity(0.6) }
                }
                HStack { Image(systemName: "cloud.sun.fill"); Text("Weather"); Spacer(); Text("--°") }.font(.subheadline).opacity(0.8)
                HStack { Text(t("quick", settings.language)).font(.title3.bold()); Spacer(); if services.count < 9 { Button(action: add) { Label(t("add", settings.language), systemImage: "plus") } } }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                    ForEach(services) { service in
                        Button { open(service.url) } label: { ServiceCard(service: service) }.buttonStyle(.plain)
                    }
                }
            }.padding()
        }
        .background(Color(uiColor: .systemBackground))
        
    }
}

struct ServiceCard: View {
    let service: Service
    var body: some View { VStack(alignment: .leading, spacing: 10) { Text(service.icon).font(.system(size: 28, weight: .bold)); Text(service.name).font(.headline); Text(service.url.replacingOccurrences(of: "https://", with: "").trimmingCharacters(in: CharacterSet(charactersIn: "/"))).font(.caption).lineLimit(1).opacity(0.55) }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08))) }
}

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = AppSettings.shared
    var available: [Service] { Services.all.filter { !settings.cards.contains($0.id) } }
    var body: some View { NavigationStack { List(available) { service in Button { settings.cards.append(service.id); dismiss() } label: { Label(service.name, systemImage: "plus.circle") } }.navigationTitle(t("add", settings.language)).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } } } }
}

struct ListPage: View {
    @ObservedObject private var settings = AppSettings.shared
    let title: String
    let items: [HistoryItem]
    let open: (String) -> Void
    var body: some View { List(items) { item in Button { open(item.url) } label: { VStack(alignment: .leading) { Text(item.title).font(.headline); Text(item.url).font(.caption).lineLimit(1).opacity(0.6) } } }.navigationTitle(title) }
}

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Binding var showClear: Bool
    var body: some View { Form { Section(t("language", settings.language)) { Picker(t("language", settings.language), selection: $settings.language) { ForEach(AppLanguage.allCases) { Text($0.title).tag($0) } } }.labelsHidden(); Section(t("appearance", settings.language)) { Picker(t("appearance", settings.language), selection: $settings.theme) { Text("Dark").tag(AppTheme.dark); Text("Light").tag(AppTheme.light) }.pickerStyle(.segmented) }; Section(t("startup", settings.language)) { Picker(t("startup", settings.language), selection: $settings.startup) { Text(t("home", settings.language)).tag("home"); ForEach(Services.all) { Text($0.name).tag($0.id) } } }; Section(t("carMode", settings.language)) { Toggle(t("carMode", settings.language), isOn: $settings.carMode); Toggle("Automatic Car Mode", isOn: $settings.autoCarMode) }; Section(t("clear", settings.language)) { Button(t("clear", settings.language), role: .destructive) { showClear = true } } }.navigationTitle(t("settings", settings.language)) }
}

struct AboutView: View { @ObservedObject private var settings = AppSettings.shared; var body: some View { Form { Section { Text("MyCarPlayBrowser").font(.title.bold()); Text("iOS / CarPlay development build").opacity(0.6) }; Section(t("about", settings.language)) { Text("The iOS version is based on the MyCarPlayBrowser desktop prototype and is being prepared for CarPlay integration.") } } }

struct BrowserView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var canBack = false
    @State private var canForward = false
    @State private var webView: WKWebView = WKWebView()
    var body: some View { VStack(spacing: 0) { WebViewContainer(webView: webView, url: url) ; Divider(); HStack { Button { webView.goBack() } label: { Image(systemName: "chevron.left") }.disabled(!canBack); Button { webView.goForward() } label: { Image(systemName: "chevron.right") }.disabled(!canForward); Button { webView.reload() } label: { Image(systemName: "arrow.clockwise") }; Spacer(); Button("Done") { dismiss() } }.padding(10) }.onAppear { updateState() }.onReceive(NotificationCenter.default.publisher(for: .webViewStateChanged)) { _ in updateState() } }
    private func updateState() { canBack = webView.canGoBack; canForward = webView.canGoForward }
}

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    let url: URL
    func makeUIView(context: Context) -> WKWebView { webView.navigationDelegate = context.coordinator; webView.load(URLRequest(url: url)); return webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator: NSObject, WKNavigationDelegate { func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { NotificationCenter.default.post(name: .webViewStateChanged, object: nil) } }
}
extension Notification.Name { static let webViewStateChanged = Notification.Name("webViewStateChanged") }
