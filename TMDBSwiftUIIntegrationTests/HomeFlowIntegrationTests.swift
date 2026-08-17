import Foundation
import Testing
import TMDBCore
@testable import TMDBSwiftUI

extension TMDBSwiftUIIntegrationTests {

@Suite
struct HomeFlowIntegrationTests {

    /// `/discover/movie` is shared by the "streaming" (flatrate) and "free" sections; only the
    /// `with_watch_monetization_types` query distinguishes them.
    private func stubDiscoverMovies(on stack: IntegrationStack, monetizationType: String, ids: [Int]) {
        stack.stub(
            path: "/discover/movie",
            matchingQuery: { $0.contains(URLQueryItem(name: "with_watch_monetization_types", value: monetizationType)) },
            json: Fixtures.popularMovies(page: 1, totalPages: 1, ids: ids)
        )
    }

    private func stubAllFourSections(on stack: IntegrationStack) {
        stack.stub(path: "/trending/all/day", json: Fixtures.multiSearch(movieIds: [1], personIds: [99]))
        stack.stub(path: "/movie/popular", json: Fixtures.popularMovies(page: 1, totalPages: 1, ids: [2]))
        stubDiscoverMovies(on: stack, monetizationType: "flatrate", ids: [3])
        stubDiscoverMovies(on: stack, monetizationType: "free", ids: [4])
    }

    @Test func loadResolvesAllFourSectionsFromDistinctFixtures() async {
        let stack = IntegrationStack()
        stubAllFourSections(on: stack)

        let viewModel = await stack.makeHomeViewModel()
        await viewModel.load()

        #expect(await viewModel.trailerItems.map(\.id) == ["movie-2"])
        #expect(await viewModel.popularItems.map(\.id) == ["movie-3"])
        #expect(await viewModel.freeItems.map(\.id) == ["movie-4"])
        #expect(await viewModel.errorMessage == nil)
    }

    @Test func loadFiltersPeopleOutOfTrending() async {
        let stack = IntegrationStack()
        stubAllFourSections(on: stack)

        let viewModel = await stack.makeHomeViewModel()
        await viewModel.load()

        let trending = await viewModel.trendingItems
        #expect(trending.map(\.id) == ["movie-1"])
    }

    @Test func oneFailingSectionFailsTheWholeConcurrentLoad() async {
        // HomeViewModel.load() awaits all four `async let` tasks as a single tuple, so one
        // failing section fails the whole group rather than partially populating state.
        let stack = IntegrationStack()
        stack.stub(path: "/trending/all/day", json: Fixtures.malformedMovies)
        stack.stub(path: "/movie/popular", json: Fixtures.popularMovies(page: 1, totalPages: 1, ids: [2]))
        stubDiscoverMovies(on: stack, monetizationType: "flatrate", ids: [3])
        stubDiscoverMovies(on: stack, monetizationType: "free", ids: [4])

        let viewModel = await stack.makeHomeViewModel()
        await viewModel.load()

        #expect(await viewModel.errorMessage == NetworkError.decodingError.localizedDescription)
        #expect(await viewModel.trailerItems.isEmpty)
        #expect(await viewModel.popularItems.isEmpty)
        #expect(await viewModel.freeItems.isEmpty)
    }
}

}
