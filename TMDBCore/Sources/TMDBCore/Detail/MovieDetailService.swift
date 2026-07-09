import Foundation

public protocol MovieDetailServiceProtocol: Sendable {
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchCredits(id: Int) async throws -> [CastMember]
    func fetchReviews(id: Int) async throws -> [Review]
    func fetchAccountStates(movieId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool)
    func markFavorite(accountId: Int, movieId: Int, sessionId: String, isFavorite: Bool) async throws
    func markWatchlist(accountId: Int, movieId: Int, sessionId: String, inWatchlist: Bool) async throws
    func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList]
    func addMovieToList(listId: Int, movieId: Int, sessionId: String) async throws
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

    public func fetchAccountStates(movieId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool) {
        let resource = Resource(url: Constants.Urls.accountStates(movieId: movieId, sessionId: sessionId), modelType: AccountStatesDTO.self)
        let dto = try await httpClient.load(resource)
        return (dto.favorite, dto.watchlist)
    }

    public func markFavorite(accountId: Int, movieId: Int, sessionId: String, isFavorite: Bool) async throws {
        let body = MarkFavoriteRequest(movieId: movieId, isFavorite: isFavorite)
        let resource = try Resource(url: Constants.Urls.markFavorite(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }

    public func markWatchlist(accountId: Int, movieId: Int, sessionId: String, inWatchlist: Bool) async throws {
        let body = MarkWatchlistRequest(movieId: movieId, inWatchlist: inWatchlist)
        let resource = try Resource(url: Constants.Urls.markWatchlist(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }

    public func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList] {
        let resource = Resource(url: Constants.Urls.accountLists(accountId: accountId, sessionId: sessionId), modelType: UserListsResponseDTO.self)
        return try await httpClient.load(resource).results.map(UserList.init)
    }

    public func addMovieToList(listId: Int, movieId: Int, sessionId: String) async throws {
        let body = AddToListRequest(mediaId: movieId)
        let resource = try Resource(url: Constants.Urls.addToList(listId: listId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }
}
