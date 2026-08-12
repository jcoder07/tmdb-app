//
//  ProfileView.swift
//  tmdb-app
//

import SwiftUI
import Charts
import TMDBCore

// MARK: - Preview Data

extension UserProfile {
    static let preview = UserProfile(
        username: "Juanjo07",
        avatarURL: nil,
        avgMovieScore: 40,
        avgTVScore: 0,
        totalMovieRatings: 1,
        totalTVRatings: 0,
        ratingDistribution: [
            RatingBar(rating: 1, count: 0),
            RatingBar(rating: 2, count: 0),
            RatingBar(rating: 3, count: 0),
            RatingBar(rating: 4, count: 1),
            RatingBar(rating: 5, count: 0),
            RatingBar(rating: 6, count: 0),
            RatingBar(rating: 7, count: 0),
            RatingBar(rating: 8, count: 0),
            RatingBar(rating: 9, count: 0),
            RatingBar(rating: 10, count: 0),
        ],
        topGenres: [
            GenreSlice(name: "Action",    colorHex: "01B4E4", opacity: 1.00, percentage: 0.35),
            GenreSlice(name: "Drama",     colorHex: "01B4E4", opacity: 0.81, percentage: 0.25),
            GenreSlice(name: "Adventure", colorHex: "01B4E4", opacity: 0.62, percentage: 0.20),
            GenreSlice(name: "Comedy",    colorHex: "01B4E4", opacity: 0.44, percentage: 0.12),
            GenreSlice(name: "Thriller",  colorHex: "01B4E4", opacity: 0.25, percentage: 0.08),
        ],
        accentHex: "01B4E4"
    )
}

// MARK: - ProfileView

struct ProfileView: View {
    var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert = false
    let onGoToWatchlist: () -> Void

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if let message = viewModel.errorMessage, viewModel.profile == nil {
                ProfileErrorView(
                    message: message,
                    onRetry: { Task { await viewModel.load() } },
                    onDismiss: { dismiss() }
                )
            } else {
                ProfileMainView(
                    profile: viewModel.profile ?? .preview,
                    showLogoutAlert: $showLogoutAlert,
                    onGoToWatchlist: onGoToWatchlist,
                    onDismiss: { dismiss() }
                )
            }
        }
        .task { await viewModel.load() }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

// MARK: - ProfileErrorView

private struct ProfileErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button {
                    onRetry()
                } label: {
                    Text("Retry")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.top, 56)
            .padding(.trailing, 16)
        }
    }
}

// MARK: - ProfileMainView

private struct ProfileMainView: View {
    let profile: UserProfile
    @Binding var showLogoutAlert: Bool
    let onGoToWatchlist: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileHeaderSection(
                username: profile.username,
                avatarURL: profile.avatarURL,
                avgMovieScore: profile.avgMovieScore,
                avgTVScore: profile.avgTVScore,
                accentHex: profile.accentHex,
                onDismiss: onDismiss
            )
            .fixedSize(horizontal: false, vertical: true)
            ScrollView {
                ProfileContentSection(
                    profile: profile,
                    showLogoutAlert: $showLogoutAlert,
                    onGoToWatchlist: onGoToWatchlist
                )
            }
            .background(Color(.systemGroupedBackground))
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - ProfileHeaderSection

private struct ProfileHeaderSection: View {
    let username: String
    let avatarURL: URL?
    let avgMovieScore: Double
    let avgTVScore: Double
    let accentHex: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(hex: "0D253F"), Color(hex: "1A3A5C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)

            DiagonalDecorations(accentHex: accentHex)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 40)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 20) {
                    AvatarView(url: avatarURL)
                    Text(username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)

                HStack(alignment: .center, spacing: 16) {
                    ScoreCircle(value: avgMovieScore, label: "Average Movie Score", accentHex: accentHex)
                    ScoreCircle(value: avgTVScore, label: "Average TV Score", accentHex: accentHex)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - AvatarView

private struct AvatarView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            default:
                ZStack {
                    Circle()
                        .fill(Color(hex: "0668E1"))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 80, height: 80)
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
        )
    }
}

// MARK: - ScoreCircle

private struct ScoreCircle: View {
    let value: Double
    let label: LocalizedStringKey
    let accentHex: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        value > 0 ? Color(hex: accentHex) : Color.gray,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                Text(value / 100, format: .percent.precision(.fractionLength(0)))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - DiagonalDecorations

private struct DiagonalDecorations: View {
    let accentHex: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: accentHex).opacity(0.7))
                .frame(width: 6, height: 60)
                .rotationEffect(.degrees(-45))
                .offset(x: -40, y: 20)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: accentHex).opacity(0.5))
                .frame(width: 6, height: 40)
                .rotationEffect(.degrees(-45))
                .offset(x: -70, y: 10)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: accentHex).opacity(0.6))
                .frame(width: 6, height: 50)
                .rotationEffect(.degrees(-45))
                .offset(x: -15, y: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .clipped()
    }
}

