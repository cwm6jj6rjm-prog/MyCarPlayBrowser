    var body: some View {
        Form {
            Section {
                Text("MyCarPlayBrowser")
                    .font(.title.bold())

                Text("iOS / CarPlay development build")
                    .opacity(0.6)
            }

            Section(t("about", settings.language)) {
                Text(
                    "The iOS version is based on the MyCarPlayBrowser desktop prototype and is being prepared for CarPlay integration."
                )
            }
        }
    }
}

struct BrowserView: View {
    let url: URL

    @Environment(\.dismiss) private var dismiss
    @State private var canBack = false
    @State private var canForward = false
    @State private var webView = WKWebView()

    var body: some View {
        VStack(spacing: 0) {
            WebViewContainer(
                webView: webView,
                url: url
            )

            Divider()

            HStack {
                Button {
                    webView.goBack()
                    updateState()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canBack)

                Button {
                    webView.goForward()
                    updateState()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canForward)

                Button {
                    webView.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
            }
            .padding(10)
        }
        .onAppear {
            updateState()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .webViewStateChanged
            )
        ) { _ in
            updateState()
        }
    }

    private func updateState() {
        canBack = webView.canGoBack
        canForward = webView.canGoForward
    }
}

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(
        _ uiView: WKWebView,
        context: Context
    ) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            NotificationCenter.default.post(
                name: .webViewStateChanged,
                object: nil
            )
        }
    }
}

extension Notification.Name {
    static let webViewStateChanged =
        Notification.Name("webViewStateChanged")
}
