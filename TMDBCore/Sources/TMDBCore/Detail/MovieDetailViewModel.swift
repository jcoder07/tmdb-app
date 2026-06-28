import Observation

@MainActor
@Observable
public final class MovieDetailViewModel {

    public var detail: MovieDetail?
    public private(set) var cast: [CastMember] = []       { didSet { recomputeDisplayedCast() } }
    public private(set) var displayedCast: [CastMember] = []
    public var reviews: [Review] = []
    public var isLoading = false
    public var errorMessage: String?
    public var showFullCast = false                        { didSet { recomputeDisplayedCast() } }

    private let movieId: Int
    private let service: any MovieDetailServiceProtocol

    public init(movieId: Int, service: MovieDetailServiceProtocol) {
        self.movieId = movieId
        self.service = service
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let detailTask  = service.fetchMovieDetail(id: movieId)
            async let creditsTask = service.fetchCredits(id: movieId)
            async let reviewsTask = service.fetchReviews(id: movieId)
            (detail, cast, reviews) = try await (detailTask, creditsTask, reviewsTask)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func recomputeDisplayedCast() {
        displayedCast = showFullCast ? cast : Array(cast.prefix(6))
    }
}
