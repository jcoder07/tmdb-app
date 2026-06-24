//
//  MovieModels.swift
//  tmdb-app
//

import Foundation

struct PopularMovie: Decodable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
}

struct PopularMoviesResponse: Decodable {
    let results: [PopularMovie]
    let page: Int
    let totalPages: Int
}

// MARK: - Movie Detail

struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let overview: String
    let backdropPath: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [MovieGenre]
    let tagline: String?
    let status: String?
    let budget: Int?
    let revenue: Int?
}

struct MovieGenre: Decodable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - Credits

struct CreditsResponse: Decodable {
    let cast: [CastMember]
}

struct CastMember: Decodable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

// MARK: - Reviews

struct ReviewsResponse: Decodable {
    let results: [Review]
    let totalResults: Int
}

struct Review: Decodable, Identifiable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?
    let authorDetails: AuthorDetails?

    struct AuthorDetails: Decodable {
        let rating: Double?
        let avatarPath: String?
    }
}
