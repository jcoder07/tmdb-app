//
//  WatchlistServiceTests.swift
//  TMDBCore
//
//  Created by Juan Fernandez on 28-07-26.
//

import Testing
import Foundation
@testable import TMDBCore

// MockHttpClient (Spy HttpClient) is defined in TestDoubles.swift

// MARK: - Tests

struct WatchlistServiceTests {

    private func makeSUT(client: MockHttpClient = MockHttpClient()) -> WatchlistService {
        WatchlistService(httpClient: client)
    }

    // MARK: fetchMovies

    @Test func fetchMoviesReturnsExpectedItems() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            WatchlistResponseDTO<WatchlistMovieDTO>(
                page: 1,
                results: [
                    WatchlistMovieDTO(id: 1, title: "Inception", overview: "A thief", posterPath: nil, voteAverage: 8.8, releaseDate: "2010-07-16"),
                    WatchlistMovieDTO(id: 2, title: "Interstellar", overview: "Space", posterPath: nil, voteAverage: 8.6, releaseDate: "2014-11-07")
                ],
                totalPages: 3
            )
        ]
        let sut = makeSUT(client: client)

        let result = try await sut.fetchMovies(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.count == 2)
        #expect(result.items[0].id == 1)
        #expect(result.items[0].title == "Inception")
        #expect(result.items[1].id == 2)
        #expect(result.totalPages == 3)
    }

    @Test func fetchMoviesReturnsEmptyList() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            WatchlistResponseDTO<WatchlistMovieDTO>(page: 1, results: [], totalPages: 0)
        ]
        let sut = makeSUT(client: client)

        let result = try await sut.fetchMovies(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.isEmpty)
        #expect(result.totalPages == 0)
    }

    @Test func fetchMoviesThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.invalidResponse
        let sut = makeSUT(client: client)

        await #expect(throws: NetworkError.self) {
            try await sut.fetchMovies(accountId: 123, sessionId: "session", page: 1)
        }
    }

    // MARK: fetchTVShows

    @Test func fetchTVShowsReturnsExpectedItems() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            WatchlistResponseDTO<WatchlistTVShowDTO>(
                page: 1,
                results: [
                    WatchlistTVShowDTO(id: 10, name: "Breaking Bad", overview: "Chemistry teacher", posterPath: nil, voteAverage: 9.5, firstAirDate: "2008-01-20")
                ],
                totalPages: 2
            )
        ]
        let sut = makeSUT(client: client)

        let result = try await sut.fetchTVShows(accountId: 123, sessionId: "session", page: 1)

        #expect(result.items.count == 1)
        #expect(result.items[0].id == 10)
        #expect(result.items[0].name == "Breaking Bad")
        #expect(result.totalPages == 2)
    }

    @Test func fetchTVShowsThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.badRequest
        let sut = makeSUT(client: client)

        await #expect(throws: NetworkError.self) {
            try await sut.fetchTVShows(accountId: 123, sessionId: "session", page: 1)
        }
    }

    // MARK: removeMovie

    @Test func removeMovieSucceeds() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            TMDBStatusResponse(success: true, statusCode: 1, statusMessage: "The item/record was updated successfully.")
        ]
        let sut = makeSUT(client: client)

        try await sut.removeMovie(accountId: 123, movieId: 456, sessionId: "session")

        #expect(client.capturedURLs.count == 1)
    }

    @Test func removeMovieThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.serverError("Internal Server Error")
        let sut = makeSUT(client: client)

        await #expect(throws: NetworkError.self) {
            try await sut.removeMovie(accountId: 123, movieId: 456, sessionId: "session")
        }
    }

    // MARK: removeTVShow

    @Test func removeTVShowSucceeds() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            TMDBStatusResponse(success: true, statusCode: 1, statusMessage: "The item/record was updated successfully.")
        ]
        let sut = makeSUT(client: client)

        try await sut.removeTVShow(accountId: 123, seriesId: 789, sessionId: "session")

        #expect(client.capturedURLs.count == 1)
    }

    @Test func removeTVShowThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.serverError("Internal Server Error")
        let sut = makeSUT(client: client)

        await #expect(throws: NetworkError.self) {
            try await sut.removeTVShow(accountId: 123, seriesId: 789, sessionId: "session")
        }
    }
}
