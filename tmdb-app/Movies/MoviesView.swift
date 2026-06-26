//
//  MoviesView.swift
//  tmdb-app
//

import SwiftUI

struct MoviesView: View {

    @ObservedObject var viewModel: MoviesViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage, viewModel.movies.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Text("Retry")
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.displayedMovies) { movie in
                            NavigationLink(value: movie.id) {
                                MovieCard(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    if viewModel.canShowMore {
                        Button {
                            Task { await viewModel.showMore() }
                        } label: {
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding(.vertical, 20)
                            } else {
                                Text("Show More")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "01B4E4"))
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                }
                .navigationDestination(for: Int.self) { movieId in
                    MovieDetailView(viewModel: viewModel.makeDetailViewModel(for: movieId))
                }
            }
        }
        .navigationTitle("Movies")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

private struct MovieCard: View {

    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "film")
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(movie.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews

private struct MockMoviesService: MoviesServiceProtocol {
    var page: MoviesPage = MoviesPage(movies: [], page: 1, totalPages: 1)
    var shouldFail = false
    var shouldHang = false

    func fetchPopularMovies(page: Int) async throws -> MoviesPage {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return self.page
    }
}

private struct MockMovieDetailService: MovieDetailServiceProtocol {
    func fetchMovieDetail(id: Int) async throws -> MovieDetail { fatalError("not used in preview") }
    func fetchCredits(id: Int) async throws -> [CastMember] { [] }
    func fetchReviews(id: Int) async throws -> [Review] { [] }
}

private let sampleMovies: [Movie] = [
    Movie(id: 1, title: "Inception",       posterURL: nil, voteAverage: 8.4, releaseDate: "2010-07-16"),
    Movie(id: 2, title: "The Dark Knight", posterURL: nil, voteAverage: 9.0, releaseDate: "2008-07-18"),
    Movie(id: 3, title: "Interstellar",    posterURL: nil, voteAverage: 8.7, releaseDate: "2014-11-07"),
    Movie(id: 4, title: "Oppenheimer",     posterURL: nil, voteAverage: 8.3, releaseDate: "2023-07-21"),
]

@MainActor
private func makeViewModel(service: MockMoviesService) -> MoviesViewModel {
    MoviesViewModel(service: service, detailService: MockMovieDetailService())
}

#Preview("Content") {
    NavigationStack {
        MoviesView(viewModel: makeViewModel(service: MockMoviesService(
            page: MoviesPage(movies: sampleMovies, page: 1, totalPages: 3)
        )))
    }
}

#Preview("Loading") {
    NavigationStack {
        MoviesView(viewModel: makeViewModel(service: MockMoviesService(shouldHang: true)))
    }
}

#Preview("Error") {
    NavigationStack {
        MoviesView(viewModel: makeViewModel(service: MockMoviesService(shouldFail: true)))
    }
}
