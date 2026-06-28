import Foundation

struct AccountProfileDTO: Decodable {
    let id: Int
    let username: String
    let name: String
    let avatar: AvatarDTO
    let languageCode: String?
    let regionCode: String?
    let includeAdult: Bool

    enum CodingKeys: String, CodingKey {
        case id, username, name, avatar
        case languageCode = "iso_639_1"
        case regionCode = "iso_3166_1"
        case includeAdult
    }

    struct AvatarDTO: Decodable {
        let gravatar: GravatarDTO
        let tmdb: TMDBProfileDTO

        struct GravatarDTO: Decodable {
            let hash: String
        }

        struct TMDBProfileDTO: Decodable {
            let avatarPath: String?
        }
    }
}

struct RatedMovieDTO: Decodable {
    let id: Int
    let rating: Double
    let genreIds: [Int]
}

struct RatedTVShowDTO: Decodable {
    let id: Int
    let rating: Double
    let genreIds: [Int]
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}

struct GenreListResponseDTO: Decodable {
    let genres: [GenreDTO]
}

struct RatedResponseDTO<T: Decodable>: Decodable {
    let results: [T]
}
