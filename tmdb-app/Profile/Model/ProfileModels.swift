//
//  ProfileModels.swift
//  tmdb-app
//

import Foundation

struct AccountProfile: Decodable {
    let id: Int
    let username: String
    let name: String
    let avatar: Avatar
    let languageCode: String?
    let regionCode: String?
    let includeAdult: Bool

    enum CodingKeys: String, CodingKey {
        case id, username, name, avatar
        case languageCode = "iso_639_1"
        case regionCode = "iso_3166_1"
        case includeAdult = "include_adult"
    }

    // Memberwise init used by previews / tests
    init(id: Int, username: String, name: String, avatar: Avatar,
         languageCode: String? = nil, regionCode: String? = nil, includeAdult: Bool = false) {
        self.id = id; self.username = username; self.name = name
        self.avatar = avatar; self.languageCode = languageCode
        self.regionCode = regionCode; self.includeAdult = includeAdult
    }

    struct Avatar: Decodable {
        let gravatar: Gravatar
        let tmdb: TMDBAvatar

        struct Gravatar: Decodable {
            let hash: String
        }

        struct TMDBAvatar: Decodable {
            let avatarPath: String?
            enum CodingKeys: String, CodingKey {
                case avatarPath = "avatar_path"
            }
        }
    }
}

struct RatedMovie: Decodable {
    let id: Int
    let rating: Double
    let genreIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id, rating
        case genreIds = "genre_ids"
    }
}

struct RatedTVShow: Decodable {
    let id: Int
    let rating: Double
    let genreIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id, rating
        case genreIds = "genre_ids"
    }
}

struct GenreItem: Decodable {
    let id: Int
    let name: String
}

struct GenreListResponse: Decodable {
    let genres: [GenreItem]
}

struct RatedResponse<T: Decodable>: Decodable {
    let results: [T]
}
