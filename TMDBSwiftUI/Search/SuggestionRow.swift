import SwiftUI
import TMDBCore

struct SuggestionRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: kindIcon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: kindIcon)
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(width: 38, height: 57)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var kindIcon: String {
        switch result {
        case .movie:  return "film"
        case .series: return "tv"
        case .person: return "person.crop.circle"
        }
    }

    private var thumbnailURL: URL? {
        switch result {
        case .movie(let m):  return m.posterURL
        case .series(let s): return s.posterURL
        case .person(let p): return p.profileURL
        }
    }

    private var title: String {
        switch result {
        case .movie(let m):  return m.title
        case .series(let s): return s.name
        case .person(let p): return p.name
        }
    }

    private var subtitle: String {
        switch result {
        case .movie(let m):
            return m.releaseDate.flatMap { String($0.prefix(4)) } ?? ""
        case .series(let s):
            return s.firstAirDate.flatMap { String($0.prefix(4)) } ?? ""
        case .person(let p):
            return p.knownForText
        }
    }
}
