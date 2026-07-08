import SwiftUI

struct MediaListView<Content: View>: View {
    let isEmpty: Bool
    let emptyLabel: LocalizedStringKey
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let onLoadMore: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isEmpty {
            MediaEmptyView(label: emptyLabel)
        } else {
            List {
                content()
                if canLoadMore {
                    Button(action: onLoadMore) {
                        if isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Load More")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "01B4E4"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct MediaItemRow: View {
    let title: String
    let overview: String
    let posterURL: URL?
    let voteAverage: Double
    let year: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            MediaPosterImage(url: posterURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if let year {
                        Text(year)
                            .foregroundStyle(.secondary)
                    }
                    MediaRatingBadge(value: voteAverage)
                }
                .font(.subheadline)
                Text(overview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MediaPosterImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .overlay {
                        Image(systemName: "film")
                            .foregroundStyle(.tertiary)
                    }
            }
        }
        .frame(width: 60, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct MediaRatingBadge: View {
    let value: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(value, format: .number.precision(.fractionLength(1)))
        }
    }
}

struct MediaEmptyView: View {
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MediaErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
