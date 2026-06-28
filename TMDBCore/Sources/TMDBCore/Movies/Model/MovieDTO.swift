import Foundation

struct PopularMovieDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
}

struct PopularMoviesResponseDTO: Decodable {
    let results: [PopularMovieDTO]
    let page: Int
    let totalPages: Int
}

struct MovieDetailDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let backdropPath: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [MovieGenreDTO]
    let tagline: String?
    let status: String?
    let budget: Int?
    let revenue: Int?
}

struct MovieGenreDTO: Decodable {
    let id: Int
    let name: String
}

struct CreditsResponseDTO: Decodable {
    let cast: [CastMemberDTO]
}

struct CastMemberDTO: Decodable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

struct ReviewsResponseDTO: Decodable {
    let results: [ReviewDTO]
    let totalResults: Int
}

struct ReviewDTO: Decodable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?
    let authorDetails: AuthorDetailsDTO?

    struct AuthorDetailsDTO: Decodable {
        let rating: Double?
        let avatarPath: String?
    }
}
