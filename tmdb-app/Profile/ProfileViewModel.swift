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
            async let movieGenresTask = service.fetchMovieGenres()
            async let tvGenresTask = service.fetchTVGenres()
            let (movies, tvShows, movieGenres, tvGenres) = try await (moviesTask, tvTask, movieGenresTask, tvGenresTask)
            let genres = (movieGenres + tvGenres).reduce(into: [Int: GenreItem]()) { $0[$1.id] = $1 }.map(\.value)
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
            let count = movies.filter { Int($0.rating) == rating }.count
                      + tvShows.filter { Int($0.rating) == rating }.count
            return RatingBar(rating: rating, count: count)
        }

        let accentHex = resolveAccentHex(account.accentColor)
        let genreMap = Dictionary(uniqueKeysWithValues: genres.map { ($0.id, $0.name) })
        var genreCounts: [Int: Int] = [:]
        movies.flatMap(\.genreIds).forEach { genreCounts[$0, default: 0] += 1 }
        tvShows.flatMap(\.genreIds).forEach { genreCounts[$0, default: 0] += 1 }
        let total = genreCounts.values.reduce(0, +)
        let sorted = genreCounts.sorted { $0.value > $1.value }.filter { genreMap[$0.key] != nil }
        let topGenres: [GenreSlice] = sorted.enumerated().compactMap { index, pair in
            guard let name = genreMap[pair.key] else { return nil }
            let pct = total > 0 ? Double(pair.value) / Double(total) : 0
            let opacity = sorted.count > 1
                ? 1.0 - Double(index) / Double(sorted.count - 1) * 0.75
                : 1.0
            return GenreSlice(name: name, color: Color(hex: accentHex).opacity(opacity), percentage: pct)
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
            avgMovieScore: avgMovie,
            avgTVScore: avgTV,
            totalMovieRatings: movies.count,
            totalTVRatings: tvShows.count,
            ratingDistribution: distribution,
            topGenres: topGenres,
            accentHex: accentHex
        )
    }

    // Maps TMDB color names, integer theme IDs, or hex strings to hex values used in the UI.
    private func resolveAccentHex(_ color: String?) -> String {
        guard let color else { return "01B4E4" }
        let key = color.lowercased().trimmingCharacters(in: .whitespaces)

        // TMDB integer theme IDs (e.g. accent_color: 1)
        let byId: [String: String] = [
            "0": "01B4E4",  // default / TMDB blue
            "1": "01B4E4",  // blue
            "2": "4CAF50",  // green
            "3": "E74C3C",  // red
            "4": "9B59B6",  // purple
            "5": "F1C40F",  // yellow
        ]
        if let mapped = byId[key] { return mapped }

        // TMDB named colors
        let byName: [String: String] = [
            "blue":    "01B4E4",
            "teal":    "01B4E4",
            "green":   "4CAF50",
            "red":     "E74C3C",
            "orange":  "E8820C",
            "purple":  "9B59B6",
            "yellow":  "F1C40F",
        ]
        if let mapped = byName[key] { return mapped }

        // Bare or prefixed hex string (#0068BC or 0068BC)
        return key.hasPrefix("#") ? String(key.dropFirst()) : key
    }
}
