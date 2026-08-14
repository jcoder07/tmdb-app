import Testing
import Foundation
@testable import TMDBCore

// Uses MockHttpClient (Spy) from TestDoubles.swift

struct MoviesServiceTests {

    private func makeSUT(client: MockHttpClient = MockHttpClient()) -> MoviesService {
        MoviesService(httpClient: client)
    }

    // MARK: - fetchPopularMovies

    @Test func fetchMoviesReturnsCorrectlyMappedItems() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            PopularMoviesResponseDTO(
                results: [
                    PopularMovieDTO(id: 1, title: "Inception", posterPath: "/inc.jpg", backdropPath: nil, voteAverage: 8.8, releaseDate: "2010-07-16"),
                    PopularMovieDTO(id: 2, title: "Dune", posterPath: nil, backdropPath: nil, voteAverage: 7.9, releaseDate: "2021-10-22")
                ],
                page: 1,
                totalPages: 5
            )
        ]

        let result = try await makeSUT(client: client).fetchPopularMovies(page: 1)

        #expect(result.movies.count == 2)
        #expect(result.movies[0].id == 1)
        #expect(result.movies[0].title == "Inception")
        #expect(result.movies[1].id == 2)
        #expect(result.totalPages == 5)
        #expect(result.page == 1)
    }

    @Test func fetchMoviesBuildsURLWithCorrectPage_usingSpyClient() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            PopularMoviesResponseDTO(results: [], page: 2, totalPages: 3)
        ]

        _ = try await makeSUT(client: client).fetchPopularMovies(page: 2)

        // Spy assertion: the URL should contain page=2
        #expect(client.capturedURLs.count == 1)
        let urlString = client.capturedURLs[0].absoluteString
        #expect(urlString.contains("page=2"))
    }

    @Test func fetchMoviesThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.invalidResponse

        await #expect(throws: NetworkError.self) {
            try await makeSUT(client: client).fetchPopularMovies(page: 1)
        }
    }

    @Test func fetchMoviesEmptyPageReturnsEmptyList() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            PopularMoviesResponseDTO(results: [], page: 1, totalPages: 1)
        ]

        let result = try await makeSUT(client: client).fetchPopularMovies(page: 1)

        #expect(result.movies.isEmpty)
    }

    @Test func fetchMoviesMapsVoteAverageCorrectly() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            PopularMoviesResponseDTO(
                results: [PopularMovieDTO(id: 9, title: "High Rated", posterPath: nil, backdropPath: nil, voteAverage: 9.3, releaseDate: nil)],
                page: 1,
                totalPages: 1
            )
        ]

        let result = try await makeSUT(client: client).fetchPopularMovies(page: 1)

        #expect(result.movies[0].voteAverage == 9.3)
    }
}
