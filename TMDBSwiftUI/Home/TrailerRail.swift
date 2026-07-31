import SwiftUI
import TMDBCore

struct TrailerRail: View {
    let items: [SearchResult]
    let trailerKeys: [String: String]
    let onPlayTap: (String) -> Void
    let onCardAppear: (SearchResult) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { result in
                    TrailerCard(
                        result: result,
                        trailerKey: trailerKeys[result.id],
                        onPlayTap: onPlayTap
                    )
                    .onAppear { onCardAppear(result) }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct TrailerCard: View {
    let result: SearchResult
    let trailerKey: String?
    let onPlayTap: (String) -> Void

    private var backdropURL: URL? {
        switch result {
        case .movie(let m):  return m.backdropURL
        case .series(let s): return s.backdropURL
        case .person:        return nil
        }
    }

    private var title: String {
        switch result {
        case .movie(let m):  return m.title
        case .series(let s): return s.name
        case .person(let p): return p.name
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: backdropURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "film")
                                .font(.system(size: 32))
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(width: 240, height: 140)

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            if let key = trailerKey {
                Button {
                    onPlayTap(key)
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(.white)
                        .shadow(radius: 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .padding(8)
        }
        .frame(width: 240, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
