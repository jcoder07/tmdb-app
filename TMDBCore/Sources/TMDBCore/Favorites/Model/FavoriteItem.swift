import Foundation

public struct FavoriteMovie: Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterURL: URL?
    public let voteAverage: Double
    public let releaseDate: String?

    public init(id: Int, title: String, overview: String, posterURL: URL?, voteAverage: Double, releaseDate: String?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterURL = posterURL
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
    }
}

extension FavoriteMovie {
    init(_ dto: FavoriteMovieDTO) {
        id = dto.id
        title = dto.title
        overview = dto.overview
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
    }
}

public struct FavoriteTVShow: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let overview: String
    public let posterURL: URL?
    public let voteAverage: Double
    public let firstAirDate: String?

    public init(id: Int, name: String, overview: String, posterURL: URL?, voteAverage: Double, firstAirDate: String?) {
        self.id = id
        self.name = name
        self.overview = overview
        self.posterURL = posterURL
        self.voteAverage = voteAverage
        self.firstAirDate = firstAirDate
    }
}

extension FavoriteTVShow {
    init(_ dto: FavoriteTVShowDTO) {
        id = dto.id
        name = dto.name
        overview = dto.overview
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        firstAirDate = dto.firstAirDate
    }
}
