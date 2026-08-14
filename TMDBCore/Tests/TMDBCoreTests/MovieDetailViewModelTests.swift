import Testing
@testable import TMDBCore

// Uses SpyMovieDetailService, FakeSessionManager, MockAccountService from TestDoubles.swift

@MainActor
struct MovieDetailViewModelTests {

    private func makeSUT(
        movieId: Int = 1,
        service: any MovieDetailServiceProtocol = SpyMovieDetailService(),
        accountService: (any AccountServiceProtocol)? = nil,
        sessionManager: (any SessionManagerProtocol)? = nil
    ) -> MovieDetailViewModel {
        MovieDetailViewModel(movieId: movieId, service: service, accountService: accountService, sessionManager: sessionManager)
    }

    // MARK: - load()

    @Test func loadFetchesDetailCreditsAndReviewsConcurrently_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.creditsToReturn = [makeCastMember(id: 1), makeCastMember(id: 2)]
        spy.reviewsToReturn = [makeReview(id: "r1")]
        let sut = makeSUT(movieId: 42, service: spy)

        await sut.load()

        #expect(spy.fetchDetailCalls == [42])
        #expect(spy.fetchCreditsCalls == [42])
        #expect(spy.fetchReviewsCalls == [42])
        #expect(sut.cast.count == 2)
        #expect(sut.reviews.count == 1)
        #expect(sut.detail != nil)
    }

    @Test func loadSetsErrorMessageOnFailure_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.errorToThrow = NetworkError.badRequest
        let sut = makeSUT(service: spy)

        await sut.load()

        #expect(sut.errorMessage != nil)
        #expect(sut.detail == nil)
        #expect(sut.isLoading == false)
    }

    @Test func loadGuardsAgainstConcurrentCalls_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let sut = makeSUT(service: spy)
        sut.isLoading = true

        await sut.load()

        #expect(spy.fetchDetailCalls.isEmpty)
    }

    @Test func loadSetsIsLoadingFalseOnSuccess_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let sut = makeSUT(service: spy)

        await sut.load()

        #expect(sut.isLoading == false)
    }

    // MARK: - Cast display logic

    @Test func displayedCastDefaultsToFirst6Members_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.creditsToReturn = (0..<10).map { makeCastMember(id: $0) }
        let sut = makeSUT(service: spy)

        await sut.load()

        #expect(sut.displayedCast.count == 6)
    }

    @Test func displayedCastShowsAllWhenShowFullCastEnabled_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.creditsToReturn = (0..<10).map { makeCastMember(id: $0) }
        let sut = makeSUT(service: spy)

        await sut.load()
        sut.showFullCast = true

        #expect(sut.displayedCast.count == 10)
    }

    @Test func displayedCastClampsBackToSixWhenShowFullCastDisabled_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.creditsToReturn = (0..<10).map { makeCastMember(id: $0) }
        let sut = makeSUT(service: spy)

        await sut.load()
        sut.showFullCast = true
        sut.showFullCast = false

        #expect(sut.displayedCast.count == 6)
    }

    // MARK: - Account state loading

    @Test func loadFetchesAccountStatesWhenSessionAvailable_usingMockAccountService() async {
        let spy = SpyMovieDetailService()
        spy.accountStatesToReturn = (isFavorite: true, isInWatchlist: true)

        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session-123")

        let mockAccount = MockAccountService()
        mockAccount.expectedFetchDetailsCount = 1

        let sut = makeSUT(service: spy, accountService: mockAccount, sessionManager: fakeSession)

        await sut.load()

        #expect(sut.isFavorite == true)
        #expect(sut.isInWatchlist == true)
        mockAccount.verify()
    }

    @Test func loadDoesNotFetchAccountStatesWithoutSession_usingSpyService() async {
        // No sessionManager passed -> loadAccountStates returns early
        let spy = SpyMovieDetailService()
        spy.accountStatesToReturn = (isFavorite: true, isInWatchlist: true)
        let sut = makeSUT(service: spy, accountService: nil, sessionManager: nil)

        await sut.load()

        #expect(sut.isFavorite == false)
        #expect(sut.isInWatchlist == false)
    }

    // MARK: - toggleFavorite()

    @Test func toggleFavoriteCallsServiceWithCorrectArgs_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let mockAccount = MockAccountService()
        mockAccount.expectedFetchDetailsCount = 1

        let sut = makeSUT(movieId: 99, service: spy, accountService: mockAccount, sessionManager: fakeSession)

        await sut.toggleFavorite()

        #expect(spy.markFavoriteCalls.count == 1)
        #expect(spy.markFavoriteCalls[0].movieId == 99)
        #expect(spy.markFavoriteCalls[0].isFavorite == true)  // toggled from false
        mockAccount.verify()
    }

    @Test func toggleFavoriteRevertsStateOnError_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.accountStatesToReturn = (isFavorite: true, isInWatchlist: false)
        spy.markErrorToThrow = NetworkError.serverError("Failed")
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let mockAccount = MockAccountService()

        let sut = makeSUT(service: spy, accountService: mockAccount, sessionManager: fakeSession)
        await sut.load()                // sets isFavorite = true from accountStates

        await sut.toggleFavorite()     // toggles to false, but service throws

        #expect(sut.isFavorite == true)  // reverted back
        #expect(sut.feedbackMessage == "Failed to update favorites.")
        #expect(sut.isTogglingFavorite == false)
    }

    @Test func toggleFavoriteDoesNothingWithoutSession_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let sut = makeSUT(service: spy, accountService: StubAccountService(), sessionManager: nil)

        await sut.toggleFavorite()

        #expect(spy.markFavoriteCalls.isEmpty)
    }

    // MARK: - toggleWatchlist()

    @Test func toggleWatchlistCallsServiceWithCorrectArgs_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let mockAccount = MockAccountService()
        mockAccount.expectedFetchDetailsCount = 1

        let sut = makeSUT(movieId: 55, service: spy, accountService: mockAccount, sessionManager: fakeSession)

        await sut.toggleWatchlist()

        #expect(spy.markWatchlistCalls.count == 1)
        #expect(spy.markWatchlistCalls[0].movieId == 55)
        #expect(spy.markWatchlistCalls[0].inWatchlist == true)  // toggled from false
        mockAccount.verify()
    }

    @Test func toggleWatchlistRevertsStateOnError_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.markErrorToThrow = NetworkError.badRequest
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let mockAccount = MockAccountService()

        let sut = makeSUT(service: spy, accountService: mockAccount, sessionManager: fakeSession)

        await sut.toggleWatchlist()

        #expect(sut.isInWatchlist == false)
        #expect(sut.feedbackMessage == "Failed to update watchlist.")
    }

    // MARK: - Account ID caching

    @Test func accountIdIsCachedAfterFirstFetch_usingMockAccountService() async {
        // MockAccountService expects fetchAccountDetails to be called exactly ONCE
        // even though load() + toggleFavorite() both go through resolvedAccountId.
        let spy = SpyMovieDetailService()
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let mockAccount = MockAccountService()
        mockAccount.expectedFetchDetailsCount = 1

        let sut = makeSUT(service: spy, accountService: mockAccount, sessionManager: fakeSession)
        await sut.load()          // first: fetches + caches accountId
        await sut.toggleFavorite() // second: uses cachedAccountId, no new fetch

        mockAccount.verify()
    }

    // MARK: - addToList()

    @Test func addToListCallsServiceAndSetsFeedbackMessage_usingSpyService() async {
        let spy = SpyMovieDetailService()
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let sut = makeSUT(movieId: 10, service: spy, sessionManager: fakeSession)

        await sut.addToList(listId: 7)

        #expect(spy.addToListCalls.count == 1)
        #expect(spy.addToListCalls[0].listId == 7)
        #expect(spy.addToListCalls[0].movieId == 10)
        #expect(sut.feedbackMessage == "Movie added to list.")
    }

    @Test func addToListSetFailureFeedbackOnError_usingSpyService() async {
        let spy = SpyMovieDetailService()
        spy.errorToThrow = NetworkError.serverError("Denied")
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "sess")
        let sut = makeSUT(service: spy, sessionManager: fakeSession)

        await sut.addToList(listId: 1)

        #expect(sut.feedbackMessage == "Failed to add movie to list.")
    }
}
