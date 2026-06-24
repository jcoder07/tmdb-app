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

    let movie: PopularMovie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: Constants.Urls.poster(path: movie.posterPath ?? "")) { phase in
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
