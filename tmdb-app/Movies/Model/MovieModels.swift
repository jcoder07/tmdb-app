//
//  MovieModels.swift
//  tmdb-app
//

import Foundation
import TMDBCore

// MARK: - Popular Movie

struct Movie: Identifiable {
    let id: Int
    let title: String
    let posterURL: URL?
    let voteAverage: Double
    let releaseDate: String?
}

extension Movie {
    init(_ dto: PopularMovieDTO) {
        id = dto.id
        title = dto.title
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
    }
}

// MARK: - Movies Page

struct MoviesPage {
    let movies: [Movie]
    let page: Int
    let totalPages: Int
}

extension MoviesPage {
    init(_ dto: PopularMoviesResponseDTO) {
        movies = dto.results.map(Movie.init)
        page = dto.page
        totalPages = dto.totalPages
    }
}

// MARK: - Movie Detail

struct MovieDetail: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let backdropURL: URL?
    let posterURL: URL?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let tagline: String?
    let status: String?
    let budget: Int?
    let revenue: Int?
}

extension MovieDetail {
    init(_ dto: MovieDetailDTO) {
        id = dto.id
        title = dto.title
        overview = dto.overview
        backdropURL = dto.backdropPath.flatMap { Constants.Urls.backdrop(path: $0) }
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        releaseDate = dto.releaseDate
        voteAverage = dto.voteAverage
        voteCount = dto.voteCount
        runtime = dto.runtime
        genres = dto.genres.map(Genre.init)
        tagline = dto.tagline
        status = dto.status
        budget = dto.budget
        revenue = dto.revenue
    }
}

// MARK: - Genre

struct Genre: Identifiable {
    let id: Int
    let name: String
}

extension Genre {
    init(_ dto: MovieGenreDTO) {
        id = dto.id
        name = dto.name
    }
}

// MARK: - Cast

struct CastMember: Identifiable {
    let id: Int
    let name: String
    let character: String
    let profileURL: URL?
    let order: Int
}

extension CastMember {
    init(_ dto: CastMemberDTO) {
        id = dto.id
        name = dto.name
        character = dto.character
        profileURL = dto.profilePath.flatMap { Constants.Urls.poster(path: $0) }
        order = dto.order
    }
}

// MARK: - Review

struct Review: Identifiable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?
    let rating: Double?
}

extension Review {
    init(_ dto: ReviewDTO) {
        id = dto.id
        author = dto.author
        content = dto.content
        createdAt = dto.createdAt
        rating = dto.authorDetails?.rating
    }
}
