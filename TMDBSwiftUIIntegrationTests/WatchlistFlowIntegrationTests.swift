import Foundation
import Testing
import TMDBCore
@testable import TMDBSwiftUI

extension TMDBSwiftUIIntegrationTests {

@Suite
struct WatchlistFlowIntegrationTests {

    private static let accountId = 555

    private func stubAccountAndWatchlist(
        on stack: IntegrationStack,
        movieIds: [Int] = [10, 11],
        tvIds: [Int] = [20]
    ) {
        stack.stub(path: "/account", json: Fixtures.accountProfile(id: Self.accountId))
        stack.stub(
            path: "/account/\(Self.accountId)/watchlist/movies",
            json: Fixtures.watchlistMovies(page: 1, totalPages: 1, ids: movieIds)
        )
        stack.stub(
            path: "/account/\(Self.accountId)/watchlist/tv",
            json: Fixtures.watchlistTVShows(page: 1, totalPages: 1, ids: tvIds)
        )
    }

    @Test func loadFetchesAccountFirstThenMoviesAndTVConcurrently() async {
        let stack = IntegrationStack(seedSessionId: "session-fixture")
        stubAccountAndWatchlist(on: stack)

        let viewModel = await stack.makeWatchlistViewModel()
        await viewModel.load()

        #expect(await viewModel.movies.map(\.id) == [10, 11])
        #expect(await viewModel.tvShows.map(\.id) == [20])
        #expect(await viewModel.errorMessage == nil)

        let paths = stack.recordedRequests.map(\.url.path)
        #expect(paths.first?.hasSuffix("/account") == true)
        let remaining = paths.dropFirst()
        #expect(remaining.count == 2)
        #expect(remaining.contains { $0.hasSuffix("/account/\(Self.accountId)/watchlist/movies") })
        #expect(remaining.contains { $0.hasSuffix("/account/\(Self.accountId)/watchlist/tv") })
    }

    @Test func secondLoadReusesTheCachedAccountIdInsteadOfRefetching() async {
        // Proves AccountServiceCacheDecorator (SwiftUI-target only) actually caches:
        // two `load()` calls should record exactly one `/account` request.
        let stack = IntegrationStack(seedSessionId: "session-fixture")
        stubAccountAndWatchlist(on: stack)

        let viewModel = await stack.makeWatchlistViewModel()
        await viewModel.load()
        await viewModel.load()

        let accountRequests = stack.recordedRequests.filter { $0.url.path.hasSuffix("/account") }
        #expect(accountRequests.count == 1)
    }

    @Test func removeMoviePostsTheSnakeCasedBodyAndRemovesLocally() async throws {
        let stack = IntegrationStack(seedSessionId: "session-fixture")
        stubAccountAndWatchlist(on: stack, movieIds: [10, 11])
        stack.stub(path: "/account/\(Self.accountId)/watchlist", json: Fixtures.tmdbStatusOK)

        let viewModel = await stack.makeWatchlistViewModel()
        await viewModel.load()
        await viewModel.removeMovie(id: 10)

        #expect(await viewModel.movies.map(\.id) == [11])

        let removeRequest = try #require(stack.recordedRequests.last { $0.url.path.hasSuffix("/account/\(Self.accountId)/watchlist") })
        #expect(removeRequest.method == "POST")
        let body = try #require(removeRequest.body)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["media_id"] as? Int == 10)
        #expect(json["media_type"] as? String == "movie")
        #expect(json["watchlist"] as? Bool == false)
    }

    @Test func removeMovieRestoresTheItemWhenTheRequestFails() async {
        // TMDBStatusResponse's fields are all optional, so any well-formed JSON object
        // "succeeds" at decode time regardless of HTTP status. Only a response that fails
        // to parse as JSON at all drives the throwing path removeMovie's rollback depends on.
        let stack = IntegrationStack(seedSessionId: "session-fixture")
        stubAccountAndWatchlist(on: stack, movieIds: [10, 11])
        stack.stub(path: "/account/\(Self.accountId)/watchlist", json: "{ not valid json")

        let viewModel = await stack.makeWatchlistViewModel()
        await viewModel.load()
        await viewModel.removeMovie(id: 10)

        #expect(await viewModel.movies.map(\.id) == [10, 11])
    }
}

}
