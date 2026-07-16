import Observation

@MainActor
@Observable
public final class SeriesViewModel {

    public private(set) var series: [Series] = []         { didSet { recomputeDerived() } }
    public private(set) var displayedSeries: [Series] = []
    public private(set) var canShowMore = false
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?

    private var displayedCount = 8 { didSet { recomputeDerived() } }
    private var currentPage = 1   { didSet { recomputeDerived() } }
    private var totalPages = 1    { didSet { recomputeDerived() } }
    private let service: any SeriesServiceProtocol
    private let detailService: any SeriesDetailServiceProtocol
    private let accountService: (any AccountServiceProtocol)?
    private let sessionManager: (any SessionManagerProtocol)?
    private var detailViewModels: [Int: SeriesDetailViewModel] = [:]

    public init(
        service: SeriesServiceProtocol,
        detailService: SeriesDetailServiceProtocol,
        accountService: AccountServiceProtocol? = nil,
        sessionManager: SessionManagerProtocol? = nil
    ) {
        self.service = service
        self.detailService = detailService
        self.accountService = accountService
        self.sessionManager = sessionManager
    }

    public func makeDetailViewModel(for seriesId: Int) -> SeriesDetailViewModel {
        if let existing = detailViewModels[seriesId] { return existing }
        let vm = SeriesDetailViewModel(
            seriesId: seriesId,
            service: detailService,
            accountService: accountService,
            sessionManager: sessionManager
        )
        detailViewModels[seriesId] = vm
        return vm
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let page = try await service.fetchPopularSeries(page: 1)
            series = page.series
            totalPages = page.totalPages
            currentPage = 1
            displayedCount = min(8, page.series.count)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func showMore() async {
        guard !isLoadingMore else { return }
        let nextCount = displayedCount + 8
        if nextCount > series.count && currentPage < totalPages {
            isLoadingMore = true
            do {
                let page = try await service.fetchPopularSeries(page: currentPage + 1)
                series += page.series
                currentPage += 1
            } catch { }
            isLoadingMore = false
        }
        displayedCount = min(nextCount, series.count)
    }

    private func recomputeDerived() {
        displayedSeries = Array(series.prefix(displayedCount))
        canShowMore = displayedCount < series.count || currentPage < totalPages
    }
}
