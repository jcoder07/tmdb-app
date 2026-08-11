import SwiftUI

struct MediaPosterCard: View {
    let title: String
    let posterURL: URL?
    let voteAverage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "film")
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text(voteAverage, format: .number.precision(.fractionLength(1)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
