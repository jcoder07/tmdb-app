//
//  ProfileView.swift
//  tmdb-app
//

import SwiftUI
import Charts

// MARK: - Models

struct UserProfile {
    let username: String
    let avatarPath: String?
    let avgMovieScore: Double
    let avgTVScore: Double
    let totalMovieRatings: Int
    let totalTVRatings: Int
    let ratingDistribution: [RatingBar]
    let topGenres: [GenreSlice]
    let accentHex: String
}

struct RatingBar: Identifiable {
    let id = UUID()
    let rating: Int
    let count: Int
}

struct GenreSlice: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let percentage: Double
}

// MARK: - Preview Data

extension UserProfile {
    static let preview = UserProfile(
        username: "Juanjo07",
        avatarPath: nil,
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
            GenreSlice(name: "Action",     color: Color(hex: "01B4E4").opacity(1.00), percentage: 0.35),
            GenreSlice(name: "Drama",      color: Color(hex: "01B4E4").opacity(0.81), percentage: 0.25),
            GenreSlice(name: "Adventure",  color: Color(hex: "01B4E4").opacity(0.62), percentage: 0.20),
            GenreSlice(name: "Comedy",     color: Color(hex: "01B4E4").opacity(0.44), percentage: 0.12),
            GenreSlice(name: "Thriller",   color: Color(hex: "01B4E4").opacity(0.25), percentage: 0.08),
        ],
        accentHex: "01B4E4"
    )
}

// MARK: - ProfileView

struct ProfileView: View {

    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert = false

    private var profile: UserProfile { viewModel.profile ?? .preview }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if let message = viewModel.errorMessage, viewModel.profile == nil {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        
                        Text(message)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.black.opacity(0.8))
                        }
                        .padding(.top, 56)
                        .padding(.trailing, 16)
                    }
       
            } else {
                mainScrollView
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

    private var mainScrollView: some View {
        VStack(spacing: 0) {
            headerSection
                .fixedSize(horizontal: false, vertical: true)
            ScrollView {
                contentSection
            }
            .background(Color(.systemGroupedBackground))
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            // Fondo degradado azul oscuro como TMDB
            LinearGradient(
                colors: [Color(hex: "0D253F"), Color(hex: "1A3A5C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)

            // Decoración diagonal (líneas naranjas como TMDB)
            diagonalDecorations

            // Botón cerrar
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 56)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Contenido del header
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 20) {
                    avatarView

                    Text(profile.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                HStack(alignment: .center, spacing: 16) {
                    scoreCircle(
                        value: profile.avgMovieScore,
                        label: "Average Movie Score"
                    )

                    scoreCircle(
                        value: profile.avgTVScore,
                        label: "Average TV Score"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var avatarView: some View {
        AsyncImage(url: profile.avatarPath.flatMap { URL(string: $0) }) { phase in
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

    private func scoreCircle(value: Double, label: LocalizedStringKey) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        value > 0 ? Color(hex: profile.accentHex) : Color.gray,
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

    // Líneas diagonales decorativas estilo TMDB
    private var diagonalDecorations: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: profile.accentHex).opacity(0.7))
                .frame(width: 6, height: 60)
                .rotationEffect(.degrees(-45))
                .offset(x: -40, y: 20)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: profile.accentHex).opacity(0.5))
                .frame(width: 6, height: 40)
                .rotationEffect(.degrees(-45))
                .offset(x: -70, y: 10)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: profile.accentHex).opacity(0.6))
                .frame(width: 6, height: 50)
                .rotationEffect(.degrees(-45))
                .offset(x: -15, y: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .clipped()
    }

    // MARK: - Content / Stats

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Stats")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 4)

            HStack(spacing: 16) {
                statCard(title: "Rated Movies", value: "\(profile.totalMovieRatings)")
                statCard(title: "Rated TV", value: "\(profile.totalTVRatings)")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            ratingOverviewCard
                .padding(.horizontal, 16)
                .padding(.top, 16)

            genresCard
                .padding(.horizontal, 16)
                .padding(.top, 16)

            logoutButton
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
        }
    }

    private func statCard(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(hex: profile.accentHex))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var ratingOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating Overview")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Chart(profile.ratingDistribution) { bar in
                BarMark(
                    x: .value("Rating", "\(bar.rating)"),
                    y: .value("Count", bar.count)
                )
                .foregroundStyle(Color(hex: profile.accentHex))
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

    private var genresCard: some View {
        HStack(spacing: 20) {
            ZStack {
                ForEach(Array(donutSegments().enumerated()), id: \.offset) { _, segment in
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

                ForEach(profile.topGenres) { genre in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(genre.color)
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

    private func donutSegments() -> [(start: Double, end: Double, color: Color)] {
        var result: [(start: Double, end: Double, color: Color)] = []
        var current = 0.0
        for genre in profile.topGenres {
            let end = current + genre.percentage
            result.append((start: current, end: end, color: genre.color))
            current = end
        }
        return result
    }

    private var logoutButton: some View {
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
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview Mocks

private struct MockProfileService: ProfileServiceProtocol {
    var shouldFail = false
    var shouldHang = false

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        if shouldHang { try await Task.sleep(for: .seconds(100)) }
        if shouldFail { throw URLError(.badServerResponse) }
        return AccountProfile(
            id: 6445638,
            username: "mduranx64",
            name: "Miguel",
            avatar: AccountProfile.Avatar(
                gravatar: AccountProfile.Avatar.Gravatar(hash: "701f890836bf668eef5bae3c305e3b31"),
                tmdb: AccountProfile.Avatar.TMDBAvatar(avatarPath: nil)
            ),
            languageCode: "en",
            regionCode: "CL"
        )
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
    ))
}

#Preview("Loading") {
    ProfileView(viewModel: ProfileViewModel(
        service: MockProfileService(shouldHang: true),
        sessionManager: MockSessionManager(),
        onLogout: {}
    ))
}

#Preview("Error") {
    ProfileView(viewModel: ProfileViewModel(
        service: MockProfileService(shouldFail: true),
        sessionManager: MockSessionManager(),
        onLogout: {}
    ))
}
