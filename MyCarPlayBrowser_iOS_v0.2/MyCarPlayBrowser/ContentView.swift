import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var url: URL?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("MyCarPlayBrowser")
                        .font(.largeTitle.bold())

                    Text(t("quick", settings.language))
                        .font(.title3.bold())

                    ForEach(Services.all.prefix(9)) { service in
                        Button {
                            open(service.url)
                        } label: {
                            HStack {
                                Text(service.icon)
                                    .font(.title2)
                                Text(service.name)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("MyCarPlayBrowser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(item: $url) { value in
                BrowserView(url: value)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private func open(_ value: String) {
        url = URL(string: value)
    }
}

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(t("language", settings.language)) {
                    Picker(t("language", settings.language), selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.title).tag(language)
                        }
                    }
                }

                Section(t("appearance", settings.language)) {
                    Picker(t("appearance", settings.language), selection: $settings.theme) {
                        Text("Dark").tag(AppTheme.dark)
                        Text("Light").tag(AppTheme.light)
                    }
                    .pickerStyle(.segmented)
                }

                Section(t("carMode", settings.language)) {
                    Toggle(t("carMode", settings.language), isOn: $settings.carMode)
                    Toggle("Automatic Car Mode", isOn: $settings.autoCarMode)
                }

                Section {
                    Button(t("clear", settings.language), role: .destructive) {
                        clearWebData()
                    }
                }
            }
            .navigationTitle(t("settings", settings.language))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func clearWebData() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {}
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
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = true
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}
}
