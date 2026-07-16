import Foundation

public protocol SeriesDetailServiceProtocol: Sendable {
    func fetchSeriesDetail(id: Int) async throws -> SeriesDetail
    func fetchCredits(id: Int) async throws -> [CastMember]
    func fetchReviews(id: Int) async throws -> [Review]
    func fetchAccountStates(seriesId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool)
    func markFavorite(accountId: Int, seriesId: Int, sessionId: String, isFavorite: Bool) async throws
    func markWatchlist(accountId: Int, seriesId: Int, sessionId: String, inWatchlist: Bool) async throws
    func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList]
    func addToList(listId: Int, seriesId: Int, sessionId: String) async throws
}

public final class SeriesDetailService: SeriesDetailServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchSeriesDetail(id: Int) async throws -> SeriesDetail {
        let resource = Resource(url: Constants.Urls.seriesDetail(id: id), modelType: SeriesDetailDTO.self)
        return SeriesDetail(try await httpClient.load(resource))
    }

    public func fetchCredits(id: Int) async throws -> [CastMember] {
        let resource = Resource(url: Constants.Urls.seriesCredits(id: id), modelType: CreditsResponseDTO.self)
        return try await httpClient.load(resource).cast.map(CastMember.init)
    }

    public func fetchReviews(id: Int) async throws -> [Review] {
        let resource = Resource(url: Constants.Urls.seriesReviews(id: id), modelType: ReviewsResponseDTO.self)
        return try await httpClient.load(resource).results.map(Review.init)
    }

    public func fetchAccountStates(seriesId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool) {
        let resource = Resource(url: Constants.Urls.seriesAccountStates(seriesId: seriesId, sessionId: sessionId), modelType: AccountStatesDTO.self)
        let dto = try await httpClient.load(resource)
        return (dto.favorite, dto.watchlist)
    }

    public func markFavorite(accountId: Int, seriesId: Int, sessionId: String, isFavorite: Bool) async throws {
        let body = MarkFavoriteRequest(seriesId: seriesId, isFavorite: isFavorite)
        let resource = try Resource(url: Constants.Urls.markFavorite(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }

    public func markWatchlist(accountId: Int, seriesId: Int, sessionId: String, inWatchlist: Bool) async throws {
        let body = MarkWatchlistRequest(seriesId: seriesId, inWatchlist: inWatchlist)
        let resource = try Resource(url: Constants.Urls.markWatchlist(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }

    public func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList] {
        let resource = Resource(url: Constants.Urls.accountLists(accountId: accountId, sessionId: sessionId), modelType: UserListsResponseDTO.self)
        return try await httpClient.load(resource).results.map(UserList.init)
    }

    public func addToList(listId: Int, seriesId: Int, sessionId: String) async throws {
        let body = AddToListRequest(mediaId: seriesId)
        let resource = try Resource(url: Constants.Urls.addToList(listId: listId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }
}
