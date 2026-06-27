import Foundation

public protocol AccountServiceProtocol: Sendable {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie]
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow]
}

public final class AccountService: AccountServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        let resource = Resource(url: Constants.Urls.account(sessionId: sessionId), modelType: AccountProfileDTO.self)
        return AccountProfile(try await httpClient.load(resource))
    }

    public func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        let resource = Resource(url: Constants.Urls.ratedMovies(accountId: accountId, sessionId: sessionId), modelType: RatedResponseDTO<RatedMovieDTO>.self)
        return try await httpClient.load(resource).results.map(RatedMovie.init)
    }

    public func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        let resource = Resource(url: Constants.Urls.ratedTVShows(accountId: accountId, sessionId: sessionId), modelType: RatedResponseDTO<RatedTVShowDTO>.self)
        return try await httpClient.load(resource).results.map(RatedTVShow.init)
    }
}
