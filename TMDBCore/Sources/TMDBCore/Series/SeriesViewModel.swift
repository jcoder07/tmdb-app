import Observation

@MainActor
@Observable
public final class SeriesViewModel {

    public private(set) var series: [Series] = []
    public private(set) var hasMorePages = false
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?

    private var currentPage = 1
    private var totalPages = 1
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
            hasMorePages = currentPage < totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func loadNextPage() async {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        do {
            let page = try await service.fetchPopularSeries(page: currentPage + 1)
            let existingIds = Set(series.map(\.id))
            series += page.series.filter { !existingIds.contains($0.id) }
            currentPage += 1
            hasMorePages = currentPage < totalPages
        } catch { }
        isLoadingMore = false
    }
}
