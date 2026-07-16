//
//  SeriesDetailView.swift
//  tmdb-app
//

import SwiftUI
import TMDBCore

// MARK: - SeriesDetailView

struct SeriesDetailView: View {

    var viewModel: SeriesDetailViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage {
                SeriesDetailErrorView(message: message) {
                    Task { await viewModel.load() }
                }
            } else if let detail = viewModel.detail {
                ScrollView {
                    VStack(spacing: 0) {
                        SeriesDetailHeaderSection(viewModel: viewModel, detail: detail)

                        VStack(alignment: .leading, spacing: 16) {
                            SeriesDetailScoreSection(
                                voteAverage: detail.voteAverage,
                                voteCount: detail.voteCount,
                                tagline: detail.tagline
                            )
                            SeriesDetailCastSection(
                                displayedCast: viewModel.displayedCast,
                                showMoreButton: viewModel.cast.count > 6,
                                showFullCast: viewModel.showFullCast,
                                onToggleFullCast: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.showFullCast.toggle()
                                    }
                                }
                            )
                            SeriesDetailSocialSection(reviews: viewModel.reviews)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .alert("Info", isPresented: Binding(
            get: { viewModel.feedbackMessage != nil },
            set: { if !$0 { viewModel.feedbackMessage = nil } }
        )) {
            Button("OK") { viewModel.feedbackMessage = nil }
        } message: {
            Text(viewModel.feedbackMessage ?? "")
        }
    }
}

// MARK: - SeriesDetailErrorView

private struct SeriesDetailErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button { onRetry() } label: {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SeriesDetailHeaderSection

private struct SeriesDetailHeaderSection: View {
    let viewModel: SeriesDetailViewModel
    let detail: SeriesDetail

    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showListSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(height: verticalSizeClass == .compact ? 16 : 52)

            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Series")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.35))
                .clipShape(Capsule())
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)

            HStack(alignment: .bottom, spacing: 14) {
                AsyncImage(url: detail.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .overlay {
                                Image(systemName: "tv").foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(width: 115, height: 172)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.5), radius: 8, y: 4)

                VStack(alignment: .leading, spacing: 7) {
                    Text(detail.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        if let year = detail.firstAirDate?.prefix(4) {
                            Text(year)
                        }
                        Text("·")
                        Text("\(detail.numberOfSeasons) Season\(detail.numberOfSeasons == 1 ? "" : "s")")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text(detail.voteAverage, format: .number.precision(.fractionLength(1)))
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .foregroundStyle(.white)

                    if !detail.genres.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(detail.genres.prefix(3)) { genre in
                                Text(genre.name)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 0) {
                SeriesHeaderActionButton(
                    icon: "list.bullet.rectangle.portrait",
                    activeIcon: "list.bullet.rectangle.portrait.fill",
                    label: "Add to List",
                    isActive: false,
                    isLoading: false
                ) {
                    showListSheet = true
                    Task { await viewModel.loadUserLists() }
                }

                SeriesHeaderActionButton(
                    icon: "heart",
                    activeIcon: "heart.fill",
                    label: "Favorite",
                    isActive: viewModel.isFavorite,
                    isLoading: viewModel.isTogglingFavorite
                ) {
                    Task { await viewModel.toggleFavorite() }
                }

                SeriesHeaderActionButton(
                    icon: "bookmark",
                    activeIcon: "bookmark.fill",
                    label: "Watchlist",
                    isActive: viewModel.isInWatchlist,
                    isLoading: viewModel.isTogglingWatchlist
                ) {
                    Task { await viewModel.toggleWatchlist() }
                }

                SeriesHeaderActionButton(
                    icon: "play.rectangle",
                    activeIcon: "play.rectangle.fill",
                    label: "Trailer",
                    isActive: false,
                    isLoading: false,
                    action: {}
                )
            }
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(SeriesDetailBackdrop(url: detail.backdropURL))
        .sheet(isPresented: $showListSheet) {
            SeriesAddToListSheet(viewModel: viewModel)
        }
    }
}

private struct SeriesDetailBackdrop: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Color(hex: "0D253F")
            }
        }
        .overlay {
            LinearGradient(
                colors: [.black.opacity(0.2), .black.opacity(0.55), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - SeriesHeaderActionButton

private struct SeriesHeaderActionButton: View {
    let icon: String
    let activeIcon: String
    let label: String
    let isActive: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                if isLoading {
                    ProgressView()
                        .frame(width: 26, height: 26)
                        .tint(.white)
                } else {
                    Image(systemName: isActive ? activeIcon : icon)
                        .font(.system(size: 26))
                        .foregroundStyle(isActive ? Color.yellow : Color.white)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(isLoading)
    }
}

// MARK: - SeriesAddToListSheet

private struct SeriesAddToListSheet: View {
    let viewModel: SeriesDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoadingLists {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.userLists.isEmpty {
                    ContentUnavailableView(
                        "No Lists",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Create a list on TMDB to add series to it.")
                    )
                } else {
                    List(viewModel.userLists) { list in
                        Button {
                            Task { await viewModel.addToList(listId: list.id) }
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(list.name)
                                    .foregroundStyle(.primary)
                                Text("\(list.itemCount) items")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - SeriesDetailScoreSection

private struct SeriesDetailScoreSection: View {
    let voteAverage: Double
    let voteCount: Int
    let tagline: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 16)

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: voteAverage / 10)
                        .stroke(scoreColor(voteAverage),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text(voteAverage / 10, format: .percent.precision(.fractionLength(0)))
                            .font(.system(size: 17, weight: .bold))
                        Text("Score")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label("\(voteCount.formatted()) ratings", systemImage: "person.2.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let tagline, !tagline.isEmpty {
                        Text("\"\(tagline)\"")
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 7 { return .green }
        if score >= 5 { return .yellow }
        return .red
    }
}

// MARK: - SeriesDetailCastSection

private struct SeriesDetailCastSection: View {
    let displayedCast: [CastMember]
    let showMoreButton: Bool
    let showFullCast: Bool
    let onToggleFullCast: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(displayedCast.enumerated()), id: \.element.id) { index, member in
                    VStack(spacing: 0) {
                        SeriesCastRow(member: member)
                        if index < displayedCast.count - 1 {
                            Divider().padding(.leading, 76)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)

            if showMoreButton {
                Button(action: onToggleFullCast) {
                    HStack(spacing: 6) {
                        Text(showFullCast ? "Show less" : "Show full cast")
                            .fontWeight(.medium)
                        Image(systemName: showFullCast ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(Color(hex: "01B4E4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct SeriesCastRow: View {
    let member: CastMember

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: member.profileURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "person.fill").foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(member.character)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - SeriesDetailSocialSection

private struct SeriesDetailSocialSection: View {
    let reviews: [Review]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Social")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 16)

            if reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(reviews) { review in
                        SeriesReviewCard(review: review)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct SeriesReviewCard: View {
    let review: Review
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: "01B4E4"))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(review.author.prefix(1)).uppercased())
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if let rating = review.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            Text(rating, format: .number.precision(.fractionLength(1)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }

            Text(review.content)
                .font(.callout)
                .foregroundStyle(.primary)
                .lineLimit(isExpanded ? nil : 3)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                Text(isExpanded ? "Show less" : "Read more")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "01B4E4"))
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
