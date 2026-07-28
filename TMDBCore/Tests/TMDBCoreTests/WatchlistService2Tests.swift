//
//  WatchlistService2Tests.swift
//  TMDBCore
//
//  Created by Juan Fernandez on 28-07-26.
//

// WHY IS THIS HARDER THAN WatchlistServiceTests?
//
// WatchlistService2 depends on the concrete `HttpClient` struct, not
// `HttpClientProtocol`. That means:
//
//   1. You can't pass a MockHttpClient — the type mismatch is a compile error.
//   2. You can't subclass HttpClient — it's a struct.
//   3. The only option is to intercept at the URLProtocol layer (below the
//      dependency), which requires:
//        - A global URLProtocol subclass with static state.
//        - Registering/unregistering it around every single test.
//        - Writing raw JSON strings instead of constructing DTOs.
//        - Accepting that tests cannot run safely in parallel (shared static).
//
// Compare this to WatchlistServiceTests where the mock is three lines and
// tests are fully isolated. That's the cost of skipping the protocol.

import Testing
import Foundation
@testable import TMDBCore

// MARK: - URL Protocol Stub

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private func makeOKResponse() -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://api.themoviedb.org")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
}

// MARK: - Tests

struct WatchlistService2Tests {

    private func makeSUT() -> WatchlistService2 {
        WatchlistService2(httpClient: HttpClient())
    }

    // MARK: fetchMovies

    @Test func fetchMoviesReturnsExpectedItems() async throws {
        // Must register globally — no way to scope this to a single URLSession instance
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        // Can't use internal DTOs here, so JSON must be written by hand
        let json = """
        {
            "page": 1,
            "results": [
                { "id": 1, "title": "Inception", "overview": "A thief",
                  "poster_path": null, "vote_average": 8.8, "release_date": "2010-07-16" },
                { "id": 2, "title": "Interstellar", "overview": "Space",
                  "poster_path": null, "vote_average": 8.6, "release_date": "2014-11-07" }
            ],
            "total_pages": 3
        }
        """
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data(json.utf8)) }

        let result = try await makeSUT().fetchMovies(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.count == 2)
        #expect(result.items[0].id == 1)
        #expect(result.items[0].title == "Inception")
        #expect(result.totalPages == 3)
    }

    @Test func fetchMoviesReturnsEmptyList() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        let json = #"{"page": 1, "results": [], "total_pages": 0}"#
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data(json.utf8)) }

        let result = try await makeSUT().fetchMovies(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.isEmpty)
        #expect(result.totalPages == 0)
    }

    @Test func fetchMoviesThrowsOnNetworkError() async {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: (any Error).self) {
            try await makeSUT().fetchMovies(accountId: 123, sessionId: "session", page: 1)
        }
    }

    // MARK: fetchTVShows

    @Test func fetchTVShowsReturnsExpectedItems() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        let json = """
        {
            "page": 1,
            "results": [
                { "id": 10, "name": "Breaking Bad", "overview": "Chemistry teacher",
                  "poster_path": null, "vote_average": 9.5, "first_air_date": "2008-01-20" }
            ],
            "total_pages": 2
        }
        """
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data(json.utf8)) }

        let result = try await makeSUT().fetchTVShows(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.count == 1)
        #expect(result.items[0].id == 10)
        #expect(result.items[0].name == "Breaking Bad")
        #expect(result.totalPages == 2)
    }

    @Test func fetchTVShowsThrowsOnNetworkError() async {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: (any Error).self) {
            try await makeSUT().fetchTVShows(accountId: 123, sessionId: "session", page: 1)
        }
    }

    // MARK: removeMovie

    @Test func removeMovieSucceeds() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        let json = #"{"success": true, "status_code": 1, "status_message": "Success."}"#
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data(json.utf8)) }

        try await makeSUT().removeMovie(accountId: 123, movieId: 456, sessionId: "session")
    }

    @Test func removeMovieThrowsOnNetworkError() async {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: (any Error).self) {
            try await makeSUT().removeMovie(accountId: 123, movieId: 456, sessionId: "session")
        }
    }

    // MARK: removeTVShow

    @Test func removeTVShowSucceeds() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        let json = #"{"success": true, "status_code": 1, "status_message": "Success."}"#
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data(json.utf8)) }

        try await makeSUT().removeTVShow(accountId: 123, seriesId: 789, sessionId: "session")
    }

    @Test func removeTVShowThrowsOnNetworkError() async {
        URLProtocol.registerClass(MockURLProtocol.self)
        defer { URLProtocol.unregisterClass(MockURLProtocol.self) }

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: (any Error).self) {
            try await makeSUT().removeTVShow(accountId: 123, seriesId: 789, sessionId: "session")
        }
    }
}
