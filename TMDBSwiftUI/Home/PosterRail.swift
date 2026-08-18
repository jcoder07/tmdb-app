import SwiftUI
import TMDBCore

struct PosterRail: View {
    let items: [SearchResult]
    var identifier: String? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(items) { result in
                    if let config = config(for: result) {
                        NavigationLink(value: config.route) {
                            MediaPosterCard(
                                title: config.title,
                                posterURL: config.posterURL,
                                voteAverage: config.voteAverage
                            )
                            .frame(width: 120)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(cardIdentifier(for: result))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .accessibilityIdentifier(identifier ?? "")
    }

    private func cardIdentifier(for result: SearchResult) -> String {
        guard let identifier else { return "" }
        return "\(identifier).card.\(result.id)"
    }

    private struct Config {
        let title: String
        let posterURL: URL?
        let voteAverage: Double
        let route: SearchRoute
    }

    private func config(for result: SearchResult) -> Config? {
        switch result {
        case .movie(let m):
            return Config(title: m.title, posterURL: m.posterURL, voteAverage: m.voteAverage, route: .movie(m.id))
        case .series(let s):
            return Config(title: s.name, posterURL: s.posterURL, voteAverage: s.voteAverage, route: .series(s.id))
        case .person:
            return nil
        }
    }
}
