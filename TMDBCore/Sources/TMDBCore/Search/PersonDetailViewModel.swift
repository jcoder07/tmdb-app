import Observation

@MainActor
@Observable
public final class PersonDetailViewModel {

    public private(set) var detail: PersonDetail?
    public private(set) var knownForMovies: [Movie] = []
    public private(set) var knownForSeries: [Series] = []
    public var isLoading = false
    public var errorMessage: String?

    private let personId: Int
    private let service: any PersonServiceProtocol

    public init(personId: Int, service: any PersonServiceProtocol) {
        self.personId = personId
        self.service = service
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let detailTask = service.fetchDetail(id: personId)
            async let creditsTask = service.fetchCombinedCredits(id: personId)
            let (personDetail, credits) = try await (detailTask, creditsTask)
            detail = personDetail
            knownForMovies = credits.movies
            knownForSeries = credits.series
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
