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
    let createdAt: String?
    // Raw value from API — may be a string ("blue") or an integer theme ID (1, 2…)
    let accentColor: String?

    enum CodingKeys: String, CodingKey {
        case id, username, name, avatar
        case createdAt = "created_at"
        case accentColor = "accent_color"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(Int.self,    forKey: .id)
        username  = try c.decode(String.self, forKey: .username)
        name      = try c.decode(String.self, forKey: .name)
        avatar    = try c.decode(Avatar.self, forKey: .avatar)
        createdAt = try? c.decode(String.self, forKey: .createdAt)
        // Accept either a String ("blue") or an Int (TMDB theme ID)
        if let str = try? c.decode(String.self, forKey: .accentColor) {
            accentColor = str
        } else if let id = try? c.decode(Int.self, forKey: .accentColor) {
            accentColor = "\(id)"
        } else {
            accentColor = nil
        }
    }

    // Memberwise init used by previews / tests
    init(id: Int, username: String, name: String, avatar: Avatar,
         createdAt: String? = nil, accentColor: String? = nil) {
        self.id = id; self.username = username; self.name = name
        self.avatar = avatar; self.createdAt = createdAt; self.accentColor = accentColor
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
