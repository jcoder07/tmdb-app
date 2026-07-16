import Foundation

public struct SeriesDetail: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let overview: String
    public let backdropURL: URL?
    public let posterURL: URL?
    public let firstAirDate: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let numberOfSeasons: Int
    public let numberOfEpisodes: Int
    public let genres: [Genre]
    public let tagline: String?
    public let status: String?

    public init(
        id: Int, name: String, overview: String,
        backdropURL: URL?, posterURL: URL?, firstAirDate: String?,
        voteAverage: Double, voteCount: Int,
        numberOfSeasons: Int, numberOfEpisodes: Int,
        genres: [Genre], tagline: String?, status: String?
    ) {
        self.id = id
        self.name = name
        self.overview = overview
        self.backdropURL = backdropURL
        self.posterURL = posterURL
        self.firstAirDate = firstAirDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.numberOfSeasons = numberOfSeasons
        self.numberOfEpisodes = numberOfEpisodes
        self.genres = genres
        self.tagline = tagline
        self.status = status
    }
}

extension SeriesDetail {
    init(_ dto: SeriesDetailDTO) {
        id = dto.id
        name = dto.name
        overview = dto.overview
        backdropURL = dto.backdropPath.flatMap { Constants.Urls.backdrop(path: $0) }
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        firstAirDate = dto.firstAirDate
        voteAverage = dto.voteAverage
        voteCount = dto.voteCount
        numberOfSeasons = dto.numberOfSeasons
        numberOfEpisodes = dto.numberOfEpisodes
        genres = dto.genres.map(Genre.init)
        tagline = dto.tagline
        status = dto.status
    }
}