// MARK: - ProfileContentSection

private struct ProfileContentSection: View {
    let profile: UserProfile
    @Binding var showLogoutAlert: Bool
    let onGoToWatchlist: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Stats")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 4)
                Spacer()
                Button(action: onGoToWatchlist) {
                    Text("Go To Watchlist")
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "01B4E4"))
                        .font(.subheadline)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 4)

            HStack(spacing: 16) {
                StatCard(title: "Rated Movies", value: profile.totalMovieRatings, accentHex: profile.accentHex)
                StatCard(title: "Rated TV", value: profile.totalTVRatings, accentHex: profile.accentHex)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            ProfileRatingOverviewCard(distribution: profile.ratingDistribution, accentHex: profile.accentHex)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            ProfileGenresCard(topGenres: profile.topGenres)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            Button {
                showLogoutAlert = true
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out")
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundStyle(.red)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let title: LocalizedStringKey
    let value: Int
    let accentHex: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value, format: .number)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(hex: accentHex))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ProfileRatingOverviewCard

private struct ProfileRatingOverviewCard: View {
    let distribution: [RatingBar]
    let accentHex: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating Overview")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Chart(distribution) { bar in
                BarMark(
                    x: .value("Rating", "\(bar.rating)"),
                    y: .value("Count", bar.count)
                )
                .foregroundStyle(Color(hex: accentHex))
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ProfileGenresCard

private struct ProfileGenresCard: View {
    let topGenres: [GenreSlice]

    private func donutSegments() -> [(id: UUID, start: Double, end: Double, color: Color)] {
        var result: [(id: UUID, start: Double, end: Double, color: Color)] = []
        var current = 0.0
        for genre in topGenres {
            let end = current + genre.percentage
            result.append((id: genre.id, start: current, end: end, color: Color(hex: genre.colorHex).opacity(genre.opacity)))
            current = end
        }
        return result
    }

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                ForEach(donutSegments(), id: \.id) { segment in
                    Circle()
                        .trim(from: segment.start, to: segment.end)
                        .stroke(segment.color, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                }
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Most Watched Genres")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(topGenres) { genre in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: genre.colorHex).opacity(genre.opacity))
                            .frame(width: 14, height: 14)
                        Text(genre.name)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview Mocks

private struct MockProfileService: ProfileServiceProtocol {
    var shouldFail = false
    var shouldHang = false

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        if shouldHang { try await Task.sleep(for: .seconds(100)) }
        if shouldFail { throw URLError(.badServerResponse) }
        return AccountProfile(id: 6445638, displayName: "Miguel", avatarURL: nil)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        if shouldFail { throw URLError(.badServerResponse) }
        return [
            RatedMovie(id: 1, rating: 4.0, genreIds: [28, 12]),
            RatedMovie(id: 2, rating: 8.0, genreIds: [28, 18]),
            RatedMovie(id: 3, rating: 6.0, genreIds: [12, 35]),
            RatedMovie(id: 4, rating: 9.0, genreIds: [53, 35]),
            RatedMovie(id: 5, rating: 9.0, genreIds: [28, 53]),
        ]
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        if shouldFail { throw URLError(.badServerResponse) }
        return [RatedTVShow(id: 1, rating: 7.0, genreIds: [10765, 18])]
    }

    func fetchMovieGenres() async throws -> [GenreItem] {
        if shouldFail { throw URLError(.badServerResponse) }
        return [
            GenreItem(id: 28, name: "Action"),
            GenreItem(id: 12, name: "Adventure"),
            GenreItem(id: 18, name: "Drama"),
            GenreItem(id: 35, name: "Comedy"),
            GenreItem(id: 53, name: "Thriller"),
        ]
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        if shouldFail { throw URLError(.badServerResponse) }
        return [
            GenreItem(id: 10765, name: "Sci-Fi & Fantasy"),
            GenreItem(id: 18, name: "Drama"),
        ]
    }
}

private struct MockSessionManager: SessionManagerProtocol {
    func saveSession(id: String) {}
    func getSession() -> String? { "mock_session" }
    func clearSession() {}
    var isLoggedIn: Bool { true }
}

// MARK: - Previews

#Preview("Loaded") {
    ProfileView(viewModel: ProfileViewModel(
        service: MockProfileService(),
        sessionManager: MockSessionManager(),
        onLogout: {}
    ), onGoToWatchlist: {})
}

#Preview("Loading") {
    ProfileView(viewModel: ProfileViewModel(
        service: MockProfileService(shouldHang: true),
        sessionManager: MockSessionManager(),
        onLogout: {}
    ), onGoToWatchlist: {})
}

#Preview("Error") {
    ProfileView(viewModel: ProfileViewModel(
        service: MockProfileService(shouldFail: true),
        sessionManager: MockSessionManager(),
        onLogout: {}
    ), onGoToWatchlist: {})
}
