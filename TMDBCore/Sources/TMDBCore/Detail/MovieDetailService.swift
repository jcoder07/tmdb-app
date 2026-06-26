import Foundation

public protocol MovieDetailServiceProtocol {
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchCredits(id: Int) async throws -> [CastMember]
    func fetchReviews(id: Int) async throws -> [Review]
}

public final class MovieDetailService: MovieDetailServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let resource = Resource(url: Constants.Urls.movieDetail(id: id), modelType: MovieDetailDTO.self)
        return MovieDetail(try await httpClient.load(resource))
    }

    public func fetchCredits(id: Int) async throws -> [CastMember] {
        let resource = Resource(url: Constants.Urls.movieCredits(id: id), modelType: CreditsResponseDTO.self)
        return try await httpClient.load(resource).cast.map(CastMember.init)
    }

    public func fetchReviews(id: Int) async throws -> [Review] {
        let resource = Resource(url: Constants.Urls.movieReviews(id: id), modelType: ReviewsResponseDTO.self)
        return try await httpClient.load(resource).results.map(Review.init)
    }
}
