//
//  ProfileViewModel.swift
//  tmdb-app
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ProfileServiceProtocol
    private let sessionManager: SessionManagerProtocol
    private let onLogout: () -> Void

    init(
        service: ProfileServiceProtocol,
        sessionManager: SessionManagerProtocol,
        onLogout: @escaping () -> Void
    ) {
        self.service = service
        self.sessionManager = sessionManager
        self.onLogout = onLogout
    }

    func load() async {
        guard let sessionId = sessionManager.getSession() else { return }
        isLoading = true
        errorMessage = nil
        do {
            let account = try await service.fetchAccountDetails(sessionId: sessionId)
            async let moviesTask = service.fetchRatedMovies(accountId: account.id, sessionId: sessionId)
            async let tvTask = service.fetchRatedTVShows(accountId: account.id, sessionId: sessionId)
            async let genresTask = service.fetchMovieGenres()
            let (movies, tvShows, genres) = try await (moviesTask, tvTask, genresTask)
            profile = buildProfile(account: account, movies: movies, tvShows: tvShows, genres: genres)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        sessionManager.clearSession()
        onLogout()
    }

    private func buildProfile(
        account: AccountProfile,
        movies: [RatedMovie],
        tvShows: [RatedTVShow],
        genres: [GenreItem]
    ) -> UserProfile {
        let avgMovie = movies.isEmpty ? 0.0 : (movies.map(\.rating).reduce(0, +) / Double(movies.count)) * 10
        let avgTV = tvShows.isEmpty ? 0.0 : (tvShows.map(\.rating).reduce(0, +) / Double(tvShows.count)) * 10

        let distribution: [RatingBar] = (1...10).map { rating in
            RatingBar(rating: rating, count: movies.filter { Int($0.rating) == rating }.count)
        }

        let genreColors: [Color] = [Color(hex: "E8820C"), Color(hex: "C9873B"), Color(hex: "E8C49A")]
        let genreMap = Dictionary(uniqueKeysWithValues: genres.map { ($0.id, $0.name) })
        var genreCounts: [Int: Int] = [:]
        movies.flatMap(\.genreIds).forEach { genreCounts[$0, default: 0] += 1 }
        let total = genreCounts.values.reduce(0, +)
        let topGenres: [GenreSlice] = genreCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .enumerated()
            .compactMap { index, pair in
                guard let name = genreMap[pair.key] else { return nil }
                let pct = total > 0 ? Double(pair.value) / Double(total) : 0
                return GenreSlice(name: name, color: genreColors[index], percentage: pct)
            }

        let displayName = account.name.isEmpty ? account.username : account.name

        let avatarURLString: String?
        if let tmdbPath = account.avatar.tmdb.avatarPath, !tmdbPath.isEmpty {
            avatarURLString = "https://image.tmdb.org/t/p/w185\(tmdbPath)"
        } else {
            avatarURLString = "https://www.gravatar.com/avatar/\(account.avatar.gravatar.hash)?s=185&d=404"
        }

        return UserProfile(
            username: displayName,
            avatarPath: avatarURLString,
            memberSince: "",
            avgMovieScore: avgMovie,
            avgTVScore: avgTV,
            totalEdits: 0,
            totalRatings: movies.count + tvShows.count,
            ratingDistribution: distribution,
            topGenres: topGenres
        )
    }
}
