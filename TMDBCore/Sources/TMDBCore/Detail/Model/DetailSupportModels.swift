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

struct RemoveFromListRequest: Encodable {
    let mediaId: Int
}

struct CreateListRequest: Encodable {
    let name: String
    let description: String
    let language: String
}

struct CreateListResponseDTO: Decodable {
    let listId: Int?
    let success: Bool?
    let statusMessage: String?
}

struct ListItemDTO: Decodable {
    let id: Int
    let title: String?
    let name: String?
    let mediaType: String
    let posterPath: String?
    let voteAverage: Double
}

struct ListDetailDTO: Decodable {
    let id: Int
    let name: String
    let items: [ListItemDTO]
}

// MARK: - Public domain model

public struct ListItem: Identifiable, Sendable {
    public let id: Int
    public let displayTitle: String
    public let mediaType: String
    public let posterURL: URL?
    public let voteAverage: Double

    public init(id: Int, displayTitle: String, mediaType: String, posterURL: URL?, voteAverage: Double) {
        self.id = id
        self.displayTitle = displayTitle
        self.mediaType = mediaType
        self.posterURL = posterURL
        self.voteAverage = voteAverage
    }
}

extension ListItem {
    init(_ dto: ListItemDTO) {
        id = dto.id
        displayTitle = dto.title ?? dto.name ?? ""
        mediaType = dto.mediaType
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
    }
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
