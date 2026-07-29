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

    public init(service: SeriesServiceProtocol) {
        self.service = service
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
