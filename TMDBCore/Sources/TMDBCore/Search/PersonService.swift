import Foundation

public protocol PersonServiceProtocol: Sendable {
    func fetchDetail(id: Int) async throws -> PersonDetail
    func fetchCombinedCredits(id: Int) async throws -> (movies: [Movie], series: [Series])
    func fetchPopular(page: Int) async throws -> [PersonSummary]
}

public final class PersonService: PersonServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchDetail(id: Int) async throws -> PersonDetail {
        let resource = Resource(url: Constants.Urls.personDetail(id: id), modelType: PersonDetailDTO.self)
        return PersonDetail(try await httpClient.load(resource))
    }

    public func fetchCombinedCredits(id: Int) async throws -> (movies: [Movie], series: [Series]) {
        let resource = Resource(url: Constants.Urls.personCombinedCredits(id: id), modelType: CombinedCreditsResponseDTO.self)
        let dto = try await httpClient.load(resource)
        let movies = dto.cast
            .filter { $0.mediaType == "movie" }
            .compactMap { item -> Movie? in
                guard let title = item.title else { return nil }
                return Movie(
                    id: item.id,
                    title: title,
                    posterURL: item.posterPath.flatMap { Constants.Urls.poster(path: $0) },
                    voteAverage: item.voteAverage,
                    releaseDate: item.releaseDate
                )
            }
        let series = dto.cast
            .filter { $0.mediaType == "tv" }
            .compactMap { item -> Series? in
                guard let name = item.name else { return nil }
                return Series(
                    id: item.id,
                    name: name,
                    posterURL: item.posterPath.flatMap { Constants.Urls.poster(path: $0) },
                    voteAverage: item.voteAverage,
                    firstAirDate: item.firstAirDate
                )
            }
        return (movies: movies, series: series)
    }

    public func fetchPopular(page: Int) async throws -> [PersonSummary] {
        let resource = Resource(url: Constants.Urls.popularPeople(page: page), modelType: PopularPeopleResponseDTO.self)
        return try await httpClient.load(resource).results.map(PersonSummary.init)
    }
}
