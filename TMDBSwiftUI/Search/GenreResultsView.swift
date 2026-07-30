import SwiftUI
import TMDBCore

struct GenreResultsView: View {
    var viewModel: GenreResultsViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage {
                errorView(message: message)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !viewModel.movies.isEmpty {
                            sectionHeader("Movies")
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.movies) { movie in
                                    NavigationLink(value: SearchRoute.movie(movie.id)) {
                                        MediaPosterCard(
                                            title: movie.title,
                                            posterURL: movie.posterURL,
                                            voteAverage: movie.voteAverage
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        if !viewModel.series.isEmpty {
                            sectionHeader("TV Shows")
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.series) { item in
                                    NavigationLink(value: SearchRoute.series(item.id)) {
                                        MediaPosterCard(
                                            title: item.name,
                                            posterURL: item.posterURL,
                                            voteAverage: item.voteAverage
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle(viewModel.genre.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .movie(let id):
                MovieDetailView(viewModel: makeMovieDetailViewModel(id))
            case .series(let id):
                SeriesDetailView(viewModel: makeSeriesDetailViewModel(id))
            default:
                EmptyView()
            }
        }
        .task { await viewModel.load() }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top, 4)
    }

    private func errorView(message: String) -> some View {
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
    }
}
