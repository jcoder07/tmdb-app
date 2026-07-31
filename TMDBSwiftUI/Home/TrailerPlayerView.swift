import SwiftUI
import WebKit

struct TrailerPlayerView: View {
    let youtubeKey: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            YouTubeWebView(key: youtubeKey)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Trailer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let key: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let urlString = "https://www.youtube.com/embed/\(key)?autoplay=1&playsinline=1"
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }
}
