import Foundation
import Testing
import TMDBCore
@testable import TMDBSwiftUI

extension TMDBSwiftUIIntegrationTests {

@Suite
struct MoviesFlowIntegrationTests {

    @Test func loadDecodesTheFixtureThroughTheRealDTOAndPageState() async {
        let stack = IntegrationStack()
        stack.stub(
            path: "/movie/popular",
            matchingQuery: { $0.contains(URLQueryItem(name: "page", value: "1")) },
            json: Fixtures.popularMovies(page: 1, totalPages: 3, ids: [1, 2, 3])
        )

        let viewModel = await stack.makeMoviesViewModel()
        await viewModel.load()

        let movies = await viewModel.movies
        #expect(movies.map(\.id) == [1, 2, 3])
        #expect(movies.map(\.title) == ["Movie 1", "Movie 2", "Movie 3"])
        #expect(await viewModel.hasMorePages == true)
        #expect(await viewModel.errorMessage == nil)
    }

    @Test func loadNextPageRequestsPageTwoAppendsAndDeduplicates() async {
        let stack = IntegrationStack()
        stack.stub(
            path: "/movie/popular",
            matchingQuery: { $0.contains(URLQueryItem(name: "page", value: "1")) },
            json: Fixtures.popularMovies(page: 1, totalPages: 2, ids: [1, 2])
        )
        // Movie 2 overlaps with page 1 to prove de-duplication.
        stack.stub(
            path: "/movie/popular",
            matchingQuery: { $0.contains(URLQueryItem(name: "page", value: "2")) },
            json: Fixtures.popularMovies(page: 2, totalPages: 2, ids: [2, 3])
        )

        let viewModel = await stack.makeMoviesViewModel()
        await viewModel.load()
        await viewModel.loadNextPage()

        let movies = await viewModel.movies
        #expect(movies.map(\.id) == [1, 2, 3])
        #expect(await viewModel.hasMorePages == false)

        let pageTwoRequest = stack.recordedRequests.last
        #expect(pageTwoRequest?.url.query?.contains("page=2") == true)
    }

    @Test func malformedResponseSurfacesAsAnErrorAndLeavesMoviesEmpty() async {
        let stack = IntegrationStack()
        stack.stub(path: "/movie/popular", json: Fixtures.malformedMovies)

        let viewModel = await stack.makeMoviesViewModel()
        await viewModel.load()

        #expect(await viewModel.movies.isEmpty)
        #expect(await viewModel.errorMessage == NetworkError.decodingError.localizedDescription)
    }
}

}
