import SwiftUI
import TMDBCore

struct BrowseResultsView: View {
    var viewModel: BrowseResultsViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel
    let makePersonDetailViewModel: (Int) -> PersonDetailViewModel

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
                switch viewModel.kind {
                case .movies:
                    moviesGrid
                case .tv:
                    seriesGrid
                case .people:
                    peopleGrid
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .movie(let id):
                MovieDetailView(viewModel: makeMovieDetailViewModel(id))
            case .series(let id):
                SeriesDetailView(viewModel: makeSeriesDetailViewModel(id))
            case .person(let id):
                PersonDetailView(viewModel: makePersonDetailViewModel(id))
            default:
                EmptyView()
            }
        }
        .task { await viewModel.load() }
    }

    private var moviesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: SearchRoute.movie(movie.id)) {
                        MediaPosterCard(title: movie.title, posterURL: movie.posterURL, voteAverage: movie.voteAverage)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var seriesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.series) { item in
                    NavigationLink(value: SearchRoute.series(item.id)) {
                        MediaPosterCard(title: item.name, posterURL: item.posterURL, voteAverage: item.voteAverage)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var peopleGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.people) { person in
                    NavigationLink(value: SearchRoute.person(person.id)) {
                        PersonCard(person: person)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var navigationTitle: String {
        switch viewModel.kind {
        case .movies:  return "Popular Movies"
        case .tv:      return "Popular TV Shows"
        case .people:  return "Popular People"
        }
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

private struct PersonCard: View {
    let person: PersonSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: person.profileURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "person.crop.circle")
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(person.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)

            if !person.knownForText.isEmpty {
                Text(person.knownForText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
