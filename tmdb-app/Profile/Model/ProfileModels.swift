//
//  ProfileModels.swift
//  tmdb-app
//

import Foundation

struct AccountProfile: Decodable {
    let id: Int
    let username: String
    let avatar: Avatar

    struct Avatar: Decodable {
        let tmdb: TMDBAvatar

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
