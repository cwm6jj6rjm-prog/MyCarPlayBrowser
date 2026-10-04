
                    Toggle(
                        "Automatic Car Mode",
                        isOn: $settings.autoCarMode
                    )
                }

                Section("Browser") {
                    Button(
                        "Clear browser data",
                        role: .destructive
                    ) {
                        Task {
                            await WKWebsiteDataStore
                                .default()
                                .removeData(
                                    ofTypes:
                                        WKWebsiteDataStore
                                        .allWebsiteDataTypes(),
                                    modifiedSince:
                                        Date(
                                            timeIntervalSince1970: 0
                                        )
                                )
                        }
                    }
                }

                Section("About") {
                    LabeledContent(
                        "App",
                        value: "MyCarPlayBrowser"
                    )

                    LabeledContent(
                        "Version",
                        value: "0.3"
                    )

                    Text(
                        "Modern iPhone browser with CarPlay integration."
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(
                t("settings", settings.language)
            )
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
                WebViewContainer(
                    webView: webView,
                    url: url
                )

                HStack(spacing: 22) {
                    Button {
                        webView.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!webView.canGoBack)

                    Button {
                        webView.goForward()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!webView.canGoForward)

                    Button {
                        webView.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.bar)
            }
            .navigationTitle(
                url.host ?? "Browser"
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    let url: URL

    func makeUIView(
        context: Context
    ) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        webView.load(
            URLRequest(url: url)
        )
        return webView
    }

    func updateUIView(
        _ uiView: WKWebView,
        context: Context
    ) {
    }
}
