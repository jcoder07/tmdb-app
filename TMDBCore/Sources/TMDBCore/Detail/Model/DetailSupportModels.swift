import Foundation

// MARK: - Internal DTOs

struct AccountStatesDTO: Decodable {
    let favorite: Bool
    let watchlist: Bool
}

struct TMDBStatusResponse: Decodable {
    let success: Bool?
    let statusCode: Int?
    let statusMessage: String?
}

struct MarkFavoriteRequest: Encodable {
    let mediaType: String
    let mediaId: Int
    let favorite: Bool

    init(movieId: Int, isFavorite: Bool) {
        mediaType = "movie"
        mediaId = movieId
        favorite = isFavorite
    }

    init(seriesId: Int, isFavorite: Bool) {
        mediaType = "tv"
        mediaId = seriesId
        favorite = isFavorite
    }
}

struct MarkWatchlistRequest: Encodable {
    let mediaType: String
    let mediaId: Int
    let watchlist: Bool

    init(movieId: Int, inWatchlist: Bool) {
        mediaType = "movie"
        mediaId = movieId
        watchlist = inWatchlist
    }

    init(seriesId: Int, inWatchlist: Bool) {
        mediaType = "tv"
        mediaId = seriesId
        watchlist = inWatchlist
    }
}

struct AddToListRequest: Encodable {
    let mediaId: Int
}

struct UserListDTO: Decodable {
    let id: Int
    let name: String
    let description: String
    let itemCount: Int
}

struct UserListsResponseDTO: Decodable {
    let results: [UserListDTO]
}

// MARK: - Public domain model

public struct UserList: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let description: String
    public let itemCount: Int

    public init(id: Int, name: String, description: String, itemCount: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.itemCount = itemCount
    }
}

extension UserList {
    init(_ dto: UserListDTO) {
        id = dto.id
        name = dto.name
        description = dto.description
        itemCount = dto.itemCount
    }
}
