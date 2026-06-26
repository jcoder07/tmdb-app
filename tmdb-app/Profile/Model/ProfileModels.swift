//
//  ProfileModels.swift
//  tmdb-app
//

import Foundation
import SwiftUI
import TMDBCore

// MARK: - Account

struct AccountProfile {
    let id: Int
    let displayName: String
    let avatarURL: URL?
}

extension AccountProfile {
    init(_ dto: AccountProfileDTO) {
        id = dto.id
        displayName = dto.name.isEmpty ? dto.username : dto.name
        if let tmdbPath = dto.avatar.tmdb.avatarPath, !tmdbPath.isEmpty {
            avatarURL = Constants.Urls.poster(path: tmdbPath)
        } else {
            avatarURL = Constants.Urls.gravatar(hash: dto.avatar.gravatar.hash)
        }
    }
}

// MARK: - Rated Content

struct RatedMovie {
    let id: Int
    let rating: Double
    let genreIds: [Int]
}

extension RatedMovie {
    init(_ dto: RatedMovieDTO) {
        id = dto.id
        rating = dto.rating
        genreIds = dto.genreIds
    }
}

struct RatedTVShow {
    let id: Int
    let rating: Double
    let genreIds: [Int]
}

extension RatedTVShow {
    init(_ dto: RatedTVShowDTO) {
        id = dto.id
        rating = dto.rating
        genreIds = dto.genreIds
    }
}

// MARK: - Genre

struct GenreItem {
    let id: Int
    let name: String
}

extension GenreItem {
    init(_ dto: GenreDTO) {
        id = dto.id
        name = dto.name
    }
}

// MARK: - UI / Presentation Models

struct UserProfile {
    let username: String
    let avatarURL: URL?
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
