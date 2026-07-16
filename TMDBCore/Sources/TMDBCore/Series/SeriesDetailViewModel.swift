import Observation

@MainActor
@Observable
public final class SeriesDetailViewModel {

    // MARK: - Content state
    public var detail: SeriesDetail?
    public private(set) var cast: [CastMember] = []       { didSet { recomputeDisplayedCast() } }
    public private(set) var displayedCast: [CastMember] = []
    public var reviews: [Review] = []
    public var isLoading = false
    public var errorMessage: String?
    public var showFullCast = false                        { didSet { recomputeDisplayedCast() } }

    // MARK: - Account action state
    public var isFavorite = false
    public var isInWatchlist = false
    public var isTogglingFavorite = false
    public var isTogglingWatchlist = false
    public var userLists: [UserList] = []
    public var isLoadingLists = false
    public var feedbackMessage: String?

    // MARK: - Private
    private let seriesId: Int
    private let service: any SeriesDetailServiceProtocol
    private let accountService: (any AccountServiceProtocol)?
    private let sessionManager: (any SessionManagerProtocol)?
    private var cachedAccountId: Int?

    public init(
        seriesId: Int,
        service: SeriesDetailServiceProtocol,
        accountService: AccountServiceProtocol? = nil,
        sessionManager: SessionManagerProtocol? = nil
    ) {
        self.seriesId = seriesId
        self.service = service
        self.accountService = accountService
        self.sessionManager = sessionManager
    }

    // MARK: - Load

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let detailTask  = service.fetchSeriesDetail(id: seriesId)
            async let creditsTask = service.fetchCredits(id: seriesId)
            async let reviewsTask = service.fetchReviews(id: seriesId)
            (detail, cast, reviews) = try await (detailTask, creditsTask, reviewsTask)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        await loadAccountStates()
    }

    // MARK: - Account actions

    public func toggleFavorite() async {
        guard !isTogglingFavorite,
              let sessionId = sessionManager?.getSession(),
              let accService = accountService else { return }
        isTogglingFavorite = true
        let newValue = !isFavorite
        isFavorite = newValue
        do {
            let accountId = try await resolvedAccountId(sessionId: sessionId, accountService: accService)
            try await service.markFavorite(accountId: accountId, seriesId: seriesId, sessionId: sessionId, isFavorite: newValue)
        } catch {
            isFavorite = !newValue
            feedbackMessage = "Failed to update favorites."
        }
        isTogglingFavorite = false
    }

    public func toggleWatchlist() async {
        guard !isTogglingWatchlist,
              let sessionId = sessionManager?.getSession(),
              let accService = accountService else { return }
        isTogglingWatchlist = true
        let newValue = !isInWatchlist
        isInWatchlist = newValue
        do {
            let accountId = try await resolvedAccountId(sessionId: sessionId, accountService: accService)
            try await service.markWatchlist(accountId: accountId, seriesId: seriesId, sessionId: sessionId, inWatchlist: newValue)
        } catch {
            isInWatchlist = !newValue
            feedbackMessage = "Failed to update watchlist."
        }
        isTogglingWatchlist = false
    }

    public func loadUserLists() async {
        guard !isLoadingLists,
              let sessionId = sessionManager?.getSession(),
              let accService = accountService else { return }
        isLoadingLists = true
        do {
            let accountId = try await resolvedAccountId(sessionId: sessionId, accountService: accService)
            userLists = try await service.fetchUserLists(accountId: accountId, sessionId: sessionId)
        } catch {
            userLists = []
        }
        isLoadingLists = false
    }

    public func addToList(listId: Int) async {
        guard let sessionId = sessionManager?.getSession() else { return }
        do {
            try await service.addToList(listId: listId, seriesId: seriesId, sessionId: sessionId)
            feedbackMessage = "Series added to list."
        } catch {
            feedbackMessage = "Failed to add series to list."
        }
    }

    // MARK: - Helpers

    private func loadAccountStates() async {
        guard let sessionId = sessionManager?.getSession(),
              let accService = accountService else { return }
        do {
            let accountId = try await resolvedAccountId(sessionId: sessionId, accountService: accService)
            let states = try await service.fetchAccountStates(seriesId: seriesId, sessionId: sessionId)
            _ = accountId
            isFavorite = states.isFavorite
            isInWatchlist = states.isInWatchlist
        } catch { }
    }

    private func resolvedAccountId(sessionId: String, accountService: any AccountServiceProtocol) async throws -> Int {
        if let cached = cachedAccountId { return cached }
        let profile = try await accountService.fetchAccountDetails(sessionId: sessionId)
        cachedAccountId = profile.id
        return profile.id
    }

    private func recomputeDisplayedCast() {
        displayedCast = showFullCast ? cast : Array(cast.prefix(6))
    }
}
