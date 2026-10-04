import SwiftUI
import WebKit
import Foundation
import UIKit

struct ContentView: View {
    @State private var selection: String = "home"
    @State private var browserURL: URL?
    @State private var searchText: String = ""

    private var settings: AppSettings { AppSettings.shared }

    var body: some View {
        TabView(selection: $selection) {
            HomeView(searchText: $searchText, open: open)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag("home")

            FavoritesView(open: open)
                .tabItem { Label("Favorites", systemImage: "star.fill") }
                .tag("favorites")

            HistoryView(open: open)
                .tabItem { Label("History", systemImage: "clock.fill") }
                .tag("history")

            BrowserStartView(open: open)
                .tabItem { Label("Browser", systemImage: "safari.fill") }
                .tag("browser")

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag("settings")
        }
        .tint(Color(red: 0.08, green: 0.48, blue: 1.0))
        .sheet(isPresented: Binding(
            get: { browserURL != nil },
            set: { if !$0 { browserURL = nil } }
        )) {
            if let url = browserURL {
                BrowserView(url: url)
            }
        }
        .preferredColorScheme(settings.theme == .dark ? .dark : .light)
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        settings.history.removeAll { $0.url == string }
        settings.history.insert(HistoryItem(title: url.host ?? string, url: string), at: 0)
        settings.history = Array(settings.history.prefix(100))
        browserURL = url
    }
}

struct HomeView: View {
    @Binding var searchText: String
    let open: (String) -> Void

    private var services: [Service] { Services.all }

    private var filteredServices: [Service] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return services }
        return services.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    search
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Quick access").font(.title2.bold())
                            Text("Your favorite services in one place")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(filteredServices.count)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(filteredServices) { service in
                            ServiceCard(service: service, open: { open(service.url) })
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
                    Label("MyCarPlayBrowser", systemImage: "globe.europe.africa.fill")
                        .font(.headline)
                }
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.12, blue: 0.28), Color(red: 0.02, green: 0.35, blue: 0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 190)
                .offset(x: 180, y: -35)

            VStack(alignment: .leading, spacing: 8) {
                Label("ONLINE", systemImage: "circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.85))
                Spacer(minLength: 10)
                Text("MyCarPlayBrowser")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Your web. Your services. One place.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(20)
        }
        .frame(height: 185)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 16, y: 8)
    }

    private var search: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search services…", text: $searchText)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

struct ServiceCard: View {
    let service: Service
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(iconColor.opacity(0.16))
                    Image(systemName: serviceSymbol)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(iconColor)
                }
                .frame(width: 48, height: 48)

                Spacer(minLength: 2)

                Text(service.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(service.url.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "www.", with: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
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
        case "youtube", "netflix": return .red
        case "spotify": return .green
        case "google", "facebook": return .blue
        case "instagram": return .purple
        default: return Color(red: 0.08, green: 0.48, blue: 1.0)
        }
    }
}

struct FavoritesView: View {
    let open: (String) -> Void
    var body: some View {
        NavigationStack {
            List(AppSettings.shared.favorites) { item in
                Button { open(item.url) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline)
                        Text(item.url).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

struct HistoryView: View {
    let open: (String) -> Void
    var body: some View {
        NavigationStack {
            List(AppSettings.shared.history) { item in
                Button { open(item.url) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline)
                        Text(item.url).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct BrowserStartView: View {
    @State private var address: String = ""
    let open: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.blue)
                Text("Browser").font(.largeTitle.bold())
                Text("Enter a web address to open it inside MyCarPlayBrowser.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                TextField("https://example.com", text: $address)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Button("Open") {
                    var value = address.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !value.lowercased().hasPrefix("http://") && !value.lowercased().hasPrefix("https://") {
                        value = "https://" + value
                    }
                    open(value)
                }
                .buttonStyle(.borderedProminent)
                .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding(24)
            .navigationTitle("Browser")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { AppSettings.shared.theme },
                        set: { AppSettings.shared.theme = $0 }
                    )) {
                        Text("Dark").tag(AppTheme.dark)
                        Text("Light").tag(AppTheme.light)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Language") {
                    Picker("Language", selection: Binding(
                        get: { AppSettings.shared.language },
                        set: { AppSettings.shared.language = $0 }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.title).tag(language)
                        }
                    }
                }
                Section("Car Mode") {
                    Toggle("Car Mode", isOn: Binding(
                        get: { AppSettings.shared.carMode },
                        set: { AppSettings.shared.carMode = $0 }
                    ))
                    Toggle("Automatic Car Mode", isOn: Binding(
                        get: { AppSettings.shared.autoCarMode },
                        set: { AppSettings.shared.autoCarMode = $0 }
                    ))
                }
                Section("Browser") {
                    Button("Clear browser data", role: .destructive) {
                        Task { @MainActor in
                            await WKWebsiteDataStore.default().removeData(
                                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                modifiedSince: .distantPast
                            )
                        }
                    }
                }
                Section("About") {
                    LabeledContent("App", value: "MyCarPlayBrowser")
                    LabeledContent("Version", value: "0.3")
                    Text("Modern iPhone browser with CarPlay integration.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct BrowserView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebViewContainer(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(url.host ?? "Browser")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
