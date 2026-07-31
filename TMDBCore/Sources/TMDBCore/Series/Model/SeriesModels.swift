import Foundation

public struct Series: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let posterURL: URL?
    public let backdropURL: URL?
    public let voteAverage: Double
    public let firstAirDate: String?

    public init(id: Int, name: String, posterURL: URL?, voteAverage: Double, firstAirDate: String?, backdropURL: URL? = nil) {
        self.id = id
        self.name = name
        self.posterURL = posterURL
        self.backdropURL = backdropURL
        self.voteAverage = voteAverage
        self.firstAirDate = firstAirDate
    }
}

extension Series {
    init(_ dto: PopularSeriesDTO) {
        id = dto.id
        name = dto.name
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        backdropURL = dto.backdropPath.flatMap { Constants.Urls.backdrop(path: $0) }
        voteAverage = dto.voteAverage
        firstAirDate = dto.firstAirDate
    }
}

public struct SeriesPage: Sendable {
    public let series: [Series]
    public let page: Int
    public let totalPages: Int

    public init(series: [Series], page: Int, totalPages: Int) {
        self.series = series
        self.page = page
        self.totalPages = totalPages
    }
}

extension SeriesPage {
    init(_ dto: PopularSeriesResponseDTO) {
        series = dto.results.map(Series.init)
        page = dto.page
        totalPages = dto.totalPages
    }
}
