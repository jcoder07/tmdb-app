import Foundation

public protocol SeriesServiceProtocol: Sendable {
    func fetchPopularSeries(page: Int) async throws -> SeriesPage
}

public final class SeriesService: SeriesServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchPopularSeries(page: Int) async throws -> SeriesPage {
        let resource = Resource(url: Constants.Urls.popularSeries(page: page), modelType: PopularSeriesResponseDTO.self)
        return SeriesPage(try await httpClient.load(resource))
    }
}
